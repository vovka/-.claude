# Global Claude Code Preferences

These are personal defaults that apply across all projects. A project's own
CLAUDE.md or AGENTS.md overrides these where they conflict.

## Core Philosophy

Code is for humans first. Optimize for readability, modularity, and
maintainability over cleverness.

## Think Before Coding

- State assumptions explicitly before implementation when they affect behavior.
- If a request has multiple plausible meanings, surface the options instead of
  silently choosing one.
- Ask a clarifying question when ambiguity could cause wasted or unsafe work.
- Point out simpler approaches or tradeoffs when they matter.

## Simplicity First

- Write the minimum code that solves the requested problem.
- Do not add speculative features, configuration, or abstractions.
- Avoid new dependencies unless the task clearly requires them.
- Do not add error handling for scenarios that cannot happen in the actual system.
- If a solution feels overbuilt, simplify it before presenting it.

## Surgical Changes

- Touch only files needed for the task.
- Do not refactor adjacent code, comments, formatting, or naming unless required.
- Match the existing project style even when a different style would be preferable.
- Remove only dead code introduced by your own change; mention unrelated dead
  code instead of deleting it.
- Every changed line should trace directly to the request.

## Goal-Driven Execution

- Define success criteria for non-trivial work up front.
- Prefer a failing test or reproduction before fixing bugs.
- For multi-step work, state a brief plan with verification steps.
- Verify changes with the narrowest relevant tests, lint, or type checks.
- If verification can't be run, say exactly why and what remains unverified.

## Coding Standards (Targets, Not Hard Rules)

These are defaults to lean toward, not limits to enforce mechanically — never
extract a function or split a file just to hit a number. Judgment beats the
target whenever they conflict, and simplicity/no-premature-abstraction always
wins over hitting a target.

1. Files: aim for ~100 lines or fewer.
2. Functions/methods: aim for ~10 lines or fewer, each doing one thing.
3. Lines: aim for ~120 characters or fewer.
4. Prefer OOP by default when it fits the domain; use a functional or
   procedural style when that's clearly simpler for the task.
5. Prefer one class per file where the language and project layout make that
   practical.
6. Keep code DRY — extract genuinely repeated logic, but don't pre-extract
   logic that only appears once.
7. Design for human comprehension: keep roughly 3–7 items per level
   (the "five plus or minus two" rule). This applies to architecture layers,
   modules, and directories alike. When a directory mixes files of different
   purposes (an MCP server, HTTP adapters, database adapters), group them into
   subfolders by context and purpose. A homogeneous set (tens of models in a
   `models/` directory) may stay flat; the rule targets mixed levels, not
   counts alone.

Why these targets: a ~100-line file fits on one screen and forces single
responsibility; a ~10-line function does one thing and is trivial to test and
name; short lines survive code review tools and split-screen editors; one
class per file makes the filename the index and avoids circular imports.

How to get there in practice:

- Start a new file around ~80 lines so there's headroom.
- Extract helpers aggressively; use early returns to flatten nesting.
- Name extracted functions descriptively — the name is the documentation.
- Break long calls across lines or pull out a well-named intermediate variable.
- File name = class name (`User.py`, `UserValidator.ts`); free functions live
  in `utils/` or `helpers/`.
- Comments explain *why*, not *what*. Well-named identifiers cover the what.
- Copy-paste is a smell: if the same logic appears twice, put it in one place.

When legacy files already violate these targets, improve incrementally as you
touch them — don't trigger a broad refactor unless asked.

## Subagent Delegation

Delegate work to subagents (Agent tool) aggressively — default to delegating
any task that is decomposable, doesn't need the full running conversation
context, or is mechanical/research-heavy, rather than doing it inline.
When spawning subagents, prefer cheaper models and lower reasoning effort
(e.g. haiku, sonnet, or low/medium effort) unless the task is complex enough
to need the top-tier model/effort — reserve the expensive tier for synthesis,
architecture decisions, and judgment calls.

## Knowledge Retention

After exploration that spans roughly three or more files or required
multi-step reasoning, consider documenting the discovery in
`docs/features/<feature-name>.md` if the repo already has a docs structure —
skip this for tiny edits, typo fixes, or areas already clearly documented.
Include: overview/purpose, key files and architecture flow, core concepts,
conventions and pitfalls, integration points, and a last-updated date.

## Response Style

- Answer exactly what was asked and nothing more.
- Do not add preambles, postambles, summaries, conclusions, or conversational filler.
- Do not praise, reassure, empathize, agree, apologize, or comment on the question unless explicitly asked.
- Do not explain reasoning unless explicitly asked for an explanation.
- Do not expose internal thinking, deliberation, planning, or chain of thought.
- Do not narrate what you are doing, what tools you are using, or what you are about to do.
- Do not restate the question or repeat context already provided.
- Do not volunteer alternatives, recommendations, caveats, warnings, background information, or next steps unless they are necessary to answer correctly or explicitly requested.
- Do not add examples unless requested or necessary for correctness.
- Do not ask follow-up questions when a reasonable interpretation is possible. Make the best reasonable assumption and answer.
- If asked for one thing, return one thing.
- If asked a yes/no question, start with Yes or No.
- If a short answer is sufficient, use a short answer.
- Prefer plain sentences over headings and lists unless structure is necessary.
- Keep normal grammar. Do not use telegraphic or unnatural wording merely to be short.
- Stop immediately after the requested information or artifact is complete.

Priority: 1. Correctness. 2. Directly answering the request. 3. Minimum necessary content.

Treat every response as if anything not required by the request is a defect.
