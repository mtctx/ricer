# ~/.config/fish/config.fish
# ----------------------------------
# Hide default Fish welcome message
set -U fish_greeting ""

# Run fastfetch on interactive shells
if status is-interactive
    fastfetch
    echo ""
end

# Better command history search with arrow keys
bind \e\[A history-search-backward
bind \e\[B history-search-forward

# Aliases
alias updatemirrors "sudo reflector -c Germany -c Switzerland -c Denmark -c Netherlands -c France -c Austria -c Luxembourg -c Belgium  --latest 80 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist"
alias rmrf "rm -rf"
alias pacman "sudo pacman"
alias cd z

# Catppuccin Mocha colors
set mocha_mauve "#cba6f7"
set mocha_green "#a6e3a1"
set mocha_blue "#89b4fa"
set mocha_text "#cdd6f4"
set mocha_peach "#fab387"

zoxide init fish | source

function fish_prompt
    # Line 1: [user@host] [cwd] [git branch]
    set_color $mocha_mauve
    echo -n (whoami)

    set_color $mocha_text
    echo -n "@"

    set_color $mocha_mauve
    echo -n (string split '.' $hostname)[1]

    set_color $mocha_text
    echo -n " in "

    set_color $mocha_green
    echo -n (string replace "/home/$USER" "~" (pwd))

    # Git branch
    set branch (git symbolic-ref --short HEAD ^/dev/null 2>/dev/null)
    if test -n "$branch"
        set_color $mocha_text
        echo -n " on "
        set_color $mocha_blue
        echo -n $branch
    end

    # New line + prompt symbol
    echo ""
    set_color $mocha_peach
    echo -n "❯ "
    set_color normal
end
