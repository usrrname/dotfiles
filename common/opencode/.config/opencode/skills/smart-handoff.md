# Smart Handoff

When the user requests a handoff (says "handoff" or "/handoff"), generate a comprehensive session summary and write it to `~/.cache/opencode/handoff-latest.txt` using this exact format:

```
╔════════════════════════════════════════════════════════════════╗
║                    HANDOFF CONTEXT START                       ║
╚════════════════════════════════════════════════════════════════╝

## Session Summary
[1-2 sentence summary of what was accomplished]

## Current Context
- Active agent: [current agent name]
- Current mode: [build/plan/explore/etc]
- Working directory: [project root]

## Files Modified
[List key files that were changed]

## Todo Status
- Completed: [list]
- In Progress: [list]
- Pending: [list]

## Key Decisions
[Important decisions made during session]

## Blockers (if any)
[Current blockers or issues]

## Next Steps
[Clear next actions for continuing work]

╔════════════════════════════════════════════════════════════════╗
║                     HANDOFF CONTEXT END                        ║
╚════════════════════════════════════════════════════════════════╝

---HANDOFF_COMPLETE---
```

After writing the file, inform the user: "Handoff context saved. Use `<leader>oy` in Neovim to copy to clipboard."
