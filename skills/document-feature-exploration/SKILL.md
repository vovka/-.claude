---
name: document-feature-exploration
description: After exploring a codebase feature, document what you learned for future reference
allowed-tools: Read, Write, Glob, Grep, Bash
---

# Document Feature Exploration

After exploring a codebase area to understand and modify a feature, create comprehensive documentation so future sessions don't need to re-explore.

## When to Use This

Use this skill when:
- You've read multiple files to understand a feature
- You've made changes to a feature
- You're context-switching after working on a feature
- Someone explicitly asks: `/document-feature-exploration <name>`

**Skip if**:
- You only read 1-2 files
- Changing a one-liner or typo
- Feature is already heavily documented

## How It Works

### Step 1: Identify What You Just Explored

From your recent work, identify the main feature or component:
- What is the core entity/concept? (e.g., "Authentication", "Payment Processing")
- What files did you touch?
- What did you learn about the architecture?

Examples:
- Explored files: `auth/OAuth.ts`, `auth/Session.ts`, `auth/strategies/` → Feature: "Authentication"
- Explored files: `payments/Stripe.ts`, `payments/Invoice.ts`, `payments/webhooks/` → Feature: "Payment Processing"

### Step 2: Check if Documentation Already Exists

Before creating new docs, check:
```bash
ls docs/features/ | grep -i <feature-name>
```

If docs already exist:
- Read them first
- Update them with new information you learned
- Preserve existing content, add/correct where needed

### Step 3: Gather Key Information

From your exploration, capture:

**Structure**:
- Main files/directories for this feature
- Entry points (how is this feature accessed?)
- Dependencies (what does it depend on?)

**Concepts**:
- Key classes/functions
- Important patterns used
- Data flow

**Processes**:
- What happens when [common action]?
- How does [component] interact with [other component]?
- What are the steps?

**Integration**:
- What other features use this?
- What does this feature depend on?
- Events or APIs involved?

**Patterns & Gotchas**:
- Repeated patterns you noticed
- Mistakes to avoid
- Configurations to be aware of

### Step 4: Create/Update Documentation

Create or update: `docs/features/<feature-name>.md`

Use this template:

```markdown
# [Feature Name]

## Overview
One-sentence description of what this feature does and why it exists.

## Key Files
- `path/to/Main.ts` — Primary module (what it does)
- `path/to/Component.ts` — Supporting component
- `tests/Feature.test.ts` — Tests for this feature

## Core Concepts

### [Concept Name]
What is this concept? Why does it matter?
- Related files: `path/to/file`
- Key classes: `ClassName`
- Important: [gotcha or pattern]

## How It Works

### [Common Scenario]
What happens when [user does X / event occurs]?

```
[Flow diagram or pseudocode if helpful]
```

1. [Step 1]
2. [Step 2]
3. [Step 3]

### [Another Scenario]
...

## Important Patterns

- **Pattern**: When modifying this feature, always [do something] because [reason]
- **Convention**: This code uses [pattern name], key thing to remember
- **Gotcha**: Common mistake is [X], avoid by [solution]

## Configuration

Where configuration lives and what can be customized:
- Config file: `path/to/config.json`
- Environment variables: `FEATURE_X`, `FEATURE_Y`
- Runtime options: [class fields, function params, etc.]

## Testing

- Unit tests: `tests/Feature.test.ts`
- Key scenarios to test:
  - [Scenario 1]
  - [Scenario 2]

## Integration Points

- **Used by**: [other features that depend on this]
- **Depends on**: [features this uses]
- **Events**: [if any events are published]

---
**Last updated**: [date]
**Exploration scope**: [small/medium/large]
```

### Step 5: Link the Documentation

In your project's `.claude/CLAUDE.md` (project memory), add:

```markdown
## Project Features Documentation

See `docs/features/` for detailed feature guides:
- Authentication: @docs/features/authentication.md
- Payment Processing: @docs/features/payment-processing.md
- [Feature]: @docs/features/[feature].md
```

This way, future sessions see the docs link immediately.

## Best Practices

**Be specific**:
- ❌ "This feature has some classes and methods"
- ✅ "UserValidator class validates email/password, raises ValidationError on failure"

**Include examples**:
- Show what a happy path looks like
- Show what error cases look like
- Code examples are better than prose

**Link to implementation**:
- Reference actual file paths
- Include class/function names
- Makes it easy to jump to the code

**Mark your learning process**:
- If you had to explore 5 files to understand 1 concept, document that relationship
- It helps others (and future you) skip the exploration

**Date it**:
```markdown
---
**Last updated**: 2025-02-06
**Updated by**: Claude
**Files explored**: 8
**Confidence**: High (touched all main paths)
```

This shows when docs are stale and need refreshing.

## Common Documentation Patterns

### Microservice/API Feature
```markdown
## Endpoints
- `POST /api/feature` — Create
- `GET /api/feature/:id` — Retrieve
- `PUT /api/feature/:id` — Update

## Data Model
- Request schema: [structure]
- Response schema: [structure]
- Error responses: [types]

## Authentication
- Required: [yes/no]
- Type: [OAuth, JWT, etc.]
- Scope: [if applicable]
```

### Business Logic Feature
```markdown
## Business Rules
- Rule 1: [what must be true]
- Rule 2: [constraint]
- Rule 3: [calculation]

## State Machine (if applicable)
- States: [list]
- Transitions: [describe flow]
- Trigger: [what causes change]
```

### Integration Feature
```markdown
## External Service
- Name: [Service name]
- API version: [version]
- Credentials: [how stored]
- Rate limits: [if any]
- Retry strategy: [how handled]

## Error Handling
- Common errors: [list]
- Retry logic: [what retries]
- Fallback: [what happens on failure]
```

## Example: Documenting the Stripe Integration

**After exploring Stripe integration files**:

```markdown
# Payment Processing (Stripe)

## Overview
Handles payment processing, subscription management, and webhook handling for Stripe.

## Key Files
- `services/StripeService.ts` — Main service (create charges, handle subscriptions)
- `webhooks/StripeWebhooks.ts` — Webhook handlers
- `models/Payment.ts` — Payment data model
- `config/stripe.config.ts` — Stripe API keys and configuration

## Core Concepts

### Charges vs Subscriptions
- **Charges**: One-time payments, created with `StripeService.charge()`
- **Subscriptions**: Recurring payments, managed with `StripeService.createSubscription()`
- Related: Customer objects in Stripe represent users

### Webhooks
Stripe calls our webhook endpoint when events occur (payment succeeded, subscription ended, etc.)
- Endpoint: `POST /webhooks/stripe`
- Signature verification: Always verify `stripe-signature` header
- Handled events: `charge.succeeded`, `customer.subscription.deleted`, etc.

## How It Works

### Processing a Payment
1. User submits payment info (card, amount)
2. `StripeService.charge()` calls Stripe API
3. Stripe returns transaction ID
4. We save Payment record in DB with status "completed"
5. Charge succeeds webhook fires (handled separately)

### Handling Webhooks
1. Stripe sends POST to `/webhooks/stripe` with event data
2. We verify signature using `STRIPE_SECRET_KEY`
3. Route to appropriate handler based on event type
4. Handler updates DB (e.g., mark subscription as ended)

## Important Patterns

- **Always verify webhook signatures** — Don't trust webhook data without signature check
- **Idempotent handlers** — Webhooks can be retried; handlers must be idempotent
- **Error handling** — Catch Stripe errors and return proper HTTP status (Stripe expects 200 for success)
- **Logging** — Always log transaction IDs for debugging

## Configuration

- `STRIPE_SECRET_KEY` — API key (environment variable)
- `STRIPE_PUBLISHABLE_KEY` — Public key for frontend
- `STRIPE_WEBHOOK_SECRET` — Webhook signature verification key

## Testing

- Unit tests mock Stripe API calls
- Use Stripe test card numbers: `4242 4242 4242 4242` (success)
- Webhook testing: Use `stripe listen` CLI to forward events to localhost

---
**Last updated**: 2025-02-06
**Files touched**: 4
```

## After Documentation

Once created:
1. ✅ Documentation exists in `docs/features/<name>.md`
2. ✅ Future sessions can read docs instead of re-exploring
3. ✅ Context is preserved for team members
4. ✅ Tokens are saved on next similar task

**Activation**: Next session, when you mention this feature again:
```
> Update the payment feature to support refunds
[Claude reads docs/features/payment-processing.md first]
[Has full context without re-exploration]
```
