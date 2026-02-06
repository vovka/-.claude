---
name: extract-as-skill
description: Take a conversation topic and turn it into a reusable ~/.claude/skills/ entry
disable-model-invocation: false
allowed-tools: Read, Write, Glob, Bash
---

# Extract as Skill

When asked to extract something as a skill, follow these steps:

## 1. Review the Conversation
- Identify the workflow, approach, or process to extract
- Find the core decision-making steps
- Note any variations or edge cases discussed

## 2. Name It Clearly
- Use kebab-case (e.g., `python-optimization`, `code-review`)
- Action-oriented names are best
- Avoid generic names like `thing`, `helper`
- Example good names:
  - `python-async-patterns`
  - `etsy-market-research`
  - `refactor-for-readability`

## 3. Determine When to Use It
- What problem does this solve?
- What's the trigger (e.g., "when optimizing network code")
- What type of projects benefit? (backend, frontend, data, etc.)

## 4. Extract Core Steps
- Break workflow into 3-7 main steps
- Include decision points ("if X, do Y")
- Reference relevant files/docs if applicable
- Show concrete examples from conversation

## 5. Create the SKILL.md File
Location: `~/.claude/skills/<skill-name>/SKILL.md`

Template:
```yaml
---
name: <skill-name>
description: <one-line: what it does and when to use>
allowed-tools: Read, Bash, Grep, Edit, Write, Glob
---

# <Skill Title>

## When to Use This
- Trigger 1
- Trigger 2
- Example: "when optimizing..."

## Core Workflow

### Step 1: [Name]
[Description and rationale]

### Step 2: [Name]
[Description and rationale]

### Step 3: [Name]
[Description and rationale]

## Examples
[Real example from conversation]

## Common Pitfalls
- Mistake 1 and how to avoid it
- Mistake 2 and how to avoid it

## References
- Link to related docs
- Link to other skills
```

## 6. Create Supporting Files (Optional)

If the skill is complex, create:
- `EXAMPLES.md` — detailed real-world examples
- `CHECKLIST.md` — validation steps
- `REFERENCE.md` — deeper technical details
- `TEMPLATES/` — code/template examples

## 7. Test the Skill
- Check that it's clear and actionable
- Verify it works for the context you extracted it from
- Consider if it would work in other projects

## Example Output

```
✓ Created skill: ~/.claude/skills/python-async-optimization/SKILL.md
Description: Design async Python code for I/O-heavy operations

You can now use this in any project:
> /python-async-optimization
or
> Have me optimize this code using the async patterns approach
```
