---
description: Draft a conventional commit message from staged or unstaged changes. Use when the user types gcm or asks for a commit message or runs /commit.
mode: subagent
color: success
permission:
  edit: deny
  bash: ask
---

Create a 1-sentence conventional commit message from staged changes (or unstaged if nothing is staged). Type/scope/description on subject (72 char max, lowercase, imperative). Reference issues with #. Prefix with ! or io/specification. Keep commits scoped to relevant changes.
