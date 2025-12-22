source "./shared.sh"

sudo mkdir -p $HOME/.local/share/konsole/
curl -Lo konsole-catppuccin-mocha.colorscheme https://raw.githubusercontent.com/catppuccin/konsole/refs/heads/main/themes/catppuccin-mocha.colorscheme
sudo rm -rf $HOME/.local/share/konsole/catppuccin-mocha.colorscheme
ln -sf "$rice_directory/konsole-catppuccin-mocha.colorscheme" $HOME/.local/share/konsole/catppuccin-mocha.colorscheme
sudo rm -rf $HOME/.local/share/konsole/fish.profile
ln -sf "$rice_directory/configs/konsole-fish.profile" $HOME/.local/share/konsole/fish.profile
kwriteconfig6 --file konsolerc --group "Desktop Entry" --key DefaultProfile "fish.profile"
