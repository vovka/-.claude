---
name: project-agent
description: Open a coding agent in a project, found by name or description. Finds the project directory (or creates it), finds the terminal workspace for it (or creates it), opens a new tab there and starts an agent. Use for "open/start an agent in project X", "find project Y and run Claude there", "work on <project> in a new tab".
---

# Project agent

## Options (defaults)

| Option | Default | Other values |
|--------|---------|--------------|
| workspace manager | `herdr` | `paseo` (add `backends/paseo.md`) |
| agent | `claude` | `codex`, or any kind the manager supports |

The user can override either in plain words ("with codex", "in paseo"). Read
`backends/<workspace manager>.md` for the exact commands. If that file does not exist, say so and stop.
Never mix: commands in the backend file are the only manager-specific part of this skill.

## Steps

1. **Find the project directory.** Match the user's name or description against, in order:
   `ls -d ~/dev/*/ ~/dev/*/*/` names, then README/CLAUDE.md first lines of near matches, then the
   manager's known projects/workspaces. One clear match: use it. Several: ask which. None: confirm the name and
   parent (default `~/dev/_utils/<snake_case_name>`), then `mkdir -p` it.
2. **Find the workspace** whose cwd is that directory (backend: *find workspace*). None: create it
   (backend: *create workspace*), labelled with the project name, without stealing focus.
3. **Open a new tab** in that workspace with cwd = project directory (backend: *new tab*).
4. **Start the agent** in the tab's pane (backend: *start agent*). If it is blocked on a trust-folder
   prompt, do not accept it; tell the user and stop.
5. Report: project path, workspace, tab/pane, agent. Nothing else.

Do not send any prompt to the agent unless asked; see `project-handoff` for that.
