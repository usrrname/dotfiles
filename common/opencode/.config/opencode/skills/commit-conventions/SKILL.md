---
name: commit-conventions
description: Conventional-commit message format for this repo. Use when writing, drafting, or reviewing commit messages.
---

# Commit Conventions

Conventional-commit message format for this repo. Use when writing, drafting, or reviewing commit messages.

## Format

```
<type>(<scope>): <description> (#<issue-number>)

[optional body]

[optional footer]

Commit written by <agent_name>
```

## Type

Use one of:

- **feat** — New feature
- **fix** — Bug fix
- **docs** — Documentation only
- **style** — Formatting, no code change
- **refactor** — Code change, no bug or feature
- **perf** — Performance improvement
- **test** — Add or update tests
- **chore** — Maintenance (deps, build config)
- **build** — Build system or dependencies
- **ci** — CI configuration
- **revert** — Revert a previous commit
- **security** — Security fix
- **rename** — File or directory rename

## Critical Rules

- Run `git status` before committing; `git add <filename>` from repo root
- Never overwrite or push untracked files
- Commits MUST follow conventional-commit standard
- Subject: max 72 chars, lowercase, imperative mood, no period
- Body: max 20 words, wrap at 72 chars — only for essential context
- Prefer single-line descriptions when possible
- Reference issue with `#` in subject or footer
- Add agent name as footer attribution

## Breaking Changes

Append `!` after type/scope:

```
feat!: remove deprecated API
feat(api)!: remove deprecated API
```

## Examples

```
feat(auth): add OAuth2 login support

Implements OAuth2 flow with refresh token rotation.
Closes #45

Commit written by sisyphus
```

```
fix(api): resolve null pointer on missing user id

Returns 404 instead of 500 when user_id query param is absent.
Fixes #123

Commit written by build
```

```
chore: bump dependencies

Commit written by sisyphus
```

```
feat!: remove deprecated user endpoint

BREAKING CHANGE: The /v1/users endpoint has been removed.
Use /v2/users instead.

Commit written by sisyphus
```
