# Personal Claude Code Configuration Guide

## My Philosophy

### Core Principles: Code for Humans

I write code for **humans to read**, not machines to execute. This means I prioritize modularity, clarity, and maintainability over everything else.

---

### Universal Code Standards

These rules apply to **every language, every framework, every project** unless explicitly overridden.

#### 1. Keep Files Small (≤ 100 lines max)

**Rule**: No file should exceed 100 lines of code.

**Why**:
- A 100-line file fits on one screen (mostly)
- Easier to understand the entire file at once
- Forces you to think about single responsibility
- Makes testing easier (small modules are simpler to test)
- Reduces merge conflicts (smaller files = fewer conflicts)

**How to implement**:
- One class per file
- Break large utilities into focused modules
- Split long scripts into logical functions/imports
- Create a new file when you hit ~80 lines (allows headroom)

**Example**:
```python
# Good: 45 lines, focused on one thing
class UserValidator:
    def validate_email(self, email: str) -> bool: ...
    def validate_password(self, pwd: str) -> bool: ...
    def validate_age(self, age: int) -> bool: ...

# Bad: 250 lines with Users, Orders, Products, Invoices all mixed in
class Entity:
    def validate_user(...): ...
    def validate_order(...): ...
    def process_invoice(...): ...
    def calculate_shipping(...): ...
```

---

#### 2. Keep Functions Small (≤ 10 lines max)

**Rule**: No function or method should exceed 10 lines of code.

**Why**:
- Functions should do ONE thing (SRP)
- Easy to understand what it does by reading it
- Easy to test (one assertion often suffices)
- Easy to reuse (small, focused functions are more reusable)
- Forces descriptive naming (can't be vague with 10-line functions)

**How to implement**:
- Extract helper functions aggressively
- Use early returns to reduce nesting
- Move complex logic into separate functions
- Name extraction functions descriptively (the name *is* the documentation)

**Example**:
```python
# Good: 10 lines, each function has one clear job
class Order:
    def calculate_total(self) -> float:
        subtotal = self._sum_items()
        tax = self._calculate_tax(subtotal)
        shipping = self._get_shipping_cost()
        return subtotal + tax + shipping

    def _sum_items(self) -> float:
        return sum(item.price for item in self.items)

    def _calculate_tax(self, amount: float) -> float:
        return amount * 0.08

# Bad: 25 lines, does 4 things at once
class Order:
    def calculate_total(self) -> float:
        subtotal = 0
        for item in self.items:
            subtotal += item.price
        tax = subtotal * 0.08
        state = self.shipping_address.state
        shipping = 5.00 if state in ['CA', 'NY'] else 10.00
        if subtotal > 100:
            shipping *= 0.5
        return subtotal + tax + shipping
```

---

#### 3. Keep Lines Short (≤ 120 characters)

**Rule**: No line should exceed 120 characters.

**Why**:
- Readable on standard terminals and code review tools
- Reduces horizontal scrolling (kills code review experience)
- Forces thoughtful variable naming (long lines often mean unclear names)
- Better for split-screen editors
- Easier to diff and compare

**How to implement**:
- Break long function calls across lines
- Extract intermediate variables for clarity
- Use meaningful variable names (not `x`, `val`, `temp`)
- Line wrap method chains

**Example**:
```python
# Good: 120 chars, readable
def send_notification(
    user_id: int,
    message: str,
    priority: NotificationPriority = NotificationPriority.NORMAL
) -> bool:
    notification = Notification(user_id, message, priority)
    return notification.send()

# Bad: 150+ chars, requires scrolling
def send_notification(user_id: int, message: str, priority: NotificationPriority = NotificationPriority.NORMAL) -> bool: return Notification(user_id, message, priority).send()
```

---

#### 4. Use OOP by Default (Unless Otherwise Specified)

**Rule**: Write code in Object-Oriented Programming style as the default approach.

**Why**:
- Organizes code around real-world concepts (objects, entities)
- Enables encapsulation (hide internal complexity, expose clean interface)
- Supports code reuse (inheritance, composition)
- Scales well (OOP grows better than procedural)
- Natural modeling of domain concepts

**How to implement**:
- Model entities as classes
- Keep state and behavior together
- Use inheritance/composition for code reuse
- Encapsulate with access modifiers
- Follow SOLID principles

**Example**:
```python
# Good: Models domain concepts
class ShoppingCart:
    def __init__(self):
        self.items: List[CartItem] = []

    def add_item(self, item: Product, quantity: int) -> None:
        self.items.append(CartItem(item, quantity))

    def get_total(self) -> float:
        return sum(item.subtotal() for item in self.items)

# Okay but not preferred: Procedural approach
def add_item_to_cart(cart: dict, product: dict, qty: int) -> dict:
    cart['items'].append({'product': product, 'qty': qty})
    return cart

def get_cart_total(cart: dict) -> float:
    return sum(item['product']['price'] * item['qty']
               for item in cart['items'])
```

---

#### 5. One Class Per File

**Rule**: Each class gets its own file.

**Why**:
- Enforces single responsibility (one class = one job)
- Easy to find code (filename = class name)
- Prevents circular dependencies
- Natural file organization
- Makes files stay under 100 lines
- Easier to navigate large projects

**How to implement**:
- File name = class name (e.g., `User.py`, `UserValidator.ts`)
- Helper utilities/functions go in a separate `utils/` or `helpers/` file
- Use imports to connect classes

**Example**:
```
src/
├── User.py              # Contains only class User
├── UserValidator.py     # Contains only class UserValidator
├── Order.py             # Contains only class Order
├── utils/
│   ├── date_helpers.py  # Helper functions
│   └── formatting.py    # Formatting utilities
└── __init__.py
```

---

#### 6. Code is for Humans: Be Modular & DRY

**Rule**: Write modular code, don't repeat yourself. Optimize for human understanding.

**Why**:
- Code is read 10x more than it's written
- Future you won't remember why you did it this way
- Bugs hide in duplicated code
- Modularity enables reuse and testing

**How to implement**:

**Modularity**:
- Each function/class has one responsibility
- Small, focused units are easier to understand
- Less coupling (change one thing, don't break others)

**DRY (Don't Repeat Yourself)**:
- If you write similar code twice, extract it to a function
- If you copy-paste, that's a code smell
- Shared logic should live in one place
- Use inheritance/composition to share behavior

**Clarity**:
- Use clear, descriptive names (function names should explain what they do)
- Add comments explaining *why*, not *what*
- Keep functions small enough to understand at a glance

**Example**:
```python
# Good: Modular, DRY, clear
class EmailNotifier:
    def send_welcome_email(self, user: User) -> bool:
        return self._send_templated_email(
            user.email,
            "welcome",
            {"name": user.name}
        )

    def send_password_reset(self, user: User, token: str) -> bool:
        return self._send_templated_email(
            user.email,
            "password_reset",
            {"token": token, "name": user.name}
        )

    def _send_templated_email(
        self,
        recipient: str,
        template: str,
        context: dict
    ) -> bool:
        """Send templated email (single responsibility)."""
        email_body = self.template_engine.render(template, context)
        return self.smtp_client.send(recipient, email_body)

# Bad: Repetitive, not modular
def send_welcome_email(user_email: str, user_name: str) -> bool:
    template = load_template("welcome")
    body = template.replace("{{name}}", user_name)
    return send_smtp(user_email, body)

def send_password_reset(user_email: str, token: str, user_name: str) -> bool:
    template = load_template("password_reset")
    body = template.replace("{{token}}", token)
    body = body.replace("{{name}}", user_name)
    return send_smtp(user_email, body)

# ❌ Repeated: template loading, email sending, name substitution
```

---

### Enforcement

These standards are **universal** and should be applied everywhere. When reviewing code or building new features:

- ✅ Every file: check line count (should be < 100)
- ✅ Every function: check it's focused and short (< 10 lines)
- ✅ Every line: ensure it's readable (< 120 chars)
- ✅ Architecture: default to OOP unless there's a good reason not to
- ✅ Organization: one class per file
- ✅ Code quality: no duplication, modular design

**Related extraction tools**:
- Can become a rule: `/extract-as-rule universal-code-standards`
- Can create a hook to validate: `/extract-as-hook code-length-check`
- Can inspire a code review skill: `/extract-as-subagent code-reviewer`

---

## Knowledge Retention: Auto-Document Feature Exploration

### The Problem

**Current workflow (token waste)**:
1. Session 1: "Add feature X" → Claude explores codebase to understand area → makes changes
2. Session 2: "Modify feature X" → Claude re-explores same codebase from scratch → makes changes
3. Result: Same exploration repeated, tokens wasted, context duplicated

### The Solution

**After any codebase exploration, document what you learned** about the area you explored.

**When I explore a codebase area to make changes, I will automatically**:

1. **Understand what I learned** — What feature/component did I just explore?
2. **Capture the structure** — Key files, directories, architecture patterns
3. **Document the feature** — Create a `docs/features/<feature-name>.md` file
4. **Save for future sessions** — Next time you ask about this feature, I read the docs instead of re-exploring

### Documentation Structure

Each feature gets its own file: `docs/features/<feature-name>.md`

**Template**:
```markdown
# [Feature Name]

## Overview
Brief one-liner of what this feature does.

## Purpose
Why does this feature exist? What problem does it solve?

## Key Files & Structure
- `src/path/to/Feature.ts` — Main feature class/module
- `src/path/to/SubComponent.ts` — Supporting component
- `tests/Feature.test.ts` — Tests
- `config/feature.config.json` — Configuration

## Core Concepts

### [Concept 1: e.g., "Authentication Flow"]
Explanation of how this concept works:
- Key classes involved
- Main entry points
- Important patterns

### [Concept 2]
...

## How It Works

### [Process 1]
Step-by-step explanation of what happens when [scenario].

```
[Pseudocode or flow diagram if helpful]
```

### [Process 2]
...

## Important Patterns & Conventions

- **Pattern 1**: When you modify this feature, always do X (because Y)
- **Pattern 2**: This feature uses [library/pattern], key thing to remember
- **Common mistake**: [gotcha], here's how to avoid it

## Integration Points

How does this feature interact with other parts of the system?
- Depends on: [other features]
- Used by: [features that use this]
- Events published: [if any]
- APIs consumed: [if any]

## Configuration & Customization

Where configuration lives and what can be customized.

## Testing Strategy

How is this feature tested?
- Unit tests in: [location]
- Integration tests in: [location]
- Key test scenarios: [list]

## Future Improvements / Known Issues

- Issue 1 and why it exists
- Potential optimization: [idea]

---

**Last updated**: [date]
**Updated by**: Claude
**Exploration depth**: Basic / Moderate / Deep
```

### Activation

This happens **automatically**:

1. **During exploration**: When I Grep, Read, and Glob across multiple files to understand a feature
2. **After changes**: When I've modified code in that area
3. **At natural pause**: When task is complete or I'm context-switching

**You can also explicitly trigger**:
```
/document-feature-exploration <feature-name>
```

### Workflow Example

**Session 1**:
```
You: "Add OAuth2 authentication to the API"

Claude: [explores auth-related files]
        [makes changes]
        [detects I explored "Authentication" feature]

✓ Created: docs/features/authentication.md
  This documentation will be used in future sessions
  to avoid re-exploring the auth system.
```

**Session 2** (different day, same project):
```
You: "Make OAuth tokens work with refresh"

Claude: [reads docs/features/authentication.md first]
        [understands existing structure from docs]
        [makes changes with context]

✓ Skipped re-exploration, used existing docs
  Saved ~20 Grep/Read calls
```

### Documentation Location

**Recommended structure**:
```
docs/
├── features/
│   ├── authentication.md
│   ├── payment-processing.md
│   ├── etsy-integration.md
│   ├── image-generation.md
│   └── analytics.md
├── architecture/
│   └── [existing architecture docs]
├── api/
│   └── [existing API docs]
└── README.md
```

One file per feature, organized by concern.

### When NOT to Document

Skip documentation if:
- ❌ You explored a tiny section (< 3 files read)
- ❌ It's already well-documented in code
- ❌ You're just fixing a typo or one-liner

Do document if:
- ✅ You explored multiple files to understand flow
- ✅ The feature has multiple components
- ✅ You made non-trivial changes
- ✅ Someone might work on this feature again

### Benefits

- **Faster iterations** — No more re-exploration tax
- **Lower context cost** — Read docs instead of reading files
- **Knowledge capture** — What you learned is preserved
- **Onboarding** — New team members/future you can understand features
- **Search optimization** — Can grep docs instead of source when possible

### Related skill

Use `/document-feature-exploration` to manually document a feature you just explored.

---

## AUTOMATIC PATTERN EXTRACTION

**I observe conversations for extractable knowledge.** When I notice something that could become reusable across projects, I will hint that extraction is possible.

### What Makes Something Extractable?

#### Skills (Repeating Workflows)
**Extract when:**
- You repeatedly use the same decision-making process
- A workflow appears in multiple contexts
- You describe a "way you like to do X"
- Example: "I always research X by doing [steps]"

**Hint format:**
```
This research approach could be extracted as `/research` skill —
would you like me to save it to ~/.claude/skills/research/?
```

#### Rules (Path/File-Type Standards)
**Extract when:**
- A requirement applies only to certain files/paths
- You say "in TypeScript files, I always..." or "for services, we..."
- Same constraint mentioned for backend/ vs frontend/
- Example: "error handling is required in all service handlers"

**Hint format:**
```
I noticed "error handling in services" is a path-specific requirement.
This could become a rule in ~/.claude/rules/backend-standards.md
```

#### Subagents (Specialized Knowledge)
**Extract when:**
- You delegate to a "specialist" mindset
- A task needs specific tools or different judgment
- You say "review this as a [role]"
- Example: "have the security expert check this"

**Hint format:**
```
You're delegating to specialized expertise (security review).
This could become a ~/.claude/agents/security-reviewer/ subagent.
```

#### Hooks (Automated Validation)
**Extract when:**
- You mention wanting automatic enforcement
- Same manual check repeated (linting, formatting, file protection)
- You say "I wish this would automatically..."
- Example: "I always run prettier after editing"

**Hint format:**
```
The "auto-format on save" need could be a hook in .claude/settings.json
```

#### Memory (Personal Principles)
**Extract when:**
- You express a personal preference or philosophy
- A decision rule applies to all your projects
- You say "I always...", "I prefer...", "I believe in..."
- Example: "I value simplicity over features"

**Hint format:**
```
Your principle "prefer simple over complex" belongs in ~/.claude/CLAUDE.md
```

### When to Suggest Extraction

I will hint at these natural pause points:
- After completing a task
- When I recognize a pattern from earlier in the conversation
- When you state a preference explicitly
- At session end, summarizing what we learned
- When the same workflow appears 2+ times in a session

### How You Can Trigger Extraction

You can explicitly ask:
- `/extract-as-skill <topic>` — save a workflow as a skill
- `/extract-as-rule <topic>` — save a path-specific requirement
- `/extract-as-subagent <role>` — create a specialized agent
- `/extract-as-hook <action>` — automate validation/formatting
- `/extract-as-memory <principle>` — save a personal principle
- `/extract-and-save` — let me analyze the conversation and extract all patterns

---

## Rules for Extraction

1. **Don't over-extract**: A one-off approach isn't reusable
2. **Name clearly**: Skill/rule names should be self-documenting
3. **Include context**: Document *why*, not just *what*
4. **Keep it single-purpose**: One skill = one approach
5. **Version personal opinions**: Mark preferences with "I prefer..." so they're adjustable
