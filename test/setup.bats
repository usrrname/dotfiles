#!/usr/bin/env bats

setup() {
    load 'test_helper/bats-assert/load'
    load 'test_helper/bats-support/load'
}

@test "can run script in dry-run mode" {
    DRY_RUN=true run ./setup.sh
    assert_success
    assert_output --partial 'Installing packages...'
    assert_output --partial 'Setup complete!'
    # Should contain either "Installing Homebrew..." or "Homebrew already installed"
    assert_output --regexp '(Installing Homebrew\.\.\.|Homebrew already installed)'
}

@test "script handles existing homebrew" {
    # This test assumes you have homebrew installed
    if command -v brew &> /dev/null; then
        DRY_RUN=true run ./setup.sh
        assert_success
        assert_output --partial 'Homebrew already installed'
    else
        skip "Homebrew not installed"
    fi
}