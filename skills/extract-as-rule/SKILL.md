---
name: extract-as-rule
description: Identify a path-specific or file-type-specific requirement and save it as ~/.claude/rules/
allowed-tools: Read, Write, Glob, Bash
---

# Extract as Rule

Rules apply to specific file paths or patterns. Extract when a requirement is NOT universal, but specific to certain directories, file types, or layers.

## 1. Identify the Scope

Rules apply to:
- **Directories**: `services/**/*.ts`, `frontend/components/**/*.tsx`
- **File types**: `*.test.ts`, `*.config.js`, `*.md`
- **Layers**: "API handlers", "utility functions", "tests"
- **Combinations**: `services/**/*.ts` but exclude `**/*.test.ts`

Glob patterns:
- `**/*.ts` — all TypeScript files recursively
- `services/**` — everything under services/
- `!services/**/*.test.ts` — exclude test files
- `{src,lib}/**/*.js` — either src or lib directory

## 2. Extract the Requirement

What must be true for files matching this scope?
- "Must include error handling"
- "Must have JSDoc comments"
- "Must not exceed 200 lines"
- "Must use async/await, not callbacks"

## 3. Name the Rule File

Location: `~/.claude/rules/<topic>.md`

Good names:
- `typescript-services.md` — rules for service files
- `python-conventions.md` — Python-specific standards
- `test-requirements.md` — testing standards
- `security-guidelines.md` — security requirements

## 4. Create the Rule File

Template:
```markdown
---
paths:
  - "services/**/*.ts"
  - "!services/**/*.test.ts"
---

# Backend Service Standards

These rules apply to all service TypeScript files.

## Error Handling
[requirement and why]

## Logging
[requirement and why]

## Type Safety
[requirement and why]

## Documentation
[requirement and why]
```

## 5. Multiple Rules in One File

You can group related rules:

```markdown
---
paths:
  - "services/**/*.ts"
  - "lib/**/*.ts"
---

# TypeScript Standards (Services & Lib)

## Error Handling
...

## Testing
...
```

Or create separate files by concern:

```
~/.claude/rules/
├── typescript-services.md
├── python-testing.md
├── documentation.md
└── security.md
```

## 6. Reference in Projects

In your project's `.claude/CLAUDE.md`:
```markdown
## Project Rules

See @~/.claude/rules/typescript-services.md for backend standards.
```

## Example Output

```
✓ Created rule: ~/.claude/rules/backend-standards.md
Applies to: services/**/*.ts

I'll apply this rule when reviewing code in those paths.
In projects, reference it with: @~/.claude/rules/backend-standards.md
```

## Common Rule Categories

- **Language conventions** (TypeScript, Python, JavaScript patterns)
- **Layer-specific requirements** (API handlers, utilities, tests)
- **Quality standards** (line length, complexity, documentation)
- **Security requirements** (input validation, error handling)
- **Testing standards** (coverage requirements, test patterns)
- **Documentation** (what each layer should document)
