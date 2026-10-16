---
name: project-handoff
description: Hand the current conversation's summary to a fresh coding agent in a project. Runs the project-agent steps (find or create the project, workspace and tab, start an agent), then sends a summary and tells the agent to wait for instructions. Use for "move this to a new workspace/agent", "hand off to project X", "continue this in <project>".
---

# Project handoff

Same options and backends as `project-agent` (defaults: workspace manager `herdr`, agent `claude`;
overridable by the user, e.g. "with codex", "in paseo").

## Steps

1. Run the `project-agent` steps for the target project. If the user gave none, derive a name from
   the current work and confirm it. Move any files this conversation created that belong to the project into
   its directory first.
2. Write the summary to a file in the session scratchpad directory, then send it with the backend's *send prompt*.
3. Report project, workspace, agent. Do not continue the work yourself.

## Summary contents

Self-contained, because the agent has none of this conversation:
- one-line project goal;
- verified findings (facts, config, ids), and what is unverified;
- files that exist and how to run them;
- constraints (never ask for secrets in chat; confirm before irreversible actions);
- the last line, exactly: `Do NOT act yet. Wait for further instructions.`

Leave out chat history, dead ends and secrets.
