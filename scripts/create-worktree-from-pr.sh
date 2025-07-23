#!/bin/zsh
# cpr - create a git worktree for a pull request
# Usage: cpr <PR_NUMBER> [<REMOTE>]
# Example: cpr 1234 origin
# If no remote is specified, it defaults to 'origin'.
# Note: This command fetches the branch associated with the PR and creates a worktree in the current directory.
# The worktree will be named after the branch.
# Ensure you have the GitHub CLI installed and authenticated with `gh auth login`.
create-worktree-from-pr() {
  # check if .git folder in current directory
  if [ ! -d ".git" ]; then
    echo "Not in a git repository"
    return
  fi

  echo "Creating worktree for PR #$1 in ${PWD}"
  pr="$1"
  remote="${2:-origin}"
  branch=$(gh pr view "$pr" --json headRefName -q .headRefName)
  git fetch "$remote" "$branch"
  git worktree add "../$branch" "$branch"
  cd "../$branch" || return
  echo "Switched to new worktree for PR #$pr: $branch"
}