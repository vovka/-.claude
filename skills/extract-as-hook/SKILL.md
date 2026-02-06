---
name: extract-as-hook
description: Identify repetitive validation/formatting and automate it via hooks in settings.json
allowed-tools: Read, Write, Bash, Glob
---

# Extract as Hook

Hooks automate actions on events (edit, save, permission, etc.).

## 1. Detection Signals

Extract a hook when:
- You repeatedly do the same check/format manually
- You say "I wish this would automatically..."
- Same validation appears in multiple sessions
- Pattern: "After I do X, I always do Y"
- Examples:
  - "I always run prettier after editing"
  - "I always run tests before committing"
  - "I always check this file isn't edited"

## 2. Identify the Trigger Event

Hooks fire on these events:

**File Operations:**
- `PostToolUse` — after editing/writing files
- `PreToolUse` — before certain operations

**Session Events:**
- `UserPromptSubmit` — on every user message
- `SessionStart` — when session begins
- `SessionEnd` — when session ends

**Permission Events:**
- `PermissionRequest` — when permission needed
- `PostToolUseFailure` — when tool fails

**Other:**
- `PreCompact` — before context compaction
- `Notification` — when notification happens

## 3. Identify the Action Type

Hooks can do:

**Command hooks** — run shell commands
```json
{
  "type": "command",
  "command": "black $EDITED_FILE"
}
```

**Prompt hooks** — Claude makes yes/no decision
```json
{
  "type": "prompt",
  "prompt": "Should I run tests?"
}
```

**Agent hooks** — subagent does something
```json
{
  "type": "agent",
  "agent": "code-reviewer"
}
```

## 4. Define Scope

Choose where hook applies:

**System-wide** (all projects):
```
~/.claude/settings.json
```

**Project-specific**:
```
.claude/settings.json
```

**Local only** (gitignored):
```
.claude/settings.local.json
```

## 5. Write the Hook

Template:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit.*\\.py",
        "hooks": [
          {
            "type": "command",
            "command": "black $EDITED_FILE 2>/dev/null && echo '✓ Auto-formatted'"
          }
        ]
      }
    ]
  }
}
```

**Components:**
- `matcher` — regex pattern (which files/tools trigger this?)
- `command` — shell command to run
- `type` — "command", "prompt", or "agent"

## 6. Environment Variables

Available in hook commands:
- `$EDITED_FILE` — path of file being edited
- `$TOOL_NAME` — which tool was used
- `$EXIT_CODE` — if tool failed
- `$CLAUDE_SESSION_ID` — current session ID

Example:
```json
{
  "command": "echo 'Edited: $EDITED_FILE' && npx eslint --fix '$EDITED_FILE'"
}
```

## 7. Test the Hook

After creating:
1. Trigger the event (edit a matching file)
2. Verify the hook runs
3. Check the action completed
4. Adjust command/matcher if needed

## Common Hooks to Create

### Auto-Format on Edit
```json
{
  "PostToolUse": [
    {
      "matcher": "Edit.*\\.py",
      "hooks": [{
        "type": "command",
        "command": "black '$EDITED_FILE' --quiet 2>/dev/null || true"
      }]
    }
  ]
}
```

### Lint on Write
```json
{
  "PostToolUse": [
    {
      "matcher": "Write.*\\.ts",
      "hooks": [{
        "type": "command",
        "command": "npx eslint --fix '$EDITED_FILE' 2>/dev/null || true"
      }]
    }
  ]
}
```

### Validate JSON
```json
{
  "PostToolUse": [
    {
      "matcher": "Write.*\\.json",
      "hooks": [{
        "type": "command",
        "command": "python -m json.tool '$EDITED_FILE' > /dev/null && echo '✓ Valid JSON'"
      }]
    }
  ]
}
```

### Protect Critical Files
```json
{
  "PreToolUse": [
    {
      "matcher": "Edit.*(\\.env|secrets|credentials|private_key)",
      "hooks": [{
        "type": "prompt",
        "prompt": "About to edit a sensitive file. Continue?"
      }]
    }
  ]
}
```

### Run Tests Before Commit
```json
{
  "UserPromptSubmit": [
    {
      "matcher": "commit",
      "hooks": [{
        "type": "command",
        "command": "npm test 2>&1 | head -20"
      }]
    }
  ]
}
```

## 8. Hook File Structure

Create/update `settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "pattern1",
        "hooks": [action1, action2, ...]
      },
      {
        "matcher": "pattern2",
        "hooks": [action3, ...]
      }
    ],
    "PreToolUse": [
      ...
    ]
  }
}
```

## Example Output

```
✓ Hook created: ~/.claude/settings.json
Trigger: PostToolUse on .py files
Action: Auto-format with black

From now on:
1. You edit a Python file
2. I automatically run: black $EDITED_FILE
3. You get formatted code without asking
```

## Tips

- **Keep commands fast** (users notice delays)
- **Suppress output** with `2>/dev/null || true`
- **Use exit code 2** in commands to block the action
- **Test hooks locally first** before making system-wide
- **Document why** in comments if hook is non-obvious
