# dotfiles

Dotfiles setup with:
- [stow](https://www.gnu.org/software/stow/) - Dotfile symlinking
- [Nix](https://nixos.org/) + [Home Manager](https://nix-community.github.io/home-manager/) - Package management
- [direnv](https://direnv.net) - Environment variable management

## Supported Systems

| System | Package Manager | Dotfiles |
|--------|---------------|----------|
| **NixOS** | Nix (flake) | stow |
| **Linux/Debian** | Home Manager | stow |
| **Raspberry Pi** | Home Manager | stow |
| **macOS** | Homebrew | stow |

---

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 2. Install Packages

#### NixOS

```bash
# Enable flakes (if not already enabled)
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Apply configuration (includes Home Manager automatically)
sudo nixos-rebuild switch --flake .#nixos
```


> **Note**: The NixOS configuration is in `hosts/nixos/configuration.nix`. Using flakes, you do NOT need to copy it to `/etc/nixos/` - it is read directly from your dotfiles directory.

#### Linux (Debian/Ubuntu/Raspberry Pi)

```bash
# Install Nix (single-user)
sh <(curl -L https://nixos.org/nix/install) --no-daemon

# Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Apply configuration
home-manager switch --flake .#linux

# For Raspberry Pi (aarch64)
home-manager switch --flake .#pi
```

#### macOS

```bash
# Install Nix via Homebrew
brew install nix

# Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Apply Home Manager (optional - can also use brew)
home-manager switch --flake .#darwin

# Or use Homebrew for packages
./setup.sh
```

### 3. Link Dotfiles

```bash
# Stow dotfiles (auto-detects OS)
./stow-dotfiles.sh
```

---

## Package Management

### Nix/Home Manager (Linux/NixOS/RPi)

Packages are defined in:
- `linux/home.nix` - Main package list
- `flake.nix` - NixOS configuration

To add packages, edit `linux/home.nix`:

```nix
home.packages = with pkgs; [
  git
  curl
  wget
  neovim
  # add more packages here
];
```

### Homebrew (macOS)

```bash
# Add packages to setup-osx.md or use brew directly
brew install <package>
```

---

## Stow Directory Structure

```
stow/
├── common/       # Shared across all OSes (bash, git, nvim, etc.)
├── macos/       # macOS-specific (zsh, cursor, iterm2, etc.)
├── linux/       # Linux-specific (zsh config)
└── pi/          # Raspberry Pi-specific (zsh config)
```

The `stow-dotfiles.sh` script automatically stows the correct packages for your OS.

---

## Updating

### Pull Updates

```bash
git pull

# Rebuild Nix configurations
home-manager switch --flake .#linux

# Re-stow dotfiles
./stow-dotfiles.sh
```

---

## Troubleshooting

### Nix/Home Manager

```bash
# Check what's installed
home-manager packages

# Dry-run (see changes without applying)
home-manager switch --flake .#linux --dry-run

# List available packages
nix search nixpkgs <package-name>
```

### Stow

```bash
# Verify symlinks
ls -la ~ | grep "\->"

# Restow specific package
stow -R <package-name>
```

---

## Additional Tools

### LazyVim

```bash
# Build plugins
nvim --headless -c "Lazy sync" -c "qa"

# Clean and reinstall
nvim --headless -c "lua require('lazy').clean()" -c "lua require('lazy').sync()" -c "qa"
```

### 1Password CLI

```bash
# Read secret
op read op://vault/item/field
```

### Devbox

```bash
devbox add <package>
devbox shell
```
