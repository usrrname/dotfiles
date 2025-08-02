#!/bin/bash

# Shared package configuration for setup.sh and tests
# This file contains the definitive list of packages to install

# =============================================================================
# PACKAGE DEFINITIONS
# =============================================================================

# CLI tools and development libraries (installed via 'brew install')
declare -gax BREW_PACKAGES=(
    "git"             # Version control system
    "1password-cli"   # 1Password command-line tool
    "nvm"            # Node Version Manager - npm is installed with each node version
    "pnpm"           # Fast, disk space efficient package manager
    "act"            # Run GitHub Actions locally
    "yarn"           # JavaScript package manager
    "pyenv"          # Python version management
    "gh"             # GitHub CLI
    "mysql-client"   # MySQL client tools
    "mysql"          # MySQL database server
    "nvim"           # Neovim text editor
    "direnv"         # Environment variable manager
)

# GUI applications (installed via 'brew install --cask')
declare -gax CASK_PACKAGES=(
    "cursor"         # AI-powered code editor
    "docker"         # Docker Desktop
    "google-chrome"  # Web browser
    "iterm2"         # Terminal emulator
    "slack"          # Team communication
    "spotify"        # Music streaming
    "zoom"           # Video conferencing
    "orbstack"       # Fast, light container & VM manager
    "claude-code"    # AI coding assistant
    "gpg-suite"      # GPG key management GUI
)

# Auto-generated combined list (DO NOT EDIT MANUALLY)
declare -gax PACKAGES=()

# =============================================================================
# INITIALIZATION FUNCTIONS
# =============================================================================

# Initialize the combined PACKAGES array from BREW_PACKAGES and CASK_PACKAGES
_init_packages() {
    PACKAGES=("${BREW_PACKAGES[@]}" "${CASK_PACKAGES[@]}" "${NODE_GLOBAL_PACKAGES[@]}")
}

# =============================================================================
# PACKAGE DETECTION FUNCTIONS
# =============================================================================

# Check if Homebrew is available
_is_brew_installed() {
    if ! command -v brew &>/dev/null; then
        echo "❌ Error: Homebrew is not installed" >&2
        echo "Run: curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | zsh"
        exit 1
    fi

    echo "🍺 Homebrew is installed"
}

# Check if a regular brew package is installed
# @param $1 package name
# @returns 0 if installed, 1 if not installed or error
is_brew_package_installed() {
    local package="${1:-}"
    
    [[ -n "$package" ]] || { echo "❌ Error: Package name required" >&2; return 1; }
    
    brew list "$package" &>/dev/null
}

# Check if a cask package is installed
# @param $1 package name
# @returns 0 if installed, 1 if not installed or error
is_cask_installed() {
    local package="${1:-}"
    
    [[ -n "$package" ]] || { echo "❌ Error: Package name required" >&2; return 1; }
    
    brew list --cask "$package" &>/dev/null
}

# Check if any package is installed (auto-detects type)
# @param $1 package name
# @returns 0 if installed, 1 if not installed or error
is_package_installed() {
    local package="${1:-}"
    
    [[ -n "$package" ]] || { echo "❌ Error: Package name required" >&2; return 1; }
    
    is_brew_package_installed "$package" || is_cask_installed "$package"
}

# =============================================================================
# STATUS REPORTING FUNCTIONS
# =============================================================================

# Get detailed package information with type detection
# @param $1 package name
# @returns package info string
get_package_info() {
    local package="${1:-}"
    [[ -n "$package" ]] || return 1
    
    local package_type="unknown"
    local install_status="❌ missing"
    
    # Determine package type and status
    if is_brew_package_installed "$package"; then
        package_type="brew"
        install_status="✅ installed"
    elif is_cask_installed "$package"; then
        package_type="cask"
        install_status="✅ installed"
    else
        # Determine expected type based on our arrays
        if [[ " ${BREW_PACKAGES[*]} " =~ " ${package} " ]]; then
            package_type="brew"
        elif [[ " ${CASK_PACKAGES[*]} " =~ " ${package} " ]]; then
            package_type="cask"
        elif [[ " ${NODE_GLOBAL_PACKAGES[*]} " =~ " ${package} " ]]; then
            package_type="node"
        fi
    fi
    
    printf "%-20s %-6s %s\n" "$package" "($package_type)" "$install_status"
}

# Validate package configuration consistency
validate_package_config() {
    local errors=0
    
    echo "🔍 Validating package configuration..."
    
    # Check for duplicates within arrays
    local duplicates
    duplicates=$(printf '%s\n' "${BREW_PACKAGES[@]}" | sort | uniq -d)
    if [[ -n "$duplicates" ]]; then
        echo "❌ Error: Duplicate packages in BREW_PACKAGES: $duplicates"
        ((errors++))
    fi
    
    duplicates=$(printf '%s\n' "${CASK_PACKAGES[@]}" | sort | uniq -d)
    if [[ -n "$duplicates" ]]; then
        echo "❌ Error: Duplicate packages in CASK_PACKAGES: $duplicates"
        ((errors++))
    fi
    
    # Check for overlap between brew and cask packages
    local overlap=()
    for pkg in "${BREW_PACKAGES[@]}"; do
        if [[ " ${CASK_PACKAGES[*]} " =~ " ${pkg} " ]]; then
            overlap+=("$pkg")
        fi
    done
    
    if [[ ${#overlap[@]} -gt 0 ]]; then
        echo "❌ Error: Packages appear in both BREW_PACKAGES and CASK_PACKAGES: ${overlap[*]}"
        ((errors++))
    fi
    
    # Verify PACKAGES matches combined arrays
    local expected_count=$((${#BREW_PACKAGES[@]} + ${#CASK_PACKAGES[@]}))
    if [[ ${#PACKAGES[@]} -ne $expected_count ]]; then
        echo "❌ Error: PACKAGES array size (${#PACKAGES[@]}) doesn't match expected ($expected_count)"
        ((errors++))
    fi
    
    if [[ $errors -eq 0 ]]; then
        echo "✅ Package configuration is valid"
        echo "   Brew packages: ${#BREW_PACKAGES[@]}"
        echo "   Cask packages: ${#CASK_PACKAGES[@]}"
        echo "   Total packages: ${#PACKAGES[@]}"
    fi
    
    return $errors
}

# List all packages with detailed information
list_packages() {
    echo "📦 Package Configuration:"
    echo ""
    echo "🍺 Brew Packages (${#BREW_PACKAGES[@]}):"
    for pkg in "${BREW_PACKAGES[@]}"; do
        get_package_info "$pkg"
    done
    echo ""
    echo "📱 Cask Packages (${#CASK_PACKAGES[@]}):"
    for pkg in "${CASK_PACKAGES[@]}"; do
        get_package_info "$pkg"
    done
    echo ""
    echo "📊 Total: ${#PACKAGES[@]} packages"
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize the package arrays when this file is sourced
_init_packages