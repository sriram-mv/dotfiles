# Homebrew (Apple Silicon, Intel mac, or Linux)
if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
else if test -x /usr/local/bin/brew
    eval (/usr/local/bin/brew shellenv)
else if test -x /home/linuxbrew/.linuxbrew/bin/brew
    eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
end

# Handle Ghostty terminal compatibility
if test "$TERM" = "xterm-ghostty"
    set -gx TERM xterm-256color
end

# Fishline prompt
if status is-interactive
    set FLINE_PATH $HOME/.config/fish/fishline
    test -f $FLINE_PATH/init.fish; and source $FLINE_PATH/init.fish
end

alias v='nvim'

# Vi key bindings (enables N/V/I mode; shown via fishline's VFISH segment)
set -g fish_key_bindings fish_vi_key_bindings

# zoxide (smarter cd)
if command -v zoxide >/dev/null 2>&1
    zoxide init fish | source
end

# pyenv
if test -d $HOME/.pyenv/bin
    set -gx PATH $HOME/.pyenv/bin $PATH
end
