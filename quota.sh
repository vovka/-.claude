#!/usr/bin/env bash
# Report the Claude subscription quota, for headless readers.
#
# There is no API and no `claude usage` subcommand. The CLI parses the limits
# from `anthropic-ratelimit-unified-*` response headers and keeps them in
# process memory; the single place it hands them out is the statusline payload.
# `statusline-command.sh` mirrors that payload to rate-limits.json, and this
# script reads it. Cost: nothing. No API call, no tokens.
#
# The cache is only as fresh as the last statusline render of *some* live
# session. A session renders on every turn, so a reader that is itself a live
# session (the dark-run operator loop) always sees its own current numbers.
# Anything older than STALE_MIN is reported as STALE and must not be trusted.
set -uo pipefail

CACHE=/home/vova/.claude/rate-limits.json
STALE_MIN=15

[ -r "$CACHE" ] || { echo "STATUS: UNKNOWN"; echo "reason: no cache at $CACHE — no session has rendered a statusline yet"; exit 0; }

now=$(date +%s)
written=$(date -d "$(jq -r '.written_at' "$CACHE")" +%s 2>/dev/null || echo 0)
age_min=$(( (now - written) / 60 ))

five_pct=$(jq -r '.rate_limits.five_hour.used_percentage // empty' "$CACHE")
five_at=$(jq -r '.rate_limits.five_hour.resets_at // empty' "$CACHE")
seven_pct=$(jq -r '.rate_limits.seven_day.used_percentage // empty' "$CACHE")
seven_at=$(jq -r '.rate_limits.seven_day.resets_at // empty' "$CACHE")

[ -n "$five_pct" ] || { echo "STATUS: UNKNOWN"; echo "reason: cache has no five_hour block"; exit 0; }

five_left=$(( (five_at - now) / 60 ))
seven_left=$(( (seven_at - now) / 3600 ))

# The thresholds are the operator's release decision, encoded here so it is made
# the same way every firing rather than re-judged by whoever is awake.
#   OPEN     — release any gate.
#   TIGHT    — release a document gate; hold `implement`, the expensive stage.
#   CLOSED   — release nothing.
if   [ "$age_min" -gt "$STALE_MIN" ]; then status="STALE"
elif [ "${five_pct%.*}" -ge 85 ];     then status="CLOSED"
elif [ "${five_pct%.*}" -ge 60 ];     then status="TIGHT"
else                                       status="OPEN"
fi

echo "STATUS: $status"
echo "five_hour_used_pct: $five_pct"
echo "five_hour_resets_at: $(date -d "@$five_at" -u +%Y-%m-%dT%H:%M:%SZ) ($(date -d "@$five_at" +%H:%M) local)"
echo "five_hour_minutes_left: $five_left"
echo "seven_day_used_pct: $seven_pct"
echo "seven_day_resets_at: $(date -d "@$seven_at" -u +%Y-%m-%dT%H:%M:%SZ)"
echo "seven_day_hours_left: $seven_left"
echo "cache_age_min: $age_min"
