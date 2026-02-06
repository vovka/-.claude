---
name: extract-as-memory
description: Capture your personal philosophies, preferences, and decision rules into ~/.claude/CLAUDE.md
allowed-tools: Read, Edit, Write, Glob
---

# Extract as Memory

Memory captures things that should be true in ALL your projects:
- Personal principles ("I prefer simple over complex")
- Preferences ("Always include docstrings")
- Decision rules ("Performance costs time, prioritize shipping")
- Constraints ("Keep files under 200 lines")
- Values and tradeoffs

## 1. Detection Signals

Extract to memory when:
- You express a personal belief
- You say "I always...", "I prefer...", "I think...", "I believe..."
- A requirement applies everywhere, not just this project
- You state a value or principle
- Examples:
  - "I always write tests for public APIs"
  - "I prefer explicit over implicit"
  - "I value code clarity over cleverness"

## 2. Identify the Principle

What's true about your approach?
- Is it a preference? ("I prefer X")
- Is it a rule? ("I always do X")
- Is it a value? ("I believe X is important")
- Is it a constraint? ("I keep X under Y limit")

Examples:
- **Preference**: "I prefer simple implementations"
- **Rule**: "I always include error handling"
- **Value**: "I value maintainability over performance"
- **Constraint**: "I keep functions under 50 lines"

## 3. Find a Good Home

Structure your `~/.claude/CLAUDE.md` with sections:

```markdown
# Personal Claude Code Configuration Guide

## My Philosophy

### Core Values
[Your values...]

### Coding Preferences
- Language-specific preferences
- Architecture preferences
- Testing approach

### Business Mindset
[How you think about tradeoffs...]

### Quality Standards
[What matters to you...]
```

## 4. Write It Clearly

When documenting:
- Start with the principle
- Explain WHY you do it
- Give examples
- Link to relevant skills/rules if they implement it

Example:
```markdown
## Code Organization

### I prefer files under 200 lines
**Why**: Single responsibility is easier to test and maintain
**Example**: Backend service files stay focused on one concern
**Related**: see rule backend-standards.md for specifics
```

vs just:
```
Keep files short.
```

## 5. Categories to Consider

**Code Quality:**
- Naming preferences
- Line/complexity limits
- Documentation standards
- Type safety preferences

**Testing:**
- What you always test
- What you skip
- Test organization
- Coverage targets

**Architecture:**
- Monolith vs microservices
- Stateless vs stateful
- Async vs sync preferences
- Scalability priorities

**Business:**
- Cost vs feature tradeoffs
- Shipping speed vs perfection
- Automation priorities
- Risk tolerance

**Languages/Frameworks:**
- Python style guide
- JavaScript/TypeScript preferences
- Framework choices
- Dependency criteria

## 6. Organize by Concern

Good structure:
```markdown
# Personal Claude Code Configuration Guide

## Core Philosophy
[Overall approach...]

## Python Development
[Python preferences...]

## TypeScript Development
[TypeScript preferences...]

## Documentation
[Doc style...]

## Testing Strategy
[Testing approach...]

## Etsy Business Project
[Project-specific values...]
```

## 7. Link to Implementations

When a principle becomes a skill/rule/hook, link it:

```markdown
## Error Handling is Essential

I always include error handling in critical paths.

**Implementation**: see ~/.claude/rules/backend-standards.md
**Automation**: see ~/.claude/settings.json (error-validation hook)
**Skill**: /error-handling-patterns for detailed approach
```

## 8. Update Over Time

Your memory evolves:
- Add new principles as you discover them
- Refactor when principles become clearer
- Remove principles that don't hold up
- Track learning in dated sections

```markdown
### Learning Log
- 2025-01: Discovered preference for explicit error messages
- 2024-12: Moved away from complex abstractions
```

## Example Personal Memory

```markdown
# Personal Claude Code Configuration Guide

## Core Philosophy

### Code Clarity Over Cleverness
I value readable code that future-me can understand. This means:
- Explicit over implicit
- Boring over clever
- Duplication over complex abstractions (until pattern is proven)
- Comments that explain *why*, not *what*

### Automation Reduces Manual Work
I automate repetitive tasks (formatting, validation, testing).

### Simplicity Scales
Simple systems stay maintainable as they grow.

---

## Python Development

### Type Hints Are Essential
I use type hints on all functions. Why:
- Enables IDE autocomplete
- Catches bugs early
- Documents intent
- Makes refactoring safer

Related: see ~/.claude/rules/python-standards.md

### Testing Strategy
I write tests for:
- Public APIs
- Error cases
- Integration points
Never test:
- Trivial getters
- Framework code
- Hard-coded data

### Async for I/O, Threads for CPU
I use asyncio for network/disk I/O, threading for CPU work.
Rationale: asyncio is simpler but only works for I/O.

---

## Documentation

### Every Module Needs a Docstring
Why: new readers should understand purpose without reading code.

Docstring format:
```
"""Brief one-liner.

Longer explanation if needed.
"""
```

### Examples Beat Prose
I include runnable examples in docs.
Code examples are more useful than 100 words of explanation.

---

## Business Mindset (Etsy AI Project)

### Automate Early
Build automation for repeat tasks from the start.
Cost: 2 hours to automate = saves hours later.

### Design for Scale
Make architecture Cloud-ready even if not using it yet.

### Track Costs
Every feature has a cost (API calls, storage, compute).
Prefer cheap features over free.

---

## Quality Standards

### Code Review is Essential
I always code review before merge.
Check: security, performance, clarity, tests.

### Monitoring Over Confidence
I don't trust code without monitoring.
Add observability (logging, metrics) to critical paths.

### Security by Default
Assume untrusted input everywhere.
Validate all inputs at system boundaries.
```

## 9. Make It Discoverable

Add this section to the top:
```markdown
## Quick Links

### My Extraction Tools
- `/extract-as-skill` — save a workflow
- `/extract-as-rule` — save a path-specific requirement
- `/extract-as-subagent` — create a specialist
- `/extract-as-hook` — automate a check
- `/extract-and-save` — analyze conversation for patterns

See @~/.claude/CLAUDE.md#automatic-pattern-extraction for extraction guidelines.
```

## Example Output

```
✓ Updated memory: ~/.claude/CLAUDE.md
Added to "Code Organization" section:
- Principle: Files should stay under 200 lines
- Rationale: Single responsibility is easier to maintain
- Related rule: see backend-standards.md for specific standards

This principle now applies to all projects.
```

## Tips

- **Be specific**: "I prefer clarity" vs "Functions should be under 50 lines because [reason]"
- **Make it actionable**: Link to skills/rules that implement your principles
- **Revisit periodically**: Refactor memory as you learn
- **Don't over-document**: Just the things that really matter to you
- **Version your thinking**: Track how your philosophy evolves
