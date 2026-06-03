---
name: tmux-processes
description: Run any long-running process in a named tmux session so it survives across Claude sessions. Use when starting any process that won't exit on its own — dev servers, clusters, watchers, builds, test runners, tail/follow commands, daemons, REPLs, port-forwards, agents, etc. — or when reading output from a previously started one, or when the user mentions tmux sessions, windows, or panes directly. The Bash tool's `run_in_background` only persists within the current Claude session; use this skill instead for anything that should outlive the session.
---

# tmux-processes

Applies to **any** long-running process — examples below (`kilter up`, `pnpm dev`, `tilt up`) are illustrative, not a closed list. If the command doesn't exit on its own and you want to read its output later (this session or a future one), put it in tmux.

## Quick start

```bash
NAME=$(basename $(pwd))   # one session per project

# Start session (idempotent — won't clobber existing)
tmux has-session -t "$NAME" 2>/dev/null \
  || tmux new-session -d -s "$NAME" -n up "$CMD ; exec bash"

# Add another concurrent process as a window in the same session
tmux new-window -t "$NAME" -n dev "pnpm dev ; exec bash"

# Read output (last 500 lines)
tmux capture-pane -t "$NAME:up" -p -S -500

# Stop a process / window / session
tmux send-keys   -t "$NAME:up" C-c
tmux kill-window -t "$NAME:dev"
tmux kill-session -t "$NAME"

# Inspect
tmux list-windows -t "$NAME"
```

## Conventions

- **Session name = `$(basename $(pwd))`** — one project, one session.
- **Window per role** with `-n <role>`: `up`, `dev`, `tilt`, `test`, etc. — addressed as `<session>:<window>`.
- **`; exec bash`** at the end of the command keeps the window alive after the process exits so output can still be read.

## Rules

- **Never `tmux attach`** — it hangs Bash forever. Read with `capture-pane -p` instead.
- **Always pass `-d` to `new-session`** so Bash returns immediately.
- **Always target `<session>:<window>`** when capturing or sending keys — don't rely on the "current" window.
- **For periodic checks**, use `ScheduleWakeup` + `capture-pane`, not a sleep loop.

## Common workflows

### Start a dev server (idempotent)

```bash
NAME=$(basename $(pwd))
tmux has-session -t "$NAME" 2>/dev/null \
  || tmux new-session -d -s "$NAME" -n dev "pnpm dev ; exec bash"
tmux capture-pane -t "$NAME:dev" -p -S -100   # check it actually started
```

### Add a second process to an existing session

```bash
tmux new-window -t "$NAME" -n test "pnpm test --watch ; exec bash"
```

### Check on a process later

```bash
tmux capture-pane -t "$NAME:up" -p -S -500
```

### Stop cleanly

```bash
tmux send-keys -t "$NAME:up" C-c   # SIGINT
# wait a moment, then:
tmux kill-window -t "$NAME:up"
```

## Optional: persistent logs

For grepping across full history (beyond scrollback):

```bash
mkdir -p ~/.local/state/tmux-logs
tmux pipe-pane -t "$NAME" -o "cat >> ~/.local/state/tmux-logs/$NAME.log"
```

Then later:

```bash
grep -i error ~/.local/state/tmux-logs/$NAME.log
```
