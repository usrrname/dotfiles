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
  ctx_display=" | ${used_k}k/${total_k}k ($(printf '%.0f' "$used_pct")%)"
else
  ctx_display=""
fi

# Cost
cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
cost_display=""
if [ -n "$cost_usd" ]; then
  cost_display=" | \$$(printf '%.2f' "$cost_usd")"
fi

# Rate limits
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
rate_display=""
if [ -n "$five" ] || [ -n "$week" ]; then
  rate_display=" |"
  [ -n "$five" ] && rate_display="$rate_display 5h:$(printf '%.0f' "$five")%"
  [ -n "$week" ] && rate_display="$rate_display 7d:$(printf '%.0f' "$week")%"
fi

printf '~%s | %s%s%s%s' "$short_dir" "$model" "$cost_display" "$ctx_display" "$rate_display"
