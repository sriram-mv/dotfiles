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
  ".config/ghostty"
  ".local/bin/tmux-sessionizer"
)

echo "==> Pulling in submodules (fishline, etc.)"
git -C "$DOTFILES" submodule update --init --recursive

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

# Homebrew (Apple Silicon, Intel mac, or Linux)
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
  echo "==> Homebrew not found, installing"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

if command -v brew >/dev/null 2>&1; then
  echo "==> Installing brew packages from brew-leaves.txt"
  xargs brew install < "$DOTFILES/brew-leaves.txt"

  echo "==> Installing rustup and a Nerd Font for fishline"
  brew install rustup
  brew install --cask font-meslo-lg-nerd-font

  # Homebrew's rustup is keg-only and doesn't create ~/.cargo/env(.fish) the
  # way a classic rustup-init install does, but .zshrc and conf.d/rustup.fish
  # both source them unconditionally on every shell startup.
  RUSTUP_BIN="$(brew --prefix rustup)/bin"
  mkdir -p "$HOME/.cargo"
  if [ ! -f "$HOME/.cargo/env" ]; then
    cat > "$HOME/.cargo/env" <<EOF
#!/bin/sh
case ":\${PATH}:" in
    *:"$RUSTUP_BIN":*)
        ;;
    *)
        export PATH="$RUSTUP_BIN:\$PATH"
        ;;
esac
EOF
  fi
  if [ ! -f "$HOME/.cargo/env.fish" ]; then
    cat > "$HOME/.cargo/env.fish" <<EOF
if not contains "$RUSTUP_BIN" \$PATH
    set -gx PATH "$RUSTUP_BIN" \$PATH
end
EOF
  fi

  PATH="$RUSTUP_BIN:$PATH" rustup default stable
else
  echo "==> Homebrew install failed or skipped; run brew steps manually later"
fi

echo ""
echo "==> Done."
echo "    - Set your email in ~/.gitconfig"
echo "    - Install tmux plugins (TPM): prefix + I inside tmux"
