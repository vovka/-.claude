---
name: guarded-loop
description: Run a task in a resumable loop that watches Claude usage limits and pauses/resumes around the 5-hour cap, so long or overnight runs survive hitting the limit instead of dying. Use when the user says "run this in a guarded loop", "keep working on X overnight without blowing my limits", "loop this and pause when I'm near my cap", or invokes /guarded-loop with a task.
allowed-tools: Bash, Read, Write, Edit
---

# Guarded Loop

Run the user's task repeatedly (or until done) without getting permanently
stuck when the 5-hour usage cap is hit. Depends on `claude-limits --guard`
(the usage guard) and a **progress file** that makes any interruption
recoverable.

## The one invariant

**Pause BEFORE the cap, never after.** Once you are hard-blocked you cannot
take even the small turn needed to check limits and reschedule. So the guard
trips on a threshold with headroom (default 85%), not on the error.

## Setup (do this once when starting)

1. Pick a slug from the task; progress file = `~/.claude/loops/<slug>.md`
   (create `~/.claude/loops/` if missing). If the file already exists with
   unfinished work, **resume from it** — do not restart.
2. Write the header: the verbatim task, the plan broken into **small bounded
   units** (each unit = one iteration's worth of work), and a `status:` line.

## The loop

Each iteration:

1. `verdict=$(claude-limits --guard 85)` — check **once per unit**, never in a
   tight poll (the endpoint rate-limits / 429s).
2. Branch on the first word:
   - **PROCEED** → do exactly one bounded unit. Append the result + a
     checkpoint (what's done, what's next) to the progress file. Loop.
   - **WAIT n** → append "paused HH:MM, waiting ~n s for 5h reset" to the
     progress file, then stop working. Resume is handled by the driver below.
   - **STOP** (weekly cap) → append the reason, set `status: blocked-weekly`,
     **notify the user**, and stop. Weekly resets over days — do not wait.
   - Anything else / **HTTP 401** → token expired. Append a note; a running
     `claude` refreshes it. Schedule a retry in ~15m; stop this turn.
3. When every unit is done → set `status: done`, notify the user, stop.

Checkpoint *before* you schedule or stop, so a crash between turns loses nothing.

## Driver — how it gets re-triggered

**Unattended / overnight (most robust):** a **local** hourly `crontab` entry
that runs Claude Code headless (`claude -p "/guarded-loop <task>"`) on this
task. Each run reads the progress file, works while the guard says PROCEED,
then exits; cron re-fires regardless of crashes / reboots / dropped sessions,
so a 5-hour cap resolves itself (runs during the cap no-op, the first run after
reset resumes from the checkpoint). Two caveats: (1) it must be **local** — it
needs the local OAuth creds and the `claude-limits` script; cloud routines
(`schedule` skill / CronCreate) have neither and bill on a different account,
so the guard won't apply there. (2) A headless run needs a permission mode the
user must choose explicitly (a scoped `--allowedTools` allowlist, or accepting
`--dangerously-skip-permissions` in a trusted dir) — do not enable that for
them; surface the decision.

**Attended (you're around):** drive it with the in-session loop
(ScheduleWakeup). On WAIT, sleep `min(n, 3600)` seconds and recheck — a 5h
reset exceeds the 3600s wakeup cap, so re-sleep until the reset passes. Simpler
to start, but it is a live process: if the host/session dies mid-wait, nothing
resumes. Prefer cron for real overnight runs.

## Guardrails

- Threshold is tunable (`claude-limits --guard 90`); lower = safer, more idle
  headroom. Leave enough that the tiny wait/check turns don't creep to 100%.
- One guard check per unit. If units are very fast, batch a few between checks.
- Always resume from the progress file; treat it as the source of truth.
- Report to the user at start (what/where), on STOP, and on done.
