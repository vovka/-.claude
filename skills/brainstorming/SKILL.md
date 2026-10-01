---
name: brainstorming
description: Turn a rough idea into a validated design through one-at-a-time questions. Use before building anything nontrivial, when the user wants to brainstorm/stress-test/think through a plan, or uses 'brainstorm'/'grill' trigger phrases.
---

Explore the idea with me before we build anything. If a *fact* can be found by reading the codebase, look it up — don't ask me. The *decisions* are mine.

1. **Look around first.** Check relevant files/docs so your questions aren't answerable from the repo.
2. **Ask one question at a time**, waiting for my answer before the next. Prefer multiple-choice; always give your recommended answer and why.
3. **Once you understand the goal**, propose 2-3 approaches with trade-offs, leading with your recommendation. For any module/service/component boundary decision, invoke `codebase-design` first so the trade-offs use the deep-module/seam vocabulary, not vibes.
4. **Present the resulting design** in plain conversation — scale it to the complexity, no template required.
5. Do not write code, scaffold files, or otherwise act on the plan until I've confirmed we have a shared understanding.

Skip this entirely for trivial, unambiguous asks — brainstorming is for things worth getting wrong.
