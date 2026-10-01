# Documentation-Driven Development (DDD)

This project follows a **Documentation-Driven Development** approach where the documentation is the source of truth for all changes.

## Two-Document System

### 1. doc/specification.md - The "What"
Describes **what** the application should do from the user's perspective. Defines features, user workflows, and expected behavior.

### 2. doc/architecture.md - The "How"
Describes **how** things should be implemented at a high level. Includes technical architecture, design patterns, technology choices, and deployment strategies.

**Important**: The architecture is intentionally high-level. Precise implementation details are discovered during feature development.

## Understanding User Intent

**CRITICAL**: You must distinguish between two types of user requests:

### Type 1: User wants to PLAN a change (modify documentation)
**Indicators**:
- User describes a new feature or change they want
- User is brainstorming or designing
- User hasn't mentioned existing documentation changes
- User says things like "I want to add...", "Let's create...", "We should implement..."

**Your action**: Help update `doc/specification.md` and/or `doc/architecture.md` to reflect the planned changes.

### Type 2: User wants to IMPLEMENT existing changes (write code)
**Indicators**:
- User says "implement the changes", "code what's in the docs", "follow the documentation"
- User references recent documentation updates
- Documentation files have uncommitted changes or recent commits

**Your action**: Check for documentation changes (uncommitted → main branch diff → remote diff) and implement what's specified there.

## Workflow for AI Agents

**These documentation files are the source of truth. All changes start by modifying these files.**

When a user makes a request:

1. **First, determine user intent**: Are they planning (documentation update) or implementing (code changes)?

2. **If PLANNING** (Type 1):
   - Collaborate with the user to update `doc/specification.md` and/or `doc/architecture.md`
   - Ensure the changes are clearly documented
   - Ask clarifying questions to make the documentation complete

3. **If IMPLEMENTING** (Type 2):
   - Check for documentation changes in this order:
     a. Uncommitted changes to `doc/specification.md` and `doc/architecture.md`
     b. Diff these files against the local `main` branch
     c. Diff these files against the remote branch
   - The diff reveals what needs to be implemented
   - Use the documentation as your guide, discovering precise implementation details by reading the codebase
   - Keep docs and code in sync: If implementation differs from docs, update the docs (or adjust implementation)

## What to Include in Architecture

**DO include** high-level technical decisions that guide implementation:
- Custom authorization approach
- System interaction diagrams and sequential flow charts
- Integration patterns
- Technology choices and rationale
- Deployment architecture and infrastructure decisions

**DO NOT include** low-level details that can be discovered from code:
- Code style conventions (snake_case vs camelCase, indentation, etc.)
- Specific variable names or function signatures
- File organization within modules (unless it's a critical architectural pattern)
- Import statement formats or module resolution details

**Rule of thumb**: If it's a decision that affects how future features should be built, include it. If it's a detail that naturally emerges from reading the existing code, omit it.

---

**Remember: Determine user intent first, then either plan (update docs) or implement (write code based on docs)!**
