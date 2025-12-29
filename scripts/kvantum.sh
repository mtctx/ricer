source "$1/scripts/shared.sh" "$1"

cpmm_kvantum_dir="$(cpmm_kvantum)"

echo "Downloading Kvantum Catppuccin Mocha Mauve theme..."
sudo rm -rf "$cpmm_kvantum_dir"
mkdir -p "$cpmm_kvantum_dir/catppuccin-mocha-mauve"
curl -LO --output-dir "$cpmm_kvantum_dir/catppuccin-mocha-mauve" https://raw.githubusercontent.com/catppuccin/kvantum/refs/heads/main/themes/catppuccin-mocha-mauve/catppuccin-mocha-mauve.kvconfig
curl -LO --output-dir "$cpmm_kvantum_dir/catppuccin-mocha-mauve" https://github.com/catppuccin/kvantum/raw/refs/heads/main/themes/catppuccin-mocha-mauve/catppuccin-mocha-mauve.svg

echo "Installing and applying Kvantum theme..."
mkdir -p "$HOME/.config/Kvantum/catppuccin-mocha-mauve"
ln -sf "$cpmm_kvantum_dir/catppuccin-mocha-mauve" "$HOME/.config/Kvantum/catppuccin-mocha-mauve"
kvantummanager --set catppuccin-mocha-mauve
