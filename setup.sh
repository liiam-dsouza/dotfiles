#!/bin/bash

set -e # Exit immediately on error

# ── Colours ──────────────────────────────────────────────
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ── Helpers ──────────────────────────────────────────────
info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ── Config ───────────────────────────────────────────────
DOTFILES_DIR="$HOME/dotfiles"
DOTFILES_REPO="git@github.com:liiam-dsouza/dotfiles.git"

# ── Xcode CLI Tools ──────────────────────────────────────
info "Checking for Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
	info "Xcode CLI Tools not found. Installing..."
	xcode-select --install
	# Wait until the tools are installed
	until xcode-select -p &>/dev/null; do
		sleep 5
	done
	success "Xcode CLI Tools installed."
else
	success "Xcode CLI Tools already installed."
fi

# ── Homebrew ─────────────────────────────────────────────
info "Checking for Homebrew..."
if ! command -v brew &>/dev/null; then
	info "Homebrew not found. Installing..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

	# Add Homebrew to PATH for the current session
	if [[ -f "/opt/homebrew/bin/brew"]] then
		eval "$(/opt/homebrew/bin/brew shellenv)"
	fi

	success "Homebrew installed."
else
	success "Homebrew already installed."
fi

info "Updating Homebrew..."
brew update

# ── Git Config ───────────────────────────────────────────
info "Configuring Git..."
git config --global core.excludesfile ~/.gitignore_global
success "Git configured."

# ── Homebrew Formulae ────────────────────────────────────
info "Installing Homebrew formulae..."
xargs brew install <<EOF
bat
borders
btop
docker
fastfetch
fd
fresh-editor
fzf
gh
git-delta
jless
jq
lazydocker
lazygit
lsd
neovim
nmap
nvm
pandoc
pipx
pnpm
posting
pyenv
python-lsp-server
ripgrep
stow
superfile
thefuck
tig
tldr
tmux
typescript
typescript-language-server
w3m
wget
zoxide
EOF

success "Homebrew formulae installed."

# ── Homebrew Casks ───────────────────────────────────────
info "Installing Homebrew casks..."
xargs brew install --cask <<EOF
aerospace
aldente
basictex
claude
claude-code
cleanmymac
cleanshot
discord
docker-desktop
font-jetbrains-mono-nerd-font
hiddenbar
kitty
raycast
rectangle
stats
visual-studio-code
zen
EOF

success "Homebrew casks installed."

# ── Python ───────────────────────────────────────────────
info "Setting up Python via pyenv..."

# Initialise pyenv in current shell session so it can be used
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"

# Install and set latest stable Python 3.13 as global default
PYTHON_VERSION="3.13"
PYTHON_FULL=$(pyenv install --list | grep -E "^\s+${PYTHON_VERSION}\.[0-9]+$" | tail -1 | tr -d '[:space:]')

if pyenv versions | grep -q "$PYTHON_FULL"; then
	info "Python $PYTHON_FULL already installed, skipping..."
else
	info "Installing Python $PYTHON_FULL..."
	pyenv install "$PYTHON_FULL"
fi

pyenv global "$PYTHON_FULL"
success "Python $PYTHON_FULL set as global default."

# ── Node ─────────────────────────────────────────────────
info "Setting up Node.js via nvm..."

# Initialise nvm in current shell session so it can be used
export NVM_DIR="$HOME/.nvm"
source "$(brew --prefix nvm)/nvm.sh"

# Install latest LTS Node version and set as default
nvm install --lts
nvm alias default lts/*
success "Node.js LTS $(node --version) installed and set as default."

# ── SSH Keys ─────────────────────────────────────────────
info "Setting up SSH keys..."

generate_key() {
	local name=$1
	local comment=$2
	local path="$HOME/.ssh/$name"

	if [[ -f "$path" ]]; then
		warn "Key $name already exists, skipping..."
	else
		info "Generating SSH key $name..."
		ssh-keygen -t ed25519 -C "$comment" -f "$path" -N ""
		ssh-add --apple-use-keychain "$path"
		success "Generated $name."
	fi
}

generate_key "id_github"      "github"
generate_key "id_remotes"     "remotes"

# Prompt user to add GitHub key before attempting SSH clone
echo ""
echo -e "${YELLOW}┌─────────────────────────────────────────────────────┐${NC}"
echo -e "${YELLOW}│  Action required: add your GitHub SSH key           │${NC}"
echo -e "${YELLOW}└─────────────────────────────────────────────────────┘${NC}"
echo ""
echo "Copy the public key below and add it at:"
echo "https://github.com/settings/ssh/new"
echo ""
cat "$HOME/.ssh/id_github.pub"
echo ""
read -rp "Have you added the key to GitHub? (y/n): " ssh_ready

# ── VSCode Extensions ────────────────────────────────────
info "Installing VSCode extensions..."

export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

xargs code --install-extension <<EOF
adpyke.codesnap
bradlc.vscode-tailwindcss
catppuccin.catppuccin-vsc
catppuccin.catppuccin-vsc-icons
formulahendry.auto-rename-tag
github.copilot
james-yu.latex-workshop
subframe7536.custom-ui-style
EOF

success "VSCode extensions installed."

# ── Dotfiles ─────────────────────────────────────────────
info "Setting up dotfiles..."

if [[ -d "$DOTFILES_DIR" ]]; then
	warn "Dotfiles directory already exists at $DOTFILES_DIR, skipping clone."
else
	info "Cloning dotfiles repository..."

	# Use SSH if possible, otherwise fallback to HTTPS
	if [[ "$ssh_ready" =~ ^[Yy]$ ]] && ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    	git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  	else
    	warn "Falling back to HTTPS clone (you can re-add the remote over SSH later)..."
    	HTTPS_REPO="${DOTFILES_REPO/git@github.com:/https:\/\/github.com\/}"
    	git clone "$HTTPS_REPO" "$DOTFILES_DIR"
  	fi

	success "Dotfiles cloned to $DOTFILES_DIR."
fi

info "Stowing dotfiles..."
cd "$DOTFILES_DIR"
stow .
success "Dotfiles stowed."

# ── Done ─────────────────────────────────────────────────
echo ""
echo -e "${GREEN}Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal (or source ~/.zshrc)"
echo "  2. Review your dotfiles and customize as needed"
if [[ ! "$ssh_ready" =~ ^[Yy]$ ]]; then
  echo "  3. Add your GitHub SSH key: cat ~/.ssh/id_github.pub"
  echo "     Then update your dotfiles remote: git -C ~/dotfiles remote set-url origin $DOTFILES_REPO"
fi
