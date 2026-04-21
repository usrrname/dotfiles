#!/bin/bash
# PostToolUse hook for git commit — reminds the agent to update the session log.
# Triggered after Bash commands that contain "git commit".

# Only trigger on git commit commands
if [[ "$CLAUDE_TOOL_INPUT" != *"git commit"* ]]; then
	exit 0
fi

# Check if a session log exists for today
TODAY=$(date +%Y-%m-%d)
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
EXISTING=$(find docs/session-logs -name "${TODAY}*" -type f 2>/dev/null | head -1)

if [ -z "$EXISTING" ]; then
	echo "SESSION LOG: No session log exists for today ($TODAY). Consider running /session-log to create one."
else
	echo "SESSION LOG: Remember to update $EXISTING with this commit."
fi
