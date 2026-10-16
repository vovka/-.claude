# herdr backend

All commands print JSON. `herdr agent start` needs `--kind` (e.g. `claude`, `codex`) and a pane at a shell prompt.

- **find workspace** — `herdr pane list`; pick panes whose `cwd`/`foreground_cwd` equals the project dir and
  take their `workspace_id`. Fallback: `herdr workspace list` and match `label`.
- **create workspace** — `herdr workspace create --cwd <dir> --label <name> --no-focus`; the result has
  `root_pane.pane_id` and `workspace.workspace_id`. Its root pane is the first tab, so for a brand-new
  workspace use that pane instead of creating another tab.
- **new tab** — `herdr tab create --workspace <wid> --cwd <dir> --label <name> --focus`; the new pane is `result.root_pane.pane_id`.
- **start agent** — `herdr agent start <name> --kind <agent> --pane <pane_id>`.
  Error `agent_not_ready`: run `herdr pane read <pane_id>` to see why (usually the trust-folder prompt).
- **switch to workspace** — `herdr workspace focus <wid>`.
- **send prompt** — `herdr agent prompt <name> "<text>" --wait --until idle`.
  Pass long text via `"$(cat file)"`; write the file under the session scratchpad.
