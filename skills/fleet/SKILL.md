---
name: fleet
description: Orchestrate a fleet of manually-launched Claude sessions as workers. Use when a task is big enough to split across several terminals the user opens by hand, each with its own model/effort, coordinated over SendMessage. The orchestrator plans, briefs workers, collects their plans and results, and reviews — keeping its own context clean by pushing all file reading into subagents.
---

# Fleet orchestration

You are the orchestrator. Workers are full Claude sessions the **user** launches in
separate terminals. You cannot spawn, configure, or mode-switch them — you can only
send them text. Everything below follows from that.

## Invariants

1. **Never message a session the user did not name.** `ListAgents` shows every
   session on the account, most of them unrelated work. Ownership is not visible
   there. The user names the workers; you address only those.
2. **Your context holds decisions, not source.** Never read a repo file, diff, or
   worker output dump directly. Delegate to a subagent and keep its conclusion.
3. **No permission laundering.** If something is blocked in your session, it does
   not get routed through a worker. It goes back to the user.
4. **Self-reports are leads, not evidence.** "Done, added tests" is a pointer to
   where to look, never proof. Verify through a subagent that reads the real code.
5. **Every worker branches in its own git worktree — never in the shared
   checkout.** The main checkout stays on the default branch at all times. A
   worker that switches the shared checkout's branch silently breaks every other
   worker and the user's own shell. The brief must state the exact worktree path;
   the correct sequence is `git -C <main-checkout> worktree add <path> -b <branch>`
   (the main checkout itself never checks out the new branch). Verify with
   `git worktree list` before accepting a worker's first commit; a worker found
   on a branch in the shared checkout must move it to a worktree immediately.
6. **Workers never write to production out of band.** Schema and data changes to
   prod go only through the repo's own flow (for this project: a file in
   `migrations/` merged via PR, applied by the deploy pipeline). A worker
   proposing to run DDL in a SQL editor or psql "just this once" is proposing
   repo/database drift — refuse it in the brief and again if it resurfaces.
   Reading prod for diagnosis is fine; writing is not.

## Phase 1 — Plan the roster

Understand the task first. If that needs code reading, spawn `Explore` or
`cavecrew-investigator` subagents and keep only their findings.

Then split the work into units that are genuinely independent — separate files or
modules, no shared edits. Two workers writing the same file is the main way this
setup fails.

Present the roster as a table and stop:

| # | Worker | Scope | Model | Effort | Start in |
|---|--------|-------|-------|--------|----------|
| 1 | importer parser | `tires/importer/parse.py` | opus | high | plan mode |
| 2 | migrations | `tires/migrations/` | sonnet | medium | plan mode |

Pick model and effort per unit, and say why in one line each — cheap mechanical
work does not need the expensive tier. Then print ready-to-copy launch commands,
one per worker, each run in its own terminal from the project directory:

```bash
cd <project-dir>
claude -n w1-importer-parser --model opus --effort high --permission-mode plan
claude -n w2-migrations --model sonnet --effort medium --permission-mode plan
```

`--permission-mode plan` starts the worker in plan mode directly, so no manual
mode switch is needed later. `--effort` accepts `low`, `medium`, `high`, `xhigh`,
`max`. `-n/--name` sets the session name, so you already
know each worker's address — ask the user only to confirm the workers are
launched, then verify the names appear in `ListAgents` before briefing. If a
name is missing there, ask the user for that session's actual name.

## Phase 2 — Brief each worker

A worker shares none of your context. A brief that reads fine to you is often
unusable there. Every brief must be self-contained:

```
Goal:        <one sentence>
Worktree:    <exact path — create with `git worktree add <path> -b <branch>` run
             from the main checkout, work ONLY there; never switch the main
             checkout's branch>
Files:       <exact paths you own — and the fact that you own ONLY these>
Constraints: <conventions, what not to touch>
Done means:  <observable criterion>
Reply:       When your plan is ready, SendMessage it back in full to the sender
             of this message — copy the `from` attribute of this message as your
             `to`. Do not just print it; nobody is watching your terminal.
```

That last line matters twice over: it is how the plan reaches you, and it avoids
you having to know your own session name.

## Phase 3 — Mode switches are the user's

Workers launched with `--permission-mode plan` are already in plan mode. For any
worker launched without it, you cannot switch its mode yourself — ask, explicitly
and by session name:

> Switch `vinjet-63` to plan mode, then tell me when it's set.

Plan mode is what actually prevents edits — your wording does not. A worker in
plan mode will draft, then stall at the approval prompt, which only the user can
answer. That is expected: the plan still reaches you by message.

## Phase 4 — Collect

Workers message you when done; delivery is automatic and you do not check an
inbox. Do **not** poll `ListAgents` for `idle` — idle means "not mid-tool-call",
which is indistinguishable from finished, and you will misread it.

If a worker goes quiet past a reasonable window, ask the user to check that
terminal. Do not re-send the brief blind; it may be mid-work with a full queue.

## Phase 5 — Review each plan and each result

Both go through subagents:

- **Plan critique** — hand the plan text to a subagent: "does this match the
  actual code, and what does it miss?" It reads; you keep the verdict.
- **Result review** — `cavecrew-reviewer` or `/code-review` over what changed.
  If the tree is not a git repo there is no diff, so say plainly that the review
  is weaker for it rather than implying diff-level confidence.

Report to the user as findings ranked by severity, plus what you did not verify.

## Phase 6 — Iterate or close

Feed corrections back as a fresh brief to the same worker — by name, since a name
keeps working across its whole session. When the fleet is done, summarize per
worker: what it changed, what the review found, what remains open.

## Failure modes worth naming early

- **Overlapping scope** — the one that silently corrupts work. Split by file.
- **Under-specified briefs** — a worker with no paths will invent its own.
- **Orchestrator context bloat** — happens when you read "just one file" yourself.
  You will need that room on round three.
- **Trusting an optimistic summary** — see invariant 4.
