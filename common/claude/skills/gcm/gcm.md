---
description: Generate conventional commit message from staged or unstaged changes
model: inherit
allowed-tools: [Bash]
user-invocable: true
---

Generate a conventional commit message for the current changes.

## Process

1. Run `git log --oneline -10` and match the existing commit style.
2. Run `git diff --cached` to read staged changes. If empty, run `git diff` for unstaged changes.
3. Generate the commit message following the rules below.

## Format

```
<type>(<scope>): <description>

<body>

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
```

## Types

`fix`, `feat`, `docs`, `style`, `refactor`, `test`, `chore`, `spelling`, `rename`

## Scope

Infer from changed file paths. If changes span multiple scopes, use the most significant one or omit the scope.

## Body

Include a body when the change is non-trivial. Explain **why**, not what. Separate from title with a blank line. Wrap at 72 characters.

## Breaking changes

If the change is breaking, add `!` after the scope and a `BREAKING CHANGE:` footer:

```
feat(sdk)!: rename updateSnapshot to updateProject

BREAKING CHANGE: updateSnapshot removed, use updateProject(projectId, { snapshotId }) instead.

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
```

## Additional context

$@
