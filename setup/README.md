# Package Configuration

This directory contains shared configuration files used by both the setup script and tests.

## Files

### `packages.sh`
Contains the list of packages to install and functions for package management.

## Package Arrays

- `BREW_PACKAGES` - CLI tools and development libraries (installed via `brew install`)
- `CASK_PACKAGES` - GUI applications (installed via `brew install --cask`)
- `PACKAGES` - Auto-generated combined list (DO NOT EDIT MANUALLY)

## Core Functions

### Package Detection
- `is_brew_package_installed(package)` - Check if a regular package is installed
- `is_cask_installed(package)` - Check if a cask is installed  
- `is_package_installed(package)` - Auto-detect package type and check installation

### Status Reporting
- `get_package_info(package)` - Get detailed package information with type detection
- `list_packages()` - List all packages with their current status

### Validation
- `validate_package_config()` - Validate configuration consistency and detect issues

## Setup Script Commands

```bash
# Normal installation
./setup-osx.sh

# Check package status
./setup-osx.sh check 
./setup-osx.sh --check

# Validate package configuration
./setup-osx.sh validate

# List all packages with status
./setup-osx.sh list 
./setup-osx.sh ls

# Dry run mode
DRY_RUN=true ./setup-osx.sh
```

## Usage

### In setup-osx.sh
```bash
source "$(dirname "$0")/config/packages.sh"
```

### In test files
```bash
source "config/packages.sh"
```

## Key Improvements

- ✅ **Automatic array synchronization** - `PACKAGES` is auto-generated from `BREW_PACKAGES` + `CASK_PACKAGES` + `NODE_PACKAGES`
- ✅ **Input validation** - All functions validate inputs and check Homebrew availability
- ✅ **Error handling** - Proper error messages and exit codes
- ✅ **Configuration validation** - Detect duplicates, overlaps, and inconsistencies
- ✅ **Detailed documentation** - Each package has inline comments explaining its purpose
- ✅ **Type detection** - Functions can determine if a package is brew or cask
- ✅ **Categorized reporting** - Missing packages are grouped by type
- ✅ **Quiet mode** - Status checks can run with minimal output

## Adding New Packages

1. Add to the appropriate array in `packages.sh`:
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

   # For Node packages
   NODE_PACKAGES=(
       "existing-node-package"
       "new-node-package"     # Description of what this node package does
   )
   ```

2. The package will automatically be:
   - Added to the combined `PACKAGES` array
   - Installed by `setup-osx.sh`
   - Tested by the bats test suite
   - Included in status checks and validation

3. Validate your changes:
   ```bash
   ./setup-osx.sh validate
   ```

## Error Prevention

The refactored configuration prevents common issues:

- **Duplicate packages** - Validation detects duplicates within arrays
- **Package overlap** - Prevents packages appearing in both brew and cask arrays
- **Manual sync errors** - `PACKAGES` is auto-generated, eliminating sync issues
- **Missing Homebrew** - Functions check for Homebrew availability
- **Invalid inputs** - All functions validate their parameters

## Example Output

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