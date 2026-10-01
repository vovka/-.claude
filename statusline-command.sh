#!/usr/bin/env bash
# Claude Code statusLine command
#
# Cycles through three formats every 5 minutes based on (current_minute % 15):
#   Minutes  0-4  (minute%15 <  5): dot  separators · with progress bars [▓▓▓░░░░░░░]
#   Minutes  5-9  (minute%15 < 10): pipe separators | with circle indicators ◑/◔
#   Minutes 10-14 (minute%15 >= 10): pipe separators | with pacman progress ᗧ······
#
# Padding in circles mode is controlled by USE_PADDING (default: false).
# Set USE_PADDING=true before calling build_line to enable 12-space circle padding
# so that separators align vertically when all three modes are shown at once.
#
# Input: JSON from stdin (Claude Code context)

# --- Helpers: progress bars ---

# 10-char bar for context used (filled on left, empties on right).
# make_bar_used <used_pct>
make_bar_used() {
  local used="${1:-0}"
  local filled=$(( (used * 10 + 50) / 100 ))
  [ "$filled" -gt 10 ] && filled=10
  local empty=$(( 10 - filled ))
  local bar="" i=0
  while [ "$i" -lt "$filled" ]; do bar="${bar}▓"; i=$(( i + 1 )); done
  i=0
  while [ "$i" -lt "$empty" ]; do bar="${bar}░"; i=$(( i + 1 )); done
  printf "[%s]" "$bar"
}

# 10-char bar for rate limit used (filled on left, empties on right).
# make_bar_rate <used_pct>
make_bar_rate() {
  local used="${1:-0}"
  local filled=$(( (used * 10 + 50) / 100 ))
  [ "$filled" -gt 10 ] && filled=10
  local empty=$(( 10 - filled ))
  local bar="" i=0
  while [ "$i" -lt "$filled" ]; do bar="${bar}▓"; i=$(( i + 1 )); done
  i=0
  while [ "$i" -lt "$empty" ]; do bar="${bar}░"; i=$(( i + 1 )); done
  printf "[%s]" "$bar"
}

# Pacman-style 11-char progress bar based on usage percentage.
# Position 0 = leftmost, position 10 = rightmost.
# pacman moves left to right as percentage increases.
# make_pacman <used_pct>
make_pacman() {
  local pct="${1:-0}"
  local pos=$(( pct / 10 ))
  [ "$pos" -gt 10 ] && pos=10
  local bar="" i=0
  local face="ᗧ"
  [ "$pct" -gt 100 ] && face="💀"
  while [ "$i" -lt "$pos" ]; do bar="${bar} "; i=$(( i + 1 )); done
  bar="${bar}${face}"
  i=$(( pos + 1 ))
  while [ "$i" -le 10 ]; do bar="${bar}·"; i=$(( i + 1 )); done
  printf "[%s]" "$bar"
}

# Quarter-circle sector indicator based on usage percentage.
# circle_for <used_pct>
#   0-12%:   ○  (empty)
#   13-37%:  ◔  (1/4 filled)
#   38-62%:  ◑  (1/2 filled)
#   63-88%:  ◕  (3/4 filled)
#   89-100%: ●  (full)
circle_for() {
  local pct="${1:-0}"
  if [ "$pct" -le 12 ]; then
    printf "○"
  elif [ "$pct" -le 37 ]; then
    printf "◔"
  elif [ "$pct" -le 62 ]; then
    printf "◑"
  elif [ "$pct" -le 88 ]; then
    printf "◕"
  else
    printf "●"
  fi
}

# Format seconds until reset as "2h:3m → 14:35" or "3d:1h → Sat 13:20".
# format_reset <resets_at_epoch>
format_reset() {
  local resets_at="$1"
  local now
  now=$(date +%s)
  local secs=$(( resets_at - now ))
  [ "$secs" -le 0 ] && return
  local days=$(( secs / 86400 ))
  local hours=$(( (secs % 86400) / 3600 ))
  local mins=$(( (secs % 3600) / 60 ))
  local clock_time
  local remaining
  if [ "$days" -gt 0 ]; then
    remaining=$(printf "%dd:%dh" "$days" "$hours")
    clock_time=$(date -d "@${resets_at}" "+%a %H:%M")
  else
    remaining=$(printf "%dh:%dm" "$hours" "$mins")
    clock_time=$(date -d "@${resets_at}" "+%H:%M")
  fi
  printf "%s → %s" "$remaining" "$clock_time"
}

# Format a raw token count as a compact string: e.g. 549000 -> 549K, 1200000 -> 1.2M.
# Always uses a period as decimal separator regardless of locale.
# fmt_tok <count>
fmt_tok() {
  local n="${1:-0}"
  if [ "$n" -ge 1000000 ]; then
    LC_ALL=C awk -v v="$n" 'BEGIN {
      val = v / 1000000
      if (val == int(val)) printf "%gM", val
      else printf "%.1fM", val
    }'
  elif [ "$n" -ge 1000 ]; then
    LC_ALL=C awk -v v="$n" 'BEGIN {
      val = v / 1000
      if (val == int(val)) printf "%gK", val
      else printf "%.1fK", val
    }'
  else
    printf "%s" "$n"
  fi
}

# --- Determine display mode ---
current_minute=$(date +%-M)
interval=$(( current_minute % 15 ))
if [ "$interval" -lt 5 ]; then
  MODE="dot"     # minutes  0-4: dots + bars
elif [ "$interval" -lt 10 ]; then
  MODE="pipe"    # minutes  5-9: pipes + circles
else
  MODE="pacman"  # minutes 10-14: pipes + pacman
fi

# --- Parse input ---
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // empty')
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // empty')
effort=$(echo "$input" | jq -r '.effort.level // empty')
ctx_used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_total=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
ctx_input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
five_h_used=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_h_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_d_used=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_d_resets=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
# Side-channel for headless readers (the dark-run operator loop). The CLI keeps
# rate limits in process memory, parsed from `anthropic-ratelimit-unified-*`
# response headers, and the only place it hands them out is this statusline
# payload. Mirroring them to a file makes them readable by anything else on the
# box. Written atomically so a reader never sees a half-file, and only when the
# payload actually carries limits — a session that has not yet made an API call
# has none, and clobbering a good cache with nulls would be worse than stale.
rl_cache="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/rate-limits.json"
if [ -n "$five_h_used" ]; then
  jq -c --arg at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    '{written_at: $at, rate_limits: .rate_limits}' <<<"$input" \
    > "$rl_cache.tmp" 2>/dev/null \
    && mv "$rl_cache.tmp" "$rl_cache"
fi

# Session token totals, tallied from the transcript (the payload's
# context_window.total_* fields are last-call only, not session totals).
# State is cached per session so each run only scans newly-appended bytes.
transcript=$(echo "$input" | jq -r '.transcript_path // empty')
sid=$(echo "$input" | jq -r '.session_id // empty')
sess_tok_in="" sess_tok_cache="" sess_tok_out=""
if [ -n "$transcript" ] && [ -n "$sid" ] && [ -f "$transcript" ]; then
  state_dir="${XDG_RUNTIME_DIR:-/tmp}/claude-statusline"
  state_file="$state_dir/$sid"
  mkdir -p "$state_dir"

  st_offset=0 st_in=0 st_cache=0 st_out=0 st_last=""
  if [ -f "$state_file" ]; then
    read -r st_offset st_in st_cache st_out st_last < "$state_file"
  fi

  transcript_size=$(wc -c < "$transcript" | tr -d ' ')
  # Transcript shrank/rotated (e.g. new session file) — start over.
  if [ "$transcript_size" -lt "$st_offset" ]; then
    st_offset=0 st_in=0 st_cache=0 st_out=0 st_last=""
  fi

  new_data_file=$(mktemp)
  tail -c +$((st_offset + 1)) "$transcript" > "$new_data_file" 2>/dev/null
  new_bytes=$(wc -c < "$new_data_file" | tr -d ' ')

  consumed=0
  if [ "$new_bytes" -gt 0 ]; then
    if [ -z "$(tail -c1 "$new_data_file")" ]; then
      # Last byte is a newline: everything read is complete lines.
      consumed=$new_bytes
    else
      # Trailing partial line (still being written) — don't consume it yet.
      last_line=$(tail -n1 "$new_data_file")
      last_line_bytes=$(printf '%s' "$last_line" | wc -c)
      consumed=$(( new_bytes - last_line_bytes ))
    fi
  fi

  read -r new_in new_cache new_out new_last < <(
    head -c "$consumed" "$new_data_file" | jq -Rr '
      fromjson? | select(.message.usage and .message.id) |
      [.message.id,
       ((.message.usage.input_tokens // 0) + (.message.usage.cache_creation_input_tokens // 0)),
       (.message.usage.cache_read_input_tokens // 0),
       (.message.usage.output_tokens // 0)
      ] | @tsv' |
    awk -F'\t' -v prev="$st_last" -v acc_in="$st_in" -v acc_cache="$st_cache" -v acc_out="$st_out" '
      {
        if ($1 == prev) next
        acc_in += $2; acc_cache += $3; acc_out += $4
        prev = $1
      }
      END { printf "%d %d %d %s\n", acc_in, acc_cache, acc_out, prev }'
  )
  rm -f "$new_data_file"

  new_offset=$(( st_offset + consumed ))
  tmp_state=$(mktemp "${state_dir}/.tmp.XXXXXX")
  printf '%s %s %s %s %s\n' "$new_offset" "$new_in" "$new_cache" "$new_out" "$new_last" > "$tmp_state"
  mv "$tmp_state" "$state_file"

  sess_tok_in="$new_in"
  sess_tok_cache="$new_cache"
  sess_tok_out="$new_out"
fi

cost_total=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')

# ANSI colors.
# Odd blocks (1, 3):  dark cyan  \033[36m
# Even blocks (2, 4): dark blue  \033[34m
# Separator:          terminal default (no explicit color)
COLOR_ODD="\033[36m"
COLOR_EVEN="\033[34m"
COLOR_RESET="\033[0m"

# --- Build section strings for a given render mode ---
# build_line <render_mode>  — prints one assembled status line to stdout.
build_line() {
  local render_mode="$1"

  # Model + effort section
  local _model_part=""
  [ -n "$model" ] && _model_part="$model"
  [ -n "$effort" ] && _model_part="$_model_part, $effort"

  # CWD section
  local _cwd_part=""
  [ -n "$cwd" ] && _cwd_part="$cwd"

  # Shared percentage for context (computed once, reused across render modes)
  local _ctx_bar_pct=""
  [ -n "$ctx_used_pct" ] && _ctx_bar_pct=$(LC_ALL=C printf '%.0f' "$ctx_used_pct")

  # Progress indicator widths (for separator alignment across modes):
  #   pacman: [xxxxxxxxxxx] = 13 chars  (widest — reference width)
  #   dot bar: [xxxxxxxxxx] = 12 chars  → pad 1 space after ]
  #   circle:  ◑            =  1 char   → pad 12 spaces after symbol
  local _BAR_PAD=" "          # 1 space: dot bar -> pacman width
  local _CIR_PAD=""            # circle padding: 12 spaces when USE_PADDING=true, empty otherwise
  [ "${USE_PADDING:-false}" = "true" ] && _CIR_PAD="            "

  # Context section
  local _ctx_part=""
  if [ -n "$_ctx_bar_pct" ]; then
    local _ctx_tokens=""
    if [ -n "$ctx_input_tokens" ] && [ -n "$ctx_total" ]; then
      _ctx_tokens=" \033[2m($(fmt_tok "$ctx_input_tokens")/$(fmt_tok "$ctx_total"))\033[22m"
    fi
    if [ "$render_mode" = "dot" ]; then
      _ctx_part="ctx ${_ctx_bar_pct}%${_ctx_tokens} $(make_bar_used "$_ctx_bar_pct")${_BAR_PAD}"
    elif [ "$render_mode" = "pipe" ]; then
      _ctx_part="ctx ${_ctx_bar_pct}%${_ctx_tokens} $(circle_for "$_ctx_bar_pct")${_CIR_PAD}"
    else
      _ctx_part="ctx ${_ctx_bar_pct}%${_ctx_tokens} $(make_pacman "$_ctx_bar_pct")"
    fi
  fi

  # 5-hour rate limit section
  local _five_h_part=""
  if [ -n "$five_h_used" ]; then
    local _five_h_pct=$(LC_ALL=C printf '%.0f' "$five_h_used")
    local _five_h_time=""
    [ -n "$five_h_resets" ] && _five_h_time=$(format_reset "$five_h_resets")
    local _five_h_indicator=""
    if [ "$render_mode" = "dot" ]; then
      _five_h_indicator="$(make_bar_rate "$_five_h_pct")${_BAR_PAD}"
    elif [ "$render_mode" = "pipe" ]; then
      _five_h_indicator="$(circle_for "$_five_h_pct")${_CIR_PAD}"
    else
      _five_h_indicator="$(make_pacman "$_five_h_pct")"
    fi
    _five_h_part="\033[1m5h ${_five_h_pct}%\033[22m ${_five_h_indicator}"
    [ -n "$_five_h_time" ] && _five_h_part="$_five_h_part \033[2m$_five_h_time\033[22m"
  fi

  # 7-day rate limit section
  local _seven_d_part=""
  if [ -n "$seven_d_used" ]; then
    local _seven_d_pct=$(LC_ALL=C printf '%.0f' "$seven_d_used")
    local _seven_d_time=""
    [ -n "$seven_d_resets" ] && _seven_d_time=$(format_reset "$seven_d_resets")
    local _seven_d_indicator=""
    if [ "$render_mode" = "dot" ]; then
      _seven_d_indicator="$(make_bar_rate "$_seven_d_pct")${_BAR_PAD}"
    elif [ "$render_mode" = "pipe" ]; then
      _seven_d_indicator="$(circle_for "$_seven_d_pct")${_CIR_PAD}"
    else
      _seven_d_indicator="$(make_pacman "$_seven_d_pct")"
    fi
    _seven_d_part="\033[1m7d ${_seven_d_pct}%\033[22m ${_seven_d_indicator}"
    [ -n "$_seven_d_time" ] && _seven_d_part="$_seven_d_part \033[2m$_seven_d_time\033[22m"
  fi

  # Token accumulation section (session totals, tallied from the transcript)
  local _tok_part=""
  if [ -n "$sess_tok_in" ]; then
    local total_in="${sess_tok_in:-0}"
    local cached="${sess_tok_cache:-0}"
    local total_out="${sess_tok_out:-0}"
    local tok_sum=$(( total_in + cached + total_out ))
    _tok_part="tok $(fmt_tok "$tok_sum"), cached $(fmt_tok "$cached"), ↑ $(fmt_tok "$total_in"), ↓ $(fmt_tok "$total_out")"
  fi

  # Cost section
  local _cost_part=""
  [ -n "$cost_total" ] && _cost_part="$(LC_ALL=C printf '$%.2f' "$cost_total")"

  # Assemble sections array
  local sections=()
  [ -n "$_model_part"   ] && sections+=("$_model_part")
  [ -n "$_cwd_part"     ] && sections+=("$_cwd_part")
  [ -n "$_ctx_part"     ] && sections+=("$_ctx_part")
  [ -n "$_five_h_part"  ] && sections+=("$_five_h_part")
  [ -n "$_seven_d_part" ] && sections+=("$_seven_d_part")
  [ -n "$_tok_part"     ] && sections+=("$_tok_part")
  [ -n "$_cost_part"    ] && sections+=("$_cost_part")

  local SEP
  if [ "$render_mode" = "pipe" ]; then
    SEP=" | "
  else
    SEP=" · "
  fi

  local line=""
  for i in "${!sections[@]}"; do
    local block_num=$(( i + 1 ))
    local color
    if (( block_num % 2 == 1 )); then
      color="$COLOR_ODD"
    else
      color="$COLOR_EVEN"
    fi
    if [ -z "$line" ]; then
      line="${color}${sections[$i]}${COLOR_RESET}"
    else
      line="${line}${COLOR_RESET}${SEP}${color}${sections[$i]}${COLOR_RESET}"
    fi
  done

  [ -n "$line" ] && printf "%b\n" "$line"
}

# --- Output current variant based on 15-minute cycle ---
# Single-variant display: no circle padding needed (USE_PADDING defaults to false).
# To review all three variants aligned, replace the line below with:
#   USE_PADDING=true
#   build_line "dot"
#   build_line "pipe"
#   build_line "pacman"
build_line "$MODE"
