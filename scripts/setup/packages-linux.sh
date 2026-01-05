#!/bin/bash

# Shared package configuration for setup-linux.sh and setup-debian-pi.sh
# This file contains the definitive list of packages to install on Debian/Ubuntu

# =============================================================================
# DISTRIBUTION DETECTION
# =============================================================================

# Detect distribution
_detect_distribution() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DISTRO="${ID:-unknown}"
    DISTRO_VERSION="${VERSION_ID:-unknown}"
    DISTRO_CODENAME="${VERSION_CODENAME:-$(lsb_release -cs 2>/dev/null || echo "unknown")}"
  elif [[ -f /etc/debian_version || -f /etc/lsb-release ]]; then
    DISTRO=$(lsb_release -si 2>/dev/null | tr '[:upper:]' '[:lower:]' || echo "debian")
    DISTRO_VERSION=$(lsb_release -sr 2>/dev/null || echo "unknown")
    DISTRO_CODENAME=$(lsb_release -cs 2>/dev/null || echo "unknown")
  else
    DISTRO="unknown"
    DISTRO_VERSION="unknown"
    DISTRO_CODENAME="unknown"
  fi

  # Detect architecture
  ARCH=$(dpkg --print-architecture 2>/dev/null || echo "unknown")
}

# Initialize distribution detection
_detect_distribution

# =============================================================================
# BASE PACKAGE DEFINITIONS (Common to all Debian/Ubuntu systems)
# =============================================================================

# CLI tools and development libraries (installed via 'apt install')
declare -gax APT_PACKAGES_BASE=(
  "git"                 # Version control system
  "curl"                # HTTP client (needed for many install scripts)
  "wget"                # HTTP client
  "build-essential"     # Essential build tools (gcc, make, etc.)
  "openssl"             # OpenSSL
  "libyaml-dev"         # YAML library development files
  "libgmp-dev"          # GNU Multiple Precision Arithmetic Library
  "ca-certificates"     # CA certificates
  "gnupg"               # GPG tools
  "apt-transport-https" # HTTPS transport for APT
  "lsb-release"         # Linux Standard Base
  "tree"
)

# Packages that require special installation (not via apt)
declare -gax SPECIAL_PACKAGES_BASE=(
  "nvm"       # Node Version Manager (installed via script)
  "pnpm"      # Fast, disk space efficient package manager (npm)
  "direnv"    # Environment variable manager (custom install)
  "tailscale" # VPN mesh networking (official script)
  "immich"    # Self-hosted photo and video backup solution (Docker)
  "grafana"   # Self-hosted monitoring and analytics platform (Docker)
)

# =============================================================================
# PI-SPECIFIC PACKAGE DEFINITIONS
# =============================================================================

# Additional packages for Raspberry Pi NAS setup
declare -gax APT_PACKAGES_PI=(
  "ufw"                 # Uncomplicated Firewall
  "openssh-server"      # OpenSSH server
  "openssh-client"      # OpenSSH client
  "nfs-kernel-server"   # NFS Kernel Server
  "samba"               # Samba for Windows/Linux file sharing
  "fail2ban"            # Firewall protection
  "hd-idle"             # Idle detection for hard drives
  "unattended-upgrades" # Automatic security updates
  "apt-transport-https" # HTTPS transport for APT
  "wget" # HTTP client
)

# Docker packages (for Pi setup)
declare -gax DOCKER_PACKAGES=(
  "containerd.io|containerd.io"
  "docker-ce|Docker CE"
  "docker-ce-cli|Docker CE CLI"
  "docker-buildx-plugin|Docker Buildx Plugin"
  "docker-compose-plugin|Docker Compose Plugin"
  "docker-ce-rootless-extras|Docker CE Rootless Extras"
)

declare -gax DOCKER_DEPENDENCIES=(
  "iptables|iptables"
  "libip4tc2|libip4tc2"
  "libip6tc2|libip6tc2"
  "pigz|pigz"
  "libslirp0|libslirp0"
  "slirp4netns|slirp4netns"
  "xdg-dbus-proxy|xdg-dbus-proxy"
)

declare -gax SUPPORTING_LIBRARIES=(
)

# =============================================================================
# FINAL PACKAGE ARRAYS (Combined based on context)
# =============================================================================

# Default APT packages (can be extended by setup scripts)
declare -gax APT_PACKAGES=("${APT_PACKAGES_BASE[@]}")

# Default special packages (can be extended by setup scripts)
declare -gax SPECIAL_PACKAGES=("${SPECIAL_PACKAGES_BASE[@]}")

# Auto-generated combined list (DO NOT EDIT MANUALLY)
declare -gax PACKAGES=()

# =============================================================================
# INITIALIZATION FUNCTIONS
# =============================================================================

# Initialize the combined PACKAGES array
_init_packages() {
  PACKAGES=("${APT_PACKAGES[@]}" "${SPECIAL_PACKAGES[@]}")
}

# =============================================================================
# PACKAGE DETECTION FUNCTIONS
# =============================================================================

# Check if APT is available and distribution is supported
_is_apt_available() {
  if ! command -v apt &>/dev/null && ! command -v apt-get &>/dev/null; then
    echo "❌ Error: APT is not available" >&2
    echo "This script only supports Debian or Ubuntu" >&2
    exit 1
  fi

  if [[ "$DISTRO" == "unknown" ]]; then
    echo "⚠️  Warning: Could not detect distribution, continuing anyway..." >&2
  else
    echo "✅ Detected: $DISTRO $DISTRO_VERSION ($DISTRO_CODENAME)"
    echo "✅ Architecture: $ARCH"
  fi

  echo "✅ APT is available"
}

# Check if an APT package is installed
# @param $1 package name
# @returns 0 if installed, 1 if not installed or error
is_apt_package_installed() {
  local package="${1:-}"

  [[ -n "$package" ]] || {
    echo "❌ Error: Package name required" >&2
    return 1
  }

  dpkg -l "$package" &>/dev/null 2>&1 && dpkg -s "$package" &>/dev/null 2>&1
}

# Check if a command is available
# @param $1 command name
# @returns 0 if available, 1 if not available
is_command_available() {
  local cmd="${1:-}"

  [[ -n "$cmd" ]] || {
    echo "❌ Error: Command name required" >&2
    return 1
  }

  command -v "$cmd" &>/dev/null
}

# Check if Tailscale is installed
# @returns 0 if installed, 1 if not installed
is_tailscale_installed() {
  is_command_available "tailscale"
}

# =============================================================================
# STATUS REPORTING FUNCTIONS
# =============================================================================

# Get detailed package information
# @param $1 package name
# @returns package info string
get_package_info() {
  local package="${1:-}"
  [[ -n "$package" ]] || return 1

  # Extract package name if format is "package|description"
  local pkg_name="$package"
  if [[ "$package" == *"|"* ]]; then
    IFS='|' read -r pkg_name _ <<<"$package"
  fi

  local package_type="unknown"
  local install_status="❌ missing"

  # Determine package type and status
  if is_apt_package_installed "$pkg_name"; then
    package_type="apt"
    install_status="✅ installed"
  elif is_command_available "$pkg_name"; then
    package_type="command"
    install_status="✅ installed"
  else
    # Determine expected type based on our arrays
    if [[ " ${APT_PACKAGES[*]} " =~ " ${pkg_name} " ]] || [[ " ${APT_PACKAGES_BASE[*]} " =~ " ${pkg_name} " ]] || [[ " ${APT_PACKAGES_PI[*]} " =~ " ${pkg_name} " ]]; then
      package_type="apt"
    elif [[ " ${SPECIAL_PACKAGES[*]} " =~ " ${pkg_name} " ]] || [[ " ${SPECIAL_PACKAGES_BASE[*]} " =~ " ${pkg_name} " ]]; then
      package_type="special"
    fi
  fi

  printf "%-30s %-10s %s\n" "$pkg_name" "($package_type)" "$install_status"
}

# List all packages with detailed information
list_packages() {
  echo "📦 Package Configuration for $DISTRO $DISTRO_VERSION ($ARCH):"
  echo ""
  echo "📦 APT Packages (${#APT_PACKAGES[@]}):"
  for pkg in "${APT_PACKAGES[@]}"; do
    get_package_info "$pkg"
  done
  echo ""
  echo "🔧 Special Packages (${#SPECIAL_PACKAGES[@]}):"
  for pkg in "${SPECIAL_PACKAGES[@]}"; do
    get_package_info "$pkg"
  done
  echo "📊 Total: ${#PACKAGES[@]} packages"
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize the package arrays when this file is sourced
_init_packages
