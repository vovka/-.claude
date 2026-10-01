---
name: multi-model-planning
description: Route a nontrivial task through a model pipeline before implementing — Fable for strategic direction, Opus for turning that direction into a concrete implementation plan, then implement in the current (Sonnet) session. Use for "should we build X", "what's the right approach", "help me think through this direction/architecture" — direction-setting requests where no plan exists yet. Do not use for small/single-file tasks, or when the user already has a clear direction and just wants an implementation plan (go straight to impl-planner) or just wants code written.
allowed-tools: Agent, AskUserQuestion, SendMessage
---

# Multi-model planning pipeline

Two stages, each a foreground subagent spawn, each allowed to ask for
clarification instead of guessing. You are the orchestrator throughout —
the subagents never talk to the user directly.

## Stage 1 — strategic direction (Fable)

1. Spawn `subagent_type: strategic-planner`, `run_in_background: false`,
   with the full task/question as the prompt.
2. If its response ends with open questions (not a finished direction):
   use `AskUserQuestion` to ask the user those exact questions — don't
   paraphrase them into prose first.
   Then call `SendMessage` addressed to that **same agent id** with the
   user's answers, to resume it with full context. Do not start a fresh
   Agent call — that throws away everything it already worked out.
   Repeat until it returns a direction with no open questions.
3. Show the user the finished strategic direction. This is a real
   decision point (it drives Opus-effort spend next) — get an explicit
   go-ahead, even a quick one, before moving on.

## Stage 2 — implementation plan (Opus)

4. Spawn `subagent_type: impl-planner`, `run_in_background: false`, with
   the confirmed strategic direction as the prompt.
5. Same clarification loop as stage 1: open questions → `AskUserQuestion`
   → `SendMessage` to resume the same agent → repeat until it returns a
   complete plan.
6. Show the user the finished implementation plan.

## Stage 3 — implementation (Sonnet)

7. Execute directly in this session. No subagent needed — this session
   already is the Sonnet implementer.

## Scope guard

Skip this pipeline for small, single-file, or already-well-specified
tasks — spawning two max-effort subagents for a one-line fix is pure
overhead. Go straight to implementation, or straight to `impl-planner`
alone if a plan is needed but the direction isn't in question.
