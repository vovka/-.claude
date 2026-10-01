---
name: remind-session
description: Give a brief reminder of the current session in 1-3 simple sentences. Use when you want a quick recap or to rename the session.
allowed-tools: None (analysis only)
---

# Remind Session

Give a quick reminder of what you and I were working on in this session.

## When to Use This

- You ask: "What were we working on?"
- You want a brief recap before context-switching
- You want to rename the session with a suggested name
- You need a one-sentence summary of the session focus

## Core Workflow

### Step 1: Identify the Main Task
What is the primary thing we've been working on? Focus on the top-level goal, not every detail.

### Step 2: Summarize in 1 Sentence
Write one clear, simple sentence that captures it. Keep it under 15 words if possible.
- Example: "Adding OAuth2 authentication to the API."
- Example: "Fixing the checkout page bug."

### Step 3: Add Context Only If Needed
If one sentence isn't enough, add 1-2 more short, simple sentences. But try to stay at 1 sentence.

### Step 4: Suggest a Session Name
End with `/rename Suggested name` using a short, concrete name that reflects the work.
- Examples: `/rename Add OAuth`, `/rename Fix checkout`, `/rename Implement caching`

## Rules

- Use 1 simple sentence by default
- Use 2-3 simple sentences only if 1 sentence is clearly not enough
- Keep each sentence short and direct
- Avoid commas, semicolons, or long joined clauses
- Focus on the main thing we worked on
- Do not try to describe every part of the session
- Write like a quick reminder to yourself
- Always end with a `/rename` suggestion

## Examples

**Good:**
```
We're implementing Azure live transcription mode for the recording system.
/rename Add Azure transcription
```

**Good:**
```
We fixed the authentication flow and added refresh token support.
/rename Fix auth refresh tokens
```

**Not ideal (too much detail):**
```
We explored the Azure transcription API, understood how it integrates with the recorder,
implemented the live transcription feature, added error handling, and updated the tests.
/rename Azure transcription
```

## Common Pitfalls

- **Including too much detail** — Focus on the main task, not every file you touched
- **Vague descriptions** — "Working on stuff" isn't helpful. "Fixing the search performance" is better
- **Long sentences** — If your reminder is more than 2 lines, break it up or simplify
- **Forgetting the session rename** — Always end with `/rename` to help organize sessions

## Tips

- Imagine explaining the session to someone in an elevator (15 seconds)
- If you find yourself writing more than 3 sentences, you're probably working on multiple things
- The `/rename` suggestion should match the main task, not every detail
