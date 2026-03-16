#!/bin/bash

# Nix garbage collection cleanup script
# Removes old direnv profiles and result symlinks, then runs GC

set -e

echo "=== Nix Store Cleanup Script ==="
echo

# Check initial size
echo "Current /nix/store size:"
du -sh /nix/store
echo

# Find all direnv flake profiles
echo "Finding direnv flake profiles to remove..."
DIRENV_PROFILES=$(find ~/proj -name 'flake-profile-*-link' -path '*/.direnv/*' 2>/dev/null || true)
if [ -z "$DIRENV_PROFILES" ]; then
    PROFILE_COUNT=0
else
    PROFILE_COUNT=$(echo "$DIRENV_PROFILES" | wc -l)
fi
echo "Found $PROFILE_COUNT old direnv profile links"

# Show some examples if found
if [ $PROFILE_COUNT -gt 0 ]; then
    echo "Examples:"
    echo "$DIRENV_PROFILES" | head -5
    echo
fi

# Find result symlinks
echo "Finding result symlinks to remove..."
RESULT_LINKS=$(find ~/proj -maxdepth 3 -name 'result' -type l 2>/dev/null || true)
RESULT_COUNT=0
if [ -n "$RESULT_LINKS" ]; then
    RESULT_COUNT=$(echo "$RESULT_LINKS" | wc -l)
fi

# Check for result in home
if [ -L ~/result ]; then
    echo "Found ~/result symlink"
    RESULT_COUNT=$((RESULT_COUNT + 1))
    if [ -z "$RESULT_LINKS" ]; then
        RESULT_LINKS="$HOME/result"
    else
        RESULT_LINKS="$RESULT_LINKS
$HOME/result"
    fi
fi

echo "Found $RESULT_COUNT result symlinks"

# Show some examples if found
if [ $RESULT_COUNT -gt 0 ]; then
    echo "Examples:"
    echo "$RESULT_LINKS" | head -5
    echo
fi

# Nothing to clean
if [ $PROFILE_COUNT -eq 0 ] && [ $RESULT_COUNT -eq 0 ]; then
    echo "No GC roots found to remove."
    echo
    read -p "Run garbage collection anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
else
    # Ask about direnv profiles
    REMOVE_PROFILES=false
    if [ $PROFILE_COUNT -gt 0 ]; then
        read -p "Remove $PROFILE_COUNT direnv profile links? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            REMOVE_PROFILES=true
        fi
    fi

    # Ask about result symlinks
    REMOVE_RESULTS=false
    if [ $RESULT_COUNT -gt 0 ]; then
        read -p "Remove $RESULT_COUNT result symlinks? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            REMOVE_RESULTS=true
        fi
    fi

    # Remove direnv profiles if approved
    if [ "$REMOVE_PROFILES" = true ]; then
        echo "Removing direnv profiles..."
        find ~/proj -name 'flake-profile-*-link' -path '*/.direnv/*' -delete 2>/dev/null || true
        echo "Done."
    fi

    # Remove result symlinks if approved
    if [ "$REMOVE_RESULTS" = true ]; then
        echo "Removing result symlinks..."
        find ~/proj -maxdepth 3 -name 'result' -type l -delete 2>/dev/null || true
        [ -L ~/result ] && rm ~/result
        echo "Done."
    fi

    echo
fi

# Detect nix installation type
if [ -f /etc/profile.d/nix.sh ]; then
    # Multi-user install
    echo "Detected multi-user Nix installation"
    echo
    echo "Running garbage collection (user profile)..."
    nix-collect-garbage -d

    echo
    echo "Running garbage collection (system-wide, requires sudo)..."
    sudo bash -c ". /etc/profile.d/nix.sh && nix-collect-garbage -d"

    echo
    echo "Optimizing store (requires sudo)..."
    sudo bash -c ". /etc/profile.d/nix.sh && nix-store --optimize"
else
    # Single-user install
    echo "Detected single-user Nix installation"
    echo
    echo "Running garbage collection..."
    nix-collect-garbage -d

    echo
    echo "Optimizing store..."
    nix-store --optimize
fi

# Show final size
echo
echo "Final /nix/store size:"
du -sh /nix/store

echo
echo "=== Cleanup complete ==="
