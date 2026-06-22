#!/usr/bin/env bash
#
# Bootstrap dotfiles into $HOME. Backs up any existing files first.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Files/dirs to link, relative to repo root and $HOME.
FILES=(
  ".tmux.conf"
  ".zshrc"
  ".bashrc"
  ".bash_profile"
  ".gitconfig"
  ".config/nvim"
  ".config/fish"
  ".config/mise"
  ".local/bin/tmux-sessionizer"
)

echo "==> Installing dotfiles from $DOTFILES"
for rel in "${FILES[@]}"; do
  src="$DOTFILES/$rel"
  dst="$HOME/$rel"
  [ -e "$src" ] || continue
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mkdir -p "$BACKUP/$(dirname "$rel")"
    mv "$dst" "$BACKUP/$rel"
    echo "    backed up existing $rel -> $BACKUP/$rel"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
  echo "    linked $rel"
done

chmod +x "$HOME/.local/bin/tmux-sessionizer" 2>/dev/null || true

echo ""
echo "==> Done."
echo "    - Set your email in ~/.gitconfig"
echo "    - Install brew packages: xargs brew install < brew-leaves.txt"
echo "    - Install tmux plugins (TPM): prefix + I inside tmux"
