# Setup Scripts - Technical Reference

For usage instructions, see [README.md](README.md).

## Files Structure

```bash
├── setup.sh              # Unified setup (auto-detects OS)
├── stow-dotfiles.sh      # OS-aware stow (auto-detects OS)
├── update.sh             # Update script
└── scripts/
    ├── setup/
    │   ├── packages-osx.sh
    │   ├── packages-pi.sh
    │   └── packages-linux.sh
    └── setup-pi.sh
    ├── setup-osx.sh
    └── setup-linux.sh
```

## Package Arrays

### macOS (`packages-osx.sh`)
- `BREW_PACKAGES` - CLI tools (installed via `brew install`)
- `CASK_PACKAGES` - GUI applications (installed via `brew install --cask`)
- `PACKAGES` - Auto-generated (DO NOT EDIT)

### Linux (`packages-linux.sh`)
- `APT_PACKAGES_BASE` - Base CLI tools (installed via `apt install`)
- `APT_PACKAGES` - Extended APT packages
- `APT_PACKAGES_PI` - Raspberry Pi specific packages
- `SPECIAL_PACKAGES_BASE` - Custom installation required (nvm, pyenv, tailscale, etc.)
- `SPECIAL_PACKAGES` - Extended special packages
- `GUI_PACKAGES` - GUI applications
- `PACKAGES` - Auto-generated (DO NOT EDIT)

### Raspberry Pi (`packages-pi.sh`)
- `APT_PACKAGES_BASE` - Base CLI tools (installed via `apt install`)
- `APT_PACKAGES` - Extended APT packages
- `APT_PACKAGES_PI` - Raspberry Pi specific packages
- `SPECIAL_PACKAGES_BASE` - Custom installation required (nvm, pyenv, tailscale, etc.)
- `SPECIAL_PACKAGES` - Extended special packages
- `PACKAGES` - Auto-generated (DO NOT EDIT)

## Core Functions

### macOS Functions
- `is_brew_package_installed(package)` - Check if brew package installed
- `is_cask_installed(package)` - Check if cask installed
- `is_package_installed(package)` - Auto-detect and check
- `get_package_info(package)` - Get detailed package info
- `list_packages()` - List all packages with status
- `validate_package_config()` - Validate configuration

### Linux Functions
- `is_apt_package_installed(package)` - Check if APT package installed
- `is_command_available(command)` - Check if command available
- `is_tailscale_installed()` - Check if Tailscale installed
- `get_package_info(package)` - Get detailed package info
- `list_packages()` - List all packages with status
- `_detect_distribution()` - Auto-detect distro, version, codename, architecture
- `_is_apt_available()` - Check APT availability

## Adding New Packages

### macOS
1. Add to array in `scripts/setup/packages-osx.sh`:
   ```bash
   BREW_PACKAGES=("existing" "new-package")
   # or
   CASK_PACKAGES=("existing" "new-app")
   ```
2. Validate: `./setup.sh validate`

### Linux/Debian/Ubuntu
1. Add to appropriate array in `scripts/setup/packages-linux.sh`:
   ```bash
   APT_PACKAGES_BASE=("existing" "new-package")
   # or
   SPECIAL_PACKAGES_BASE=("existing" "new-special")
   # or
   APT_PACKAGES_PI=("pi-package")  # Raspberry Pi only
   ```
2. If custom installation needed, add logic to `scripts/setup-linux.sh`

## Key Features

**macOS:**
- Auto array sync (`PACKAGES` from `BREW_PACKAGES` + `CASK_PACKAGES`)
- Input validation & Homebrew checks
- Configuration validation (duplicates, overlaps)
- Type detection (brew vs cask)

**Linux:**
- Auto distribution detection (Debian/Ubuntu, version, codename, arch)
- Cross-distribution support
- Architecture-aware
- Package type detection (APT, special, GUI)

## Error Prevention

- Duplicate detection within arrays
- Package overlap prevention
- Auto-generated `PACKAGES` (no manual sync)
- Package manager availability checks
- Input validation
- Distribution compatibility verification

## Special Package Installation

**Tailscale:**
- macOS: Homebrew cask
- Linux: Official script (`curl -fsSL https://tailscale.com/install.sh | sh`)

**Development Tools:**
- `nvm` - Script-based
- `pyenv` - Git-based
- `rust` - rustup installer
- `mise` - Script-based
- `devbox` - Script-based

## Notes

- All scripts support `DRY_RUN=true`
- Linux scripts require `sudo` for package installation
- NixOS: `setup.sh` provides guidance, use `stow-dotfiles.sh` for dotfiles
- Raspberry Pi: Uses standard Linux setup, Pi-specific packages in `APT_PACKAGES_PI`
