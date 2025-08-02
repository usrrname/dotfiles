#!/usr/bin/env bats

# Source shared package configuration
setup() {
    source "config/packages.sh"
    load 'test_helper/bats-assert/load'
    load 'test_helper/bats-support/load'
}

after_each() {
    # Reset the package arrays
    BREW_PACKAGES=()
    CASK_PACKAGES=()
    _init_packages
}

@test "can run script in dry-run mode" {
    DRY_RUN=true run ./setup.sh
    assert_success
    assert_output --partial 'Homebrew is installed'
    assert_output --partial 'Installing packages...'
    assert_output --partial 'Setup complete!'
    # Should contain either "Installing Homebrew..." or "Homebrew already installed"
    assert_output --regexp '(Installing Homebrew\.\.\.|Homebrew already installed)'
    unset DRY_RUN
}

@test "should succeed check if brew is already installed" {

    CHECK_ONLY=true run ./setup.sh check;
    if command -v brew &>/dev/null; then
        assert_success
        assert_output --partial 'Homebrew is installed'
    else
        assert_failure
        assert_output --partial 'Homebrew is not installed'
    fi
    unset CHECK_ONLY
}

@test "should check for if a package is installed" {
    # Test the package checking functions work
    if command -v brew &>/dev/null; then
        # Test with git (should be installed)
        run is_brew_package_installed "git"
        assert_success
        
        # Test with a package that definitely doesn't exist
        run is_brew_package_installed "definitely-not-a-real-package-name-12345"
        assert_failure
    else
        skip "Homebrew not installed"
    fi
}

@test "should be able to check for cask installation" {
    if command -v brew &>/dev/null; then
        for cask in "${CASK_PACKAGES[@]}"; do
            if brew list --cask $cask &>/dev/null; then
                run is_cask_installed "$cask"
                assert_success
            else
                run is_cask_installed "$cask"
                assert_failure
            fi
        done
    fi
}

@test 'packages can be listed' {
    run ./setup.sh list
    assert_success
    assert_output --partial "📦 Package Configuration:"
}

@test 'should validate package configuration to prevent duplicate in brew and cask arrays' {
    # Save original arrays
    local orig_brew=("${BREW_PACKAGES[@]}")
    local orig_cask=("${CASK_PACKAGES[@]}")
    
    # Add a duplicate package to create overlap between arrays
    BREW_PACKAGES+=("git")
    CASK_PACKAGES+=("git")
    
    # Re-initialize PACKAGES array with the modified arrays
    _init_packages
    
    # Test validation function directly
    run validate_package_config
    assert_failure
    assert_output --partial "❌ Error: Packages appear in both BREW_PACKAGES and CASK_PACKAGES: git"
    
    # Restore original arrays
    BREW_PACKAGES=("${orig_brew[@]}")
    CASK_PACKAGES=("${orig_cask[@]}")
    _init_packages
}

@test 'should detect duplicates within same array' {
    # Save original arrays
    local orig_brew=("${BREW_PACKAGES[@]}")
    
    # Add a duplicate within the same array
    BREW_PACKAGES+=("git")  # git already exists in BREW_PACKAGES
    
    # Re-initialize PACKAGES array
    _init_packages
    
    # Test validation function directly
    run validate_package_config
    assert_failure
    assert_output --partial "❌ Error: Duplicate packages in BREW_PACKAGES: git"
    
    # Restore original arrays
    BREW_PACKAGES=("${orig_brew[@]}")
    _init_packages
}

@test 'should validate clean configuration successfully' {
    # Test that current configuration is valid
    run validate_package_config
    assert_success
    assert_output --partial "✅ Package configuration is valid"
    assert_output --partial "Brew packages: ${#BREW_PACKAGES[@]}"
    assert_output --partial "Cask packages: ${#CASK_PACKAGES[@]}"
}