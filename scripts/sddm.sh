source "./shared.sh"

if sudo pacman -Q sddm &>/dev/null && systemctl is-active sddm; then
    yay -S --needed qt6-svg qt6-declarative qt5-quickcontrols2

    sudo mkdir -p /usr/share/sddm/themes/
    sudo rm -rf /usr/share/sddm/themes/catppuccin-mocha-mauve/
    rm -rf "$cpmm_sddm"

    echo "Downloading Catppuccin SDDM theme..."
    latest_tag=$(curl -s https://api.github.com/repos/catppuccin/sddm/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
    curl -Lo "$cpmm_sddm.zip" "https://github.com/catppuccin/sddm/releases/download/$latest_tag/catppuccin-mocha-mauve-sddm.zip"
    unzip "$cpmm_sddm.zip" -d "$cppm_sddm"
    sudo rm -rf "/usr/share/sddm/themes/catppuccin-mocha-mauve"
    ln -sf "$cpmm_sddm" "/usr/share/sddm/themes/catppuccin-mocha-mauve"
    rm -rf "$cpmm_sddm.zip"

    for file in /etc/sddm.conf.d/kde_settings.conf /etc/sddm.conf; do
        if [[ -f $file ]]; then
            sudo sed -i "s/Current=.*/Current=catppuccin-mocha-mauve/" "$file"
            break
        fi
    done
else
    echo "SDDM is not installed or inactive -> Skipping SDDM theme setup."
fi