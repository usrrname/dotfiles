#!/usr/bin/env bats

setup() {
    load 'test_helper/bats-assert/load'
    load 'test_helper/bats-support/load'
    TEST_TEMP_DIR=$(mktemp -d)
}

teardown() {
    rm -rf "$TEST_TEMP_DIR"
}

contains() {
    local element="$1"
    shift
    local array=("$@")
    for item in "${array[@]}"; do
        if [[ "$item" == "$element" ]]; then
            return 0
        fi
    done
    return 1
}

@test "COMMON packages are defined with expected packages" {
    local common_packages=$(grep -A10 '^COMMON=(' "$BATS_TEST_DIRNAME/../stow-dotfiles.sh" | grep -oE '^\s+[a-z]+' | tr -d ' ')
    assert [ -n "$common_packages" ]
    assert contains "bash" $common_packages
    assert contains "nvim" $common_packages
    assert contains "direnv" $common_packages
}

@test "LINUX packages include git and zsh" {
    local linux_packages=$(grep -A5 '^LINUX=(' "$BATS_TEST_DIRNAME/../stow-dotfiles.sh" | grep -oE '^\s+[a-z]+' | tr -d ' ')
    assert contains "git" $linux_packages
    assert contains "zsh" $linux_packages
}

@test "MACOS packages include git, zsh, and act" {
    local macos_packages=$(grep -A10 '^MACOS=(' "$BATS_TEST_DIRNAME/../stow-dotfiles.sh" | grep -oE '^\s+[a-z]+' | tr -d ' ')
    assert contains "git" $macos_packages
    assert contains "zsh" $macos_packages
    assert contains "act" $macos_packages
}

@test "stow-dotfiles.sh script exists and is executable" {
    assert test -x "$BATS_TEST_DIRNAME/../stow-dotfiles.sh"
}

@test "stow-dotfiles.sh accepts empty first argument" {
    run "$BATS_TEST_DIRNAME/../stow-dotfiles.sh" ""
    # Should not crash - will fail on stow but not on argument parsing
    # We just verify the script doesn't have argument parsing errors
    if [[ $status -ne 0 ]]; then
        refute output --regexp "unexpected"
    fi
}

@test "stow-dotfiles.sh detects Darwin OS correctly" {
    run bash -c 'source "$1" 2>&1; echo "OS=$OS"' _ "$BATS_TEST_DIRNAME/../stow-dotfiles.sh"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        assert_output --regexp "OS=Darwin"
    fi
}

@test "stow-dotfiles.sh has clean_symlinks function" {
    run grep -c "clean_symlinks()" "$BATS_TEST_DIRNAME/../stow-dotfiles.sh"
    assert_output "1"
}

@test "stow-dotfiles.sh has unstow_all function" {
    run grep -c "unstow_all()" "$BATS_TEST_DIRNAME/../stow-dotfiles.sh"
    assert_output "1"
}

@test "stow-dotfiles.sh has stow_package function" {
    run grep -c "stow_package()" "$BATS_TEST_DIRNAME/../stow-dotfiles.sh"
    assert_output "1"
}

@test "stow-dotfiles.sh cleans .DS_Store on Darwin" {
    run grep '\.DS_Store' "$BATS_TEST_DIRNAME/../stow-dotfiles.sh"
    assert_success
    run grep 'Darwin' "$BATS_TEST_DIRNAME/../stow-dotfiles.sh"
    assert_success
}

@test "stow-dotfiles.sh handles --adopt flag" {
    run grep 'STOW_FLAGS="--adopt"' "$BATS_TEST_DIRNAME/../stow-dotfiles.sh"
    assert_success
}

@test "stow-dotfiles.sh uses correct stow directory structure" {
    run grep 'stow.*-d' "$BATS_TEST_DIRNAME/../stow-dotfiles.sh"
    assert_success
    run grep -- 'stow -D' "$BATS_TEST_DIRNAME/../stow-dotfiles.sh"
    assert_success
}

@test "stow-dotfiles.sh uses -t ~ for home directory targeting" {
    run grep 'stow.*-t ~' "$BATS_TEST_DIRNAME/../stow-dotfiles.sh"
    assert_success
    assert_output --regexp 'stow.*-t ~'
}

@test "stow-dotfiles.sh warns on stow failure" {
    run grep -c "Warning: Could not stow" "$BATS_TEST_DIRNAME/../stow-dotfiles.sh"
    assert_output "1"
}

@test "stow-dotfiles.sh prints setup complete message" {
    run grep -c "Dotfiles setup complete" "$BATS_TEST_DIRNAME/../stow-dotfiles.sh"
    assert_output "1"
}

@test "stow-dotfiles.sh has error logging for failed stow" {
    run grep -c 'Error: $stow_output' "$BATS_TEST_DIRNAME/../stow-dotfiles.sh"
    assert_output "1"
}