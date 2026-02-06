---
name: plan
description: Break down work into structured plans using your proven TodoWrite/TaskCreate patterns. Choose the right workflow for the task size and complexity.
allowed-tools: TodoWrite, TaskCreate, Read, Bash, Grep
---

# Planning Framework

Based on 119 actual task workflows across your projects, use these proven patterns to break down work effectively.

## Quick Decision: Which Pattern to Use?

```
Is it a small, focused task (< 2 hours)?
├─ Yes → Use Pattern A (Simple Fix - 4 steps)
│
Is it a new feature or enhancement (2-4 hours)?
├─ Yes → Use Pattern B (Feature Implementation - 5 steps)
│
Is it a major refactor or complete rewrite (2-6 hours)?
├─ Yes → Use Pattern C (Comprehensive Refactor - 6 steps)
│
Is it a large system change (> 6 hours, 3+ components)?
└─ Yes → Use TaskCreate (Component Decomposition)
```

---

## Pattern A: Simple Fix (4 Steps) — 26% of your workflows

**Best for**: Bug fixes, quick updates, small corrections
**Duration**: 30 min to 2 hours
**Your most practical pattern for daily work**

### Steps

```
[ ] Read: Understand the issue and locate relevant code
[ ] Fix: Make the minimal necessary change
[ ] Test: Verify the fix works
[ ] Verify: Check for side effects or related issues
```

### When to Use
- Fixing a bug in existing code
- Small config updates
- One-file changes
- Quick performance tweaks

### Example TodoWrite Output
```
Task: Fix encryption bug in firmware

- [ ] Read: Understand how password validation works
- [ ] Fix: Update hash algorithm in auth module
- [ ] Test: Verify passwords work with new hash
- [ ] Verify: Check backwards compatibility
```

---

## Pattern B: Feature Implementation (5 Steps) — 21% of your workflows

**Best for**: New features, enhancements, adding functionality
**Duration**: 1-4 hours
**Sweet spot for feature-sized work**

### Steps

```
[ ] Understand: Research existing code and requirements
[ ] Plan: Design the implementation approach
[ ] Implement: Write the core feature
[ ] Integrate: Connect to the rest of the system
[ ] Test: Verify feature works end-to-end
```

### When to Use
- Adding a new feature
- Implementing an enhancement
- Building a new component
- Adding new functionality to existing system

### Example TodoWrite Output
```
Task: Add font scaling feature for keycodes

- [ ] Understand: See how font sizes are currently handled
- [ ] Plan: Decide on scaling algorithm and config structure
- [ ] Implement: Write font scaling logic
- [ ] Integrate: Connect to UI and serialization
- [ ] Test: Verify scaling works across all keycode types
```

---

## Pattern C: Comprehensive Refactor (6 Steps) — 28% of your workflows

**Best for**: Major refactoring, rewrites, system changes
**Duration**: 2-6 hours
**Your most frequently used pattern**

### Steps

```
[ ] Read: Understand current implementation
[ ] Analyze: Identify what needs to change and why
[ ] Plan: Design the new structure
[ ] Implement: Rewrite/refactor the code
[ ] Update: Update related code/tests/docs
[ ] Verify: Test and check nothing broke
```

### When to Use
- Major refactoring of existing code
- Rewriting a component
- Restructuring how something works
- Performance optimization
- Code quality improvements

### Example TodoWrite Output
```
Task: Refactor LED matrix lookup system

- [ ] Read: Understand current matrix lookup algorithm
- [ ] Analyze: Identify performance issues and design problems
- [ ] Plan: Design new lookup strategy
- [ ] Implement: Rewrite lookup code with new approach
- [ ] Update: Update related code, tests, documentation
- [ ] Verify: Run all tests, benchmark performance, check edge cases
```

---

## Pattern D: TaskCreate for Large Systems (Emerging Pattern)

**Best for**: Large features (> 6 hours), multiple files/components
**Use when**: 3+ related tasks needed, multiple sessions
**Your pattern for complex architectural work**

### When to Use TaskCreate Instead of TodoWrite

Create multiple persistent tasks when:
- Feature spans multiple files/components
- Multiple team members could work on it
- Work spans multiple sessions
- Each component has clear dependencies

### Example TaskCreate Structure

```
Task 1: Add LED matrix enum
Task 2: Create color classification logic
Task 3: Build color assignment system
Task 4: Implement renderers for each color
Task 5: Integrate with serialization
Task 6: Test end-to-end
```

Each task can be worked on separately, tracked across sessions, and has clear dependencies.

---

## How to Invoke This Pattern

When planning work, you can ask:

```
/plan "Add user authentication to the API"
```

Or describe the work:

```
> I need to refactor the payment system

[Claude recognizes this as Pattern C: Comprehensive Refactor]
Claude creates the 6-step TodoWrite
```

---

## Pattern Selection by Project Type

**Firmware Projects (qmk)**:
- Mostly Pattern C (comprehensive refactor) - 73 tasks
- Fast, iterative development cycle
- Each fix often requires understanding broader system

**GUI Projects (vial-gui)**:
- Mostly TaskCreate for component architecture
- Multiple components created in sequence
- Clear separation of concerns

**Business Projects (etsy-ai-images)**:
- Pattern B (feature implementation) preferred
- Add research/planning step upfront
- Multi-step workflows with strategy + execution

**Voice Projects (talon)**:
- Pattern A (simple fix) most common
- Quick integrations
- 30 min to 2 hour cycles

---

## Tips for Using Patterns Effectively

### 1. Be Specific with Step Descriptions
```
Bad:  [ ] Fix it
Good: [ ] Fix: Update hash validation to use bcrypt instead of MD5
```

### 2. Adjust Patterns to Your Context
Start with the base pattern, then add or combine steps:
```
Pattern B + research step:
- [ ] Research: Understand how other systems do this
- [ ] Understand: See current implementation
- [ ] Plan: Design approach
- [ ] Implement: Write code
- [ ] Integrate: Connect to system
- [ ] Test: Verify
```

### 3. Update in Real-Time
As you work, check off steps as you complete them. Patterns help organize work, not constrain it.

### 4. Know When to Switch
If Pattern A (simple fix) becomes 10 steps, switch to Pattern C (refactor). If Pattern C becomes 3+ files, consider TaskCreate.

---

## Decision Flowchart Example

```
User: "We need to support dynamic keyboard layouts"

Claude evaluates:
- New feature? Yes → Pattern B (Feature Implementation)
- Spans multiple files? Yes
- Work > 6 hours? Maybe
- Multiple developers needed? No

Decision: Use Pattern B (5 steps) with optional TaskCreate if reaches 3+ files

Pattern B TodoWrite:
- [ ] Understand: See how layouts are currently loaded
- [ ] Plan: Design dynamic layout system
- [ ] Implement: Write layout loading logic
- [ ] Integrate: Connect to config and UI
- [ ] Test: Verify layouts can be changed dynamically
```

---

## When to Get Help from Extraction Agent

After you finish work using one of these patterns:

```
/extract-and-save

This will:
- Analyze the todo list you created
- Notice patterns in your workflow
- Suggest extracting common approaches as skills
- Document what worked for future reference
```

---

## Your Pattern Statistics

From analysis of 119 actual tasks across your projects:

| Pattern | Frequency | Avg Duration | Best For |
|---------|-----------|--------------|----------|
| **C: Comprehensive Refactor** | 28% | 2-6h | Major changes |
| **A: Simple Fix** | 26% | 30m-2h | Bug fixes |
| **B: Feature Implementation** | 21% | 1-4h | New features |
| **D: TaskCreate** | 12% | 8h+ | Large systems |
| **Other/Custom** | 13% | varies | Context-specific |

This skill encodes your actual, proven workflows. Use the right pattern for the right task.
