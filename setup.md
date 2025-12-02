# Setup Scripts

## Overview

The setup scripts support:
- **macOS**: Uses Homebrew for package management
- **Linux (Debian/Ubuntu)**: Uses APT for package management
- **Raspberry Pi**: Specialized setup for Raspberry Pi 4B

## Files Structure

```bash
├── scripts/
│   ├── setup/
│   │   ├── packages-osx.sh
│   │   ├── packages-linux.sh
│   │   ├── setup-osx.sh
│   │   └── setup-linux.sh
```

### Package Configuration Files

Within `scripts/setup/`:
- `packages-osx.sh` - macOS package definitions and functions
- `packages-linux.sh` - Linux/Debian/Ubuntu package definitions and functions

### Setup Scripts
- `setup-osx.sh` - macOS setup script (uses `packages-osx.sh`)
- `setup-linux.sh` - Linux/Debian/Ubuntu setup script (uses `packages-linux.sh`)

## macOS Setup

### Package Arrays

- `BREW_PACKAGES` - CLI tools and development libraries (installed via `brew install`)
- `CASK_PACKAGES` - GUI applications (installed via `brew install --cask`)
- `PACKAGES` - Auto-generated combined list (DO NOT EDIT MANUALLY)

### Commands

```bash
# Normal installation
./scripts/setup-osx.sh

# Check package status
./scripts/setup-osx.sh check 
./scripts/setup-osx.sh --check

# Validate package configuration
./scripts/setup-osx.sh validate

# List all packages with status
./scripts/setup-osx.sh list 
./scripts/setup-osx.sh ls

# Dry run mode
DRY_RUN=true ./scripts/setup-osx.sh
```

### Core Functions

#### Package Detection
- `is_brew_package_installed(package)` - Check if a regular package is installed
- `is_cask_installed(package)` - Check if a cask is installed  
- `is_package_installed(package)` - Auto-detect package type and check installation

#### Status Reporting
- `get_package_info(package)` - Get detailed package information with type detection
- `list_packages()` - List all packages with their current status

#### Validation
- `validate_package_config()` - Validate configuration consistency and detect issues

## Linux/Debian/Ubuntu Setup

### Package Arrays

- `APT_PACKAGES_BASE` - Base CLI tools and development libraries (installed via `apt install`)
- `APT_PACKAGES` - Extended APT packages (can be customized per setup)
- `APT_PACKAGES_PI` - Raspberry Pi specific packages
- `SPECIAL_PACKAGES_BASE` - Packages requiring custom installation (nvm, pyenv, tailscale, etc.)
- `SPECIAL_PACKAGES` - Extended special packages
- `GUI_PACKAGES` - GUI applications
- `PACKAGES` - Auto-generated combined list (DO NOT EDIT MANUALLY)

### Distribution Detection

The Linux setup automatically detects:
- Distribution (Debian/Ubuntu)
- Distribution version and codename
- Architecture (amd64, arm64, etc.)

### Commands

```bash
# Normal installation
./scripts/setup-linux.sh

# Check package status
./scripts/setup-linux.sh check 
./scripts/setup-linux.sh --check

# List all packages with status
./scripts/setup-linux.sh list 
./scripts/setup-linux.sh ls

# Dry run mode
DRY_RUN=true ./scripts/setup-linux.sh
```

### Core Functions

#### Package Detection
- `is_apt_package_installed(package)` - Check if an APT package is installed
- `is_command_available(command)` - Check if a command is available
- `is_tailscale_installed()` - Check if Tailscale is installed

#### Status Reporting
- `get_package_info(package)` - Get detailed package information with type detection
- `list_packages()` - List all packages with their current status

#### Distribution Detection
- `_detect_distribution()` - Automatically detects distribution, version, codename, and architecture
- `_is_apt_available()` - Checks if APT is available and distribution is supported

## Raspberry Pi Setup

The Raspberry Pi setup (`setup/setup-debian-pi.sh`) includes:
- All base Linux packages
- Docker CE and related tools
- Development tools (Node.js, GitHub CLI, 1Password CLI)
- Desktop applications (if desktop environment is present)
- System services (NFS, UFW firewall)
- Supporting libraries

### Usage

```bash
# Run Raspberry Pi setup
./scripts/setup/setup-debian-pi.sh
```

## Adding New Packages

### macOS

1. Add to the appropriate array in `packages-osx.sh`:
   ```bash
   # For CLI tools
   BREW_PACKAGES=(
       "existing-package"
       "new-cli-tool"    # Description of what this tool does
   )
   
   # For GUI applications
   CASK_PACKAGES=(
       "existing-app"
       "new-gui-app"     # Description of what this app does
   )
   ```

2. The package will automatically be:
   - Added to the combined `PACKAGES` array
   - Installed by `setup-osx.sh`
   - Included in status checks and validation

3. Validate your changes:
   ```bash
   ./setup-osx.sh validate
   ```

### Linux/Debian/Ubuntu

1. Add to the appropriate array in `scripts/setup/packages-linux.sh`:
   ```bash
   # For standard APT packages
   APT_PACKAGES_BASE=(
       "existing-package"
       "new-package"    # Description of what this package does
   )
   
   # For packages requiring custom installation
   SPECIAL_PACKAGES_BASE=(
       "existing-special"
       "new-special"    # Description (e.g., tailscale, nvm, etc.)
   )
   
   # For Raspberry Pi specific packages
   APT_PACKAGES_PI=(
       "pi-specific-package"
   )
   ```

2. If the package requires custom installation logic, add it to the setup script:
   - `scripts/setup-linux.sh` for general Linux packages
   - `scripts/setup/setup-debian-pi.sh` for Pi-specific packages

3. The package will automatically be:
   - Added to the combined `PACKAGES` array
   - Installed by the appropriate setup script
   - Included in status checks

## Key Features

### macOS
- ✅ **Automatic array synchronization** - `PACKAGES` is auto-generated from `BREW_PACKAGES` + `CASK_PACKAGES`
- ✅ **Input validation** - All functions validate inputs and check Homebrew availability
- ✅ **Error handling** - Proper error messages and exit codes
- ✅ **Configuration validation** - Detect duplicates, overlaps, and inconsistencies
- ✅ **Type detection** - Functions can determine if a package is brew or cask
- ✅ **Categorized reporting** - Missing packages are grouped by type

### Linux
- ✅ **Automatic distribution detection** - Detects Debian/Ubuntu, version, codename, and architecture
- ✅ **Cross-distribution support** - Works on both Debian and Ubuntu
- ✅ **Architecture-aware** - Automatically handles different architectures (amd64, arm64, etc.)
- ✅ **Package type detection** - Distinguishes between APT packages, special packages, and GUI packages
- ✅ **Flexible package arrays** - Base packages can be extended for specific use cases (e.g., Raspberry Pi)

## Error Prevention

The configuration prevents common issues:

- **Duplicate packages** - Validation detects duplicates within arrays
- **Package overlap** - Prevents packages appearing in multiple arrays
- **Manual sync errors** - `PACKAGES` is auto-generated, eliminating sync issues
- **Missing package managers** - Functions check for Homebrew/APT availability
- **Invalid inputs** - All functions validate their parameters
- **Distribution compatibility** - Linux scripts verify distribution support

## Example Output

### macOS
```bash
$ ./setup-osx.sh list
📦 Package Configuration:

🍺 Brew Packages (13):
git                  (brew)  ✅ installed
1password-cli        (brew)  ✅ installed
nvm                  (brew)  ✅ installed
...

📱 Cask Packages (10):
cursor               (cask)  ❌ missing
docker               (cask)  ❌ missing
google-chrome        (cask)  ❌ missing
...

📊 Total: 23 packages
```

### Linux
```bash
$ ./setup-linux.sh list
📦 Package Configuration for debian 12 (bookworm) (arm64):

📦 APT Packages (15):
git                  (apt)   ✅ installed
curl                 (apt)   ✅ installed
neovim               (apt)   ❌ missing
...

🔧 Special Packages (10):
tailscale            (special) ❌ missing
nvm                  (special) ❌ missing
...

📊 Total: 25 packages
```

## Special Package Installation

Some packages require custom installation methods:

### Tailscale
- **macOS**: Installed via Homebrew cask (includes GUI)
- **Linux**: Installed via official Tailscale script
  ```bash
  curl -fsSL https://tailscale.com/install.sh | sh
  sudo tailscale up
  sudo systemctl enable --now tailscaled
  ```

### Node.js
- **macOS**: Installed via nvm (installed via Homebrew)
- **Linux**: Installed via NodeSource repository or nvm

### Development Tools
- **nvm**: Node Version Manager (script-based installation)
- **pyenv**: Python version management (git-based installation)
- **rust**: Rust programming language (rustup installer)
- **mise**: Runtime version manager (script-based installation)
- **devbox**: Devbox (script-based installation)

## Notes

- All setup scripts support `DRY_RUN=true` for testing without making changes
- Linux setup scripts require `sudo` privileges for package installation
- Some packages may require manual configuration after installation (e.g., Tailscale authentication)
- Raspberry Pi setup includes additional packages and services specific to Pi use cases