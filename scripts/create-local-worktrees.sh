#!/bin/zsh

create-local-worktrees() {

    # set -x
    # get repo name from user
    read "REPO_NAME?Enter repo name: (press enter for current repo)"
    if [ -z "$REPO_NAME" ]; then
        REPO_NAME=$(basename $(git rev-parse --show-toplevel))
        echo "Using current repo name: $REPO_NAME"
    fi

    # ask user to select branch type

    read "BRANCH_TYPE?Select branch type: \
    1) feature \
    2) bug \
    3) hotfix\
    4) chore"

    case $BRANCH_TYPE in
        1)
            BRANCH_TYPE="feature"
            ;;
        2)
            BRANCH_TYPE="bug"
            ;;
        3)
            BRANCH_TYPE="hotfix"
            ;;
        4)
            BRANCH_TYPE="chore"
            ;;
    esac
    # validate branch type
    if [ -z "$BRANCH_TYPE" ]; then
        BRANCH_TYPE="feature"
    fi

    read "Ticket_ID?Enter ticket ID: (press enter for none)"
    if [ -z "$Ticket_ID" ]; then
    # random number if ticket id not given
        Ticket_ID=$(shuf -i 100000-999999 -n 1)
        echo "Random ticket ID generated: $Ticket_ID"
    fi

    BRANCH_NAME="${BRANCH_TYPE}-${Ticket_ID}"

    # get base branch from user
    read "BASE_BRANCH?Enter base branch: (press enter for main)"
    
    if [ -z "$BASE_BRANCH" ]; then
        BASE_BRANCH="main"
    fi

    WORKTREE_PATH="../${REPO_NAME}-${BRANCH_NAME}"

    # Create worktree
    git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH" "$BASE_BRANCH"

    # Copy .env to worktree
    cp "$PWD/.env" "$WORKTREE_PATH/.env"
    echo "Copied .env to $WORKTREE_PATH/.env"

    # Setup environment
    cd "$WORKTREE_PATH" && echo "switched to $PWD"

    # Store names in variable
    ACTIVE_CONTAINERS=$(docker ps --format "{{.Names}}")

  # get existing Docker containers if they are running
    EXISTING_CONTAINERS=$(docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}" | grep -v "$BRANCH_NAME")
    echo "Existing containers: $EXISTING_CONTAINERS"

    # create new ports mapped to existing ports
    NEW_PORTS=$(echo $EXISTING_CONTAINERS | sed 's/-p \([0-9]*\):/-p \1+1000:/g')

    # print new ports
    echo "New ports: $NEW_PORTS"

    # start project (ie. npm ci)
    echo "Starting project..."

    # Create task file
    echo "# Task: $BRANCH_NAME
    ## Description:
    [Add your task description here]

    ## Files to modify:
    - 

    ## Success criteria:
    - " > TASK.md

    echo "Worktree created at: $WORKTREE_PATH"
    echo "Task file created: TASK.md"
    echo "Ready for Claude Code!"

    # Open in editor (Optional)
    echo "Opening in editor..."
    #cursor "$WORKTREE_PATH"
    cp "~/scripts/prompt-templates/$BRANCH_TYPE-prompt.txt" "$WORKTREE_PATH/.claude/$BRANCH_TYPE-prompt.txt"
    echo "Populate .claude/$BRANCH_TYPE-prompt.txt with your specs"

    echo "run claude code --system "$WORKTREE_PATH/.claude/$BRANCH_TYPE-prompt.txt" to initialize workflow"
}