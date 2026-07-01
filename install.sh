#!/usr/bin/env bash
#
# Bootstrap dotfiles into $HOME. Backs up any existing files first.
#
# Order matters: every external tool the configs depend on (Homebrew
# packages, rustup, oh-my-zsh, fishline, TPM, borders) is installed *before*
# any dotfile is symlinked, so nothing sources a tool that isn't there yet.
# TPM's plugin install and starting the borders service are exceptions -
# both read config files that only exist after the symlink step.
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
  ".config/borders"
  ".local/bin/tmux-sessionizer"
)

### --- Phase 1: install tools -----------------------------------------

echo "==> Pulling in submodules (fishline, etc.)"
git -C "$DOTFILES" submodule update --init --recursive

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

  if [ "$(uname)" = "Darwin" ]; then
    echo "==> Installing borders (focused-window halo)"
    brew tap FelixKratz/formulae
    brew trust --tap FelixKratz/formulae
    brew install borders
  fi
else
  echo "==> Homebrew install failed or skipped; run brew/rustup/font steps manually later"
fi

echo "==> Installing oh-my-zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "==> Installing TPM (tmux plugin manager)"
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

### --- Phase 2: link dotfiles -------------------------------------------

echo "==> Linking dotfiles from $DOTFILES"
for rel in "${FILES[@]}"; do
  src="$DOTFILES/$rel"
  dst="$HOME/$rel"
  [ -e "$src" ] || continue
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "    already linked $rel"
    continue
  fi
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

### --- Phase 3: populate tmux plugins (needs ~/.tmux.conf linked above) -

if command -v tmux >/dev/null 2>&1 && [ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
  echo "==> Installing tmux plugins via TPM"
  tmux start-server
  tmux source-file "$HOME/.tmux.conf"
  "$HOME/.tmux/plugins/tpm/bin/install_plugins"
fi

if command -v brew >/dev/null 2>&1 && brew list borders >/dev/null 2>&1; then
  echo "==> Starting borders"
  brew services start felixkratz/formulae/borders
fi

echo ""
echo "==> Done."
echo "    - Set your email in ~/.gitconfig"
