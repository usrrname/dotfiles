# Linux specific zshrc

# Load fnm (Fast Node Manager)
eval "$(fnm env --use-on-cd)"

# uv
eval "$(uv generate-shell-completion zsh)"

# nvim
export PATH="/opt/nvim/bin:$PATH"
