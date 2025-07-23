clean-worktree() {
    # if in git repo
    if [ -z "$(git rev-parse --show-toplevel)" ]; then
        echo "Not in a git repo"
        return
    fi

    # get worktrees
    git worktree list | grep -v "$(git rev-parse --show-toplevel)" | while read worktree branch commit; do
        branch_name=$(echo $branch | sed 's/\[//g' | sed 's/\]//g')
        echo "Removing worktree? (y/n): $worktree ($branch_name)"
        read -p "Remove worktree? (y/n): " is_remove_worktree
        if [ "$is_remove_worktree" = "y" ]; then
            git worktree remove "$worktree"
            git branch -d "$branch_name"
            echo "Worktree removed: $worktree ($branch_name)"
        else
            echo "Worktree not removed: $worktree ($branch_name)"
        fi
    done
}