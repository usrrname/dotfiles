# Commit Conventions

Follow these guidelines when drafting commit messages.

## Format

```
<type>(<scope>): <description> (#<issue-number>)

[optional body]

[optional footer]

Commit written by <agent_name>
```

## Type

Use one of:

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Formatting, missing semicolons, etc. (no code change)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Performance improvement
- **test**: Adding or updating tests
- **chore**: Maintenance tasks (dependencies, build config, etc.)
- **build**: Changes affecting build system or dependencies
- **ci**: Changes to CI configuration files and scripts
- **revert**: Reverts a previous commit
- **security**: Security fixes
- **rename**: File or directory renaming

## Critical Rules

- Use `git status` to check modified or staged files before committing
- Never overwrite or push untracked files
- Commits MUST follow the conventional-commit standard
- Always run `git add <filename>` from repo root
- Use present tense in subject ("add" not "added")
- Subject: max 72 characters, lowercase, no period
- Use imperative mood ("add feature" not "added feature")
- Body: max 20 words, concise, wrap at 72 characters
- Prefer single-line descriptions when possible
- Only use body for essential context
- Reference issue/ticket with `#` in subject or footer
- Add agent name as footer attribution

## Breaking Changes

Append `!` after type/scope:

```
feat!: remove deprecated API
feat(api)!: remove deprecated API
```

Or use `BREAKING CHANGE:` footer:

```
feat: remove deprecated API

BREAKING CHANGE: The deprecated 'oldMethod' has been removed.
```

## Footer Conventions

```
Closes #123
Fixes: #123
Refs: #123

Reviewed-by: Name <email>
Co-authored-by: Name <email>
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
