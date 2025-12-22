source "./shared.sh"

if ! sudo chsh "$USER" -s /usr/bin/fish; then
    if grep -q "^$USER:" /etc/passwd | grep -q "/usr/bin/fish$"; then
        echo "Shell is already set to Fish – continuing."
    else
        echo "Failed to change shell to Fish." >&2
        exit 1
    fi
fi

echo "Copying fish config"
sudo rm -rf $HOME/.config/fish
sudo mkdir -p $HOME/.config/fish/
ln -sf "$rice_directory/configs/config.fish" $HOME/.config/fish/config.fish

echo "Installing fisher and plugins"
/usr/bin/fish -c '
    # Install fisher if not present
    yay -S --needed --noconfirm fisher

    # Install plugins
    fisher install catppuccin/fish
    fisher install reitzig/sdkman-for-fish
    fisher install jorgebucaran/autopair.fish
    fisher install patrickf1/fzf.fish
    fisher install joseluisq/gitnow

    # Set theme
    fish_config theme save "Catppuccin Mocha"
'