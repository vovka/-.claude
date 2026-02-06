---
name: extract-as-subagent
description: Identify a specialized expertise area and create ~/.claude/agents/<name>/ subagent
allowed-tools: Read, Write, Glob, Bash
---

# Extract as Subagent

Subagents are specialized AI assistants with their own:
- Restricted toolset (maybe read-only, maybe full)
- Specialized knowledge domain
- Persistent memory
- Different instructions/personality

Extract when you delegate to a "specialist" mindset.

## 1. Detection Signals

Extract a subagent when:
- You say "have the [expert] review..."
- A task needs specific tools or different perspective
- Same specialized role appears multiple times
- You want a focused specialist vs generalist
- Examples:
  - "have the security reviewer check this"
  - "let the code quality bot review the PR"
  - "ask the architect if this scales"

## 2. Name the Specialist

Good names:
- `code-reviewer` — reviews code quality
- `security-auditor` — checks security
- `performance-optimizer` — identifies bottlenecks
- `documentation-specialist` — ensures docs are complete
- `business-analyst` — analyzes business metrics

Bad names:
- `helper`, `bot`, `agent`, `assistant` (too generic)

## 3. Define Their Expertise

What do they know deeply?
- Their domain area
- What patterns they recognize
- What they should focus on
- What they should NOT focus on

Examples:
```
Code Reviewer knows:
- Code quality metrics (complexity, duplication, readability)
- Testing strategies
- Performance anti-patterns
- Common security issues

Security Auditor knows:
- OWASP top 10
- Input validation
- Authentication/authorization patterns
- Encryption and data protection
```

## 4. Choose Their Toolset

Different roles need different tools:

**Read-only reviewers** (for code review, analysis):
```json
"tools": ["Read", "Grep", "Glob"]
```

**Fixers** (can modify code):
```json
"tools": ["Read", "Edit", "Write", "Bash", "Grep"]
```

**Full autonomy** (can do anything):
```json
"tools": ["all"]
```

## 5. Create the Agent Configuration

Location: `~/.claude/agents/<agent-name>/`

Create `claude.json`:
```json
{
  "name": "code-reviewer",
  "description": "Reviews code for quality, security, performance issues",
  "tools": ["Read", "Grep", "Glob"],
  "model": "sonnet",
  "memory": "~/.claude/agent-memory/code-reviewer"
}
```

Configuration options:
- `name` — agent identifier
- `description` — what they do
- `tools` — which tools they can use
- `model` — which Claude model (inherit, sonnet, opus, haiku)
- `memory` — path to persistent memory file

## 6. Create Agent Memory

Location: `~/.claude/agent-memory/<agent-name>/MEMORY.md`

Template:
```markdown
# Code Reviewer Memory

## Expertise
- Code quality metrics and standards
- Testing strategies and coverage
- Performance patterns and anti-patterns
- Common security issues in code

## What to Focus On
- Complexity and maintainability
- Test coverage
- Error handling
- Performance bottlenecks

## What to Ignore
- Style/formatting (separate tool handles that)
- High-level architecture (architecture agent handles that)

## Learning Log
[Track what you learn from reviews]
```

## 7. Usage

Once created, invoke in conversations:
```
> Have the code-reviewer examine this function for quality issues
[subagent loads with its own memory, tools, and expertise]
```

## Example Complete Subagent

```json
{
  "name": "security-auditor",
  "description": "Security audit specialist. Reviews code for vulnerabilities, input validation, authentication, encryption.",
  "tools": ["Read", "Grep", "Glob"],
  "model": "opus",
  "memory": "~/.claude/agent-memory/security-auditor"
}
```

```markdown
# Security Auditor Memory

## Expertise
- OWASP Top 10
- Input validation and sanitization
- Authentication and authorization
- Encryption and secure storage
- SQL injection, XSS, CSRF
- Secure API design

## Checklist When Reviewing Code
1. Is all user input validated?
2. Are secrets hardcoded?
3. Are permissions checked?
4. Is sensitive data logged?
5. Are errors handled securely?
6. Is there rate limiting?
7. Are dependencies up to date?

## Common Issues Found
[Log patterns you discover]
```

## Common Subagents to Create

1. **code-reviewer** — code quality
2. **security-auditor** — security vulnerabilities
3. **performance-optimizer** — bottlenecks and optimization
4. **architecture-reviewer** — system design
5. **testing-specialist** — test coverage and strategy
6. **documentation-specialist** — docs quality
7. **business-analyst** — business metrics and analysis

## Example Output

```
✓ Created subagent: ~/.claude/agents/code-reviewer/
Memory: ~/.claude/agent-memory/code-reviewer/MEMORY.md

You can now delegate to this specialist:
> Have the code-reviewer audit this function
> Ask the code-reviewer about testing strategy
```
