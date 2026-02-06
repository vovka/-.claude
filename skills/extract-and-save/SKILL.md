---
name: extract-and-save
description: Analyze this conversation and automatically extract all reusable patterns into ~/.claude/
allowed-tools: Read, Write, Edit, Bash, Glob
---

# Extract and Save

Master skill that analyzes a conversation and automatically extracts all patterns into your system-wide configuration.

## How It Works

When you ask to extract and save:

1. **Scan the conversation** for extractable patterns
2. **Categorize** each pattern (skill, rule, subagent, hook, memory)
3. **Create files** in appropriate `~/.claude/` locations
4. **Report** what was extracted and where
5. **Suggest usage** in future projects

## What I Look For

### Skills (Repeating Workflows)
Signals:
- Same decision-making process used multiple times
- "I always do X when Y"
- Workflow with clear steps
- Can be applied in other projects

### Rules (Path-Specific Requirements)
Signals:
- "In [directory], I always..."
- "For [file type], requirement is..."
- Requirement applies to a subset of files
- Same constraint in different contexts

### Subagents (Specialist Expertise)
Signals:
- "Have the [role] review this"
- Task needs specific tools or perspective
- Same specialist role appears 2+ times
- Delegation to expertise

### Hooks (Automated Validation)
Signals:
- "I wish this would automatically..."
- Manual check repeated multiple times
- "I always do X after doing Y"
- Validation/formatting that's repetitive

### Memory (Personal Principles)
Signals:
- "I believe...", "I prefer...", "I always..."
- Personal philosophy or principle
- Applies to all projects
- Value or tradeoff decision

## Prioritization

**High Priority** (extract these):
- User explicitly asks for extraction
- Same workflow appears 3+ times in conversation
- Personal principle stated 2+ times
- User expresses frustration with manual task

**Medium Priority** (suggest these):
- New workflow discovered
- Principle stated once but clearly important
- Path-specific requirement identified

**Low Priority** (probably skip):
- One-off solutions
- Temporary workarounds
- Project-specific quirks
- Edge cases

## Extraction Criteria

Only extract if:
1. ✓ It's actually reusable (appears in multiple contexts or clearly would be)
2. ✓ It has a clear name and purpose
3. ✓ It's not redundant with existing skills/rules
4. ✓ It's well-documented enough to use later

Don't extract if:
1. ✗ It's a one-time solution for this project
2. ✗ It's too specific (not generalizable)
3. ✗ It would just replicate existing skills
4. ✗ Documentation would be unclear

## Output Format

```
## Extraction Summary

Total patterns identified: X
Extracted: Y
Skipped: Z

---

### ✓ Extracted: Skills (Y/Z)

1. **python-async-patterns**
   Location: ~/.claude/skills/python-async-patterns/SKILL.md
   Based on: [lines from conversation]
   Use in future: /python-async-patterns

### ✓ Extracted: Rules (Y/Z)

1. **typescript-services**
   Location: ~/.claude/rules/typescript-services.md
   Applies to: services/**/*.ts
   Based on: [conversation context]

### ✓ Extracted: Subagents (Y/Z)

1. **code-reviewer**
   Location: ~/.claude/agents/code-reviewer/
   Memory: ~/.claude/agent-memory/code-reviewer/MEMORY.md
   Use in future: Have the code-reviewer review this

### ✓ Extracted: Hooks (Y/Z)

1. **auto-format-python**
   Location: ~/.claude/settings.json
   Trigger: PostToolUse on .py files
   Action: black --quiet

### ✓ Extracted: Memory (Y/Z)

1. **Personal principle: Prefer simplicity**
   Location: ~/.claude/CLAUDE.md
   Section: Core Philosophy > Code Clarity Over Cleverness

---

### ⊘ Skipped Patterns (Could extract later)

1. "How to choose between Redis and in-memory cache"
   Reason: Too context-specific, only mentioned in this project

2. "Error message formatting"
   Reason: Covered by existing backend-standards rule

---

## Next Steps

These extractions are now available across all projects:
- Run `/python-async-patterns` to use the skill
- Rules auto-apply to matching paths in projects
- Delegate with "Have the code-reviewer check this"
- Hooks auto-run on matching files
- Personal philosophy is loaded in all sessions
```

## Execution Steps

1. **Read the full conversation** to understand context
2. **Extract each pattern type** using the appropriate `/extract-as-*` skill
3. **Check for duplicates** against existing `~/.claude/` content
4. **Create files** with Clear names and documentation
5. **Test patterns** if possible (e.g., verify hooks run)
6. **Document** what was extracted and why
7. **Report** the summary to the user

## When to Use This

**Best time**: End of a productive session where you:
- Discovered a new workflow
- Stated preferences or principles
- Solved a recurring problem
- Built something you'd use again

**Invoke with**:
```
/extract-and-save
```

or

```
> Analyze this conversation and extract all patterns to ~/.claude/
```

## Tips

- Run this monthly after multiple projects
- Dedicate a 10-minute session just to extraction
- Review what was extracted — it shows patterns in your thinking
- If something extracted doesn't feel right, you can delete it
- Your ~/.claude/ directory grows as you work — it becomes your personal framework

## Learning Over Time

As you extract more:
1. Your personal framework grows
2. Future sessions start faster (less exploration needed)
3. You recognize patterns earlier
4. Skills/rules become more refined
5. Your Claude Code "knows you" better
