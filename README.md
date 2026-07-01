# dotfiles

Personal config for fish, zsh, tmux, neovim, Ghostty, and git, plus a
bootstrap script that sets up a new machine from scratch.

## Quick start

```sh
git clone https://github.com/sriram-mv/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` is safe to re-run any time — every step is idempotent, and it
backs up any pre-existing non-symlink file it would otherwise overwrite to
`~/.dotfiles-backup-<timestamp>/`.

## What `install.sh` does

1. **Pulls submodules** — currently just [fishline](https://github.com/0rax/fishline),
   the fish prompt framework.
2. **Installs tools**, in order:
   - Homebrew (if missing)
   - everything in `brew-leaves.txt` (fish, neovim, tmux, ripgrep, fzf, etc.)
   - `rustup` + the stable Rust toolchain (Homebrew's `rustup` is keg-only
     and doesn't create `~/.cargo/env`/`env.fish` the way a classic
     `rustup-init` install does, so this script generates them itself)
   - the MesloLGS Nerd Font (needed for fishline's glyphs)
   - oh-my-zsh
   - TPM (tmux plugin manager)
3. **Symlinks dotfiles** into `$HOME` (see list below).
4. **Installs tmux plugins** via TPM — this runs last because it reads
   `~/.tmux.conf`, which only exists after step 3.

## What's tracked here

| Path | Purpose |
|---|---|
| `.config/fish/` | fish config, functions, and the `fishline` prompt (submodule) |
| `.config/nvim/` | Neovim config (Lua) |
| `.config/mise/` | [mise](https://mise.jdx.dev) tool-version config (Python, etc.) |
| `.config/ghostty/` | Ghostty terminal config — Catppuccin Mocha theme, Nerd Font |
| `.tmux.conf` | tmux config — Ctrl+s prefix, vi copy-mode, catppuccin theme, session persistence via resurrect/continuum |
| `.zshrc` / `.bashrc` / `.bash_profile` | shell configs; `.zshrc` execs into fish for interactive sessions |
| `.gitconfig` | git config (**set your email after installing**, see below) |
| `.local/bin/tmux-sessionizer` | fuzzy project-session switcher, bound to `prefix + o` in tmux |
| `brew-leaves.txt` | list of Homebrew formulae installed by `install.sh` |

## Manual steps after installing

- **Set your git email**: `git config --global user.email you@example.com`
  (or edit `.gitconfig` directly).
- **Set Ghostty's font**: the config sets `font-family`, but if Ghostty was
  already running before the font got installed, quit and reopen it (or
  `Cmd+Shift+,` to reload config) to pick it up.
- **tmux plugins**: `install.sh` runs TPM for you, but if you ever add a new
  `@plugin` line to `.tmux.conf`, install it with `prefix + I` inside tmux.

## Auth for pushing

This repo's remote is over SSH (`git@github.com:sriram-mv/dotfiles.git`).
On a new machine you'll need an SSH key added to your GitHub account:

```sh
ssh-keygen -t ed25519 -C "you@example.com"
# paste ~/.ssh/id_ed25519.pub into github.com/settings/keys
```
