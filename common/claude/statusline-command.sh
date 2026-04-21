#!/bin/sh
# Claude Code status line — inspired by ~/.zshrc PROMPT='~🧻 '
input=$(cat)

dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
short_dir=$(basename "$dir")
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
used=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
total=$(echo "$input" | jq -r '.context_window.context_window_size // empty')

# Build context display
if [ -n "$used_pct" ] && [ -n "$used" ] && [ -n "$total" ]; then
  used_k=$((used / 1000))
  total_k=$((total / 1000))
  ctx_display=" | ${used_k}k/${total_k}k used ($(printf '%.0f' "$used_pct")% full)"
else
  ctx_display=""
fi

printf '%s%s' "$model" "$ctx_display"
