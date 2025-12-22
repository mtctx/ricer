source "./shared.sh"

echo "Copying Fastfetch config"
sudo mkdir -p $HOME/.config/fastfetch/
sudo rm -rf $HOME/.config/fastfetch/config.jsonc
ln -sf "$rice_directory/configs/fastfetch.jsonc" $HOME/.config/fastfetch/config.jsonc