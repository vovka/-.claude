---
name: claude-limits
description: Check the user's current Claude subscription usage limits (5-hour session window, weekly, and per-model). Use when the user asks about their usage, limits, quota, how much they have left, when their limit resets, or whether they're close to a cap.
allowed-tools: Bash
---

# Check Claude Usage Limits

The live limits (5-hour session %, weekly %, per-model weekly %) come from the
Anthropic usage endpoint, authenticated with the user's OAuth token. A helper
script reads the token internally and prints **only** the percentages — the
token itself is never exposed.

## How to check

Run the installed helper:

```bash
claude-limits          # formatted summary
claude-limits --json   # raw JSON (all fields)
```

Report the percentages and reset times back to the user. Example output:

```
Session (5h)            54%  (normal)  resets Fri Jul 3 17:59
Weekly (all)             6%  (normal)  resets Sat Jul 4 22:59
Weekly (Fable)           9%  (normal)  resets Sat Jul 4 22:59
```

## If the script is missing

Recreate it, or run the request inline (token is read into the header and never
printed):

```bash
TOKEN=$(jq -r '.claudeAiOauth.accessToken' "$HOME/.claude/.credentials.json")
curl -sS https://api.anthropic.com/api/oauth/usage \
  -H "Authorization: Bearer $TOKEN" \
  -H "anthropic-beta: oauth-2025-04-20" | jq .
```

Endpoint: `https://api.anthropic.com/api/oauth/usage`
Header: `anthropic-beta: oauth-2025-04-20`
Token: `~/.claude/.credentials.json` → `.claudeAiOauth.accessToken`

## Notes

- On **HTTP 401** the token is expired — running any `claude` command refreshes
  it, then retry.
- Never print the token or the raw `.credentials.json` contents. Only surface
  the usage numbers.
- For unattended periodic checks, add a cron entry:
  `0 * * * * claude-limits >> ~/.claude/limits.log 2>&1` (token may go stale if
  `claude` is unused for days).
