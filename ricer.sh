#!/bin/bash

set -e

exit_dir_on_error() {
    cd $HOME || true
}

trap exit_dir_on_error ERR

clone() {
    local repo="$1"
    local out="$2"
    local remove="$3"

    remove=${remove:-false}

    if [[ $remove == true ]]; then
        rm -rf "$out"
    fi

    git clone -- "$repo" "$out" || {
        echo "Clone failed or incomplete" >&2
        rm -rf -- "$out"
        exit 1
    }
}

check_kde_version() {
    if [[ $(plasmashell --version 2>/dev/null | cut -d' ' -f2 | cut -d. -f1) != 6 ]]; then
        echo "Not KDE Plasma 6." >&2
        exit 1
    fi
}

check_kde_installed() {
    if ! command -v plasmashell >/dev/null 2>&1; then
        echo "KDE Plasma not installed." >&2
        check_kde_version
        exit 1
    fi
}

trim_indent() {
    local line min_indent=999999 indent content
    local -a lines=()

    # Read all lines into an array
    while IFS= read -r line; do
        lines+=("$line")
    done

    # Find minimum indent (ignore blank lines)
    for line in "${lines[@]}"; do
        if [[ $line =~ ^([[:space:]]*)(.*)$ ]]; then
            content=${BASH_REMATCH[2]}
            indent=${#BASH_REMATCH[1]}
            # Only consider non-blank lines
            [[ -n $content ]] && (( indent < min_indent )) && min_indent=$indent
        fi
    done

    # If no indent found, just output as-is
    (( min_indent == 999999 )) && min_indent=0

    # Output each line with min_indent removed
    for line in "${lines[@]}"; do
        printf '%s\n' "${line:min_indent}"
    done
}

trim_indent <<EOF
    Welcome to Ricer by mtctx (https://github.com/mtctx/rice)
    This shell script is exclusively for Arch-based Distros.
    Officially supported are CachyOS and Vanilla Arch.
    If you are on a different Arch-based Distro run this script with --trustmeiamonarch.

    Ricer will setup your KDE enviroment to use Catppuccin Mocha Mauve everywhere.
    What will Ricer setup?
    - KDE -> https://github.com/catppuccin/kde
    - Konsole -> https://github.com/catppuccin/konsole & https://github.com/mtctx/rice/blob/main/konsole-fish.profile
    - Kvantum -> https://github.com/tsujan/Kvantum/tree/master/Kvantum & https://github.com/catppuccin/kvantum
    - Fish shell -> https://github.com/catppuccin/fish & https://github.com/mtctx/rice/blob/main/config.fish & https://github.com/jorgebucaran/fisher
    - Fastfetch -> https://github.com/mtctx/rice/blob/main/fastfetch.jsonc

    Requirements:
    - KDE Plasma 6
    - QT 5 and/or 6
EOF

check_kde_installed
check_kde_version

sleep 1.25s

arch="ARCH"
cachyos="CACHYOS"

rice_directory="~/rice"
skip_os_check=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dir)
            rice_directory="$2"
            shift
        ;;
        --qt)
            if [[ -n "$2" && "$2" != -* ]]; then
                case "$2" in
                    "5")
                        export USE_QT5="true"
                    ;;
                    "6")
                    ;;
                    *)
                        echo "Defaulting to QT 6 for Where is my SDDM theme?."
                        echo "Version $2 is invalid. Accepted options: 5, 6"
                    ;;
                esac
                shift
            else
                echo "Error: --qt requires a value" >&2
                exit 1
            fi
        ;;
        --trustmeiamonarch)
            skip_os_check=true
            shift
        ;;
        -h|--help) 
            trim_indent <<EOF
                Usage: $0 [--dir PATH_TO_DIR] [--qt 5|6] [--trustmeiamonarch]
                
                Options:
                --dir: Set the directory to save all configs.
                --qt: Set the QT Version, either 5 or 6. Malformed input will default to QT 6
                --trustmeiamonarch: Skip the OS check (Use if you are on an different Arch-based distro and not on vanilla Arch or CachyOS)
EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
    shift
done

echo
echo "Storing all configs inside $rice_directory"

if [[ $USE_QT5 == "true" ]]; then
    echo "Using QT 5 for Where is my SDDM theme?."
else
    echo "Using QT 6 for Where is my SDDM theme?."
fi

echo

declare os
if [[ $skip_os_check == false ]]; then
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            arch)
                os="$arch"
                echo "Using Vanilla Arch"
                ;;
            cachyos)
                os="$cachyos"
                ;;
            *)
                echo "This is neither Arch nor CachyOS (ID: $ID)"
                exit 1
                ;;
        esac
    else
        echo "/etc/os-release not found – unable to detect distribution!"
        exit 1
    fi
else
    echo "Trust me flag detected, will skip the os check!"
fi

sudo -v

# Update System
echo "Updating system..."
sudo pacman -Syyu --noconfirm

# YAY Setup
if [[ $os == $cachyos ]]; then
    echo "Installing YAY via CachyOS AUR"
    sudo pacman -S --needed git base-devel yay --noconfirm
elif [[ $os == $arch || $skip_os_check == true ]]; then
    echo "Building YAY manually"
    sudo pacman -S --needed git base-devel --noconfirm
    clone https://aur.archlinux.org/yay.git true
    cd yay && makepkg -si
fi

# Install packages
declare ucode_package
cpu_info=$(grep -m 1 'vendor_id' /proc/cpuinfo)

if [[ "$cpu_info" == *"GenuineIntel"* ]]; then
    echo "Intel CPU detected"
    ucode_package="intel-ucode"
elif [[ "$cpu_info" == *"AuthenticAMD"* ]]; then
    echo "AMD CPU detected"
    ucode_package="amd-ucode"
else
    echo "Unknown CPU vendor"
    exit 1
fi

echo "Installing packages..."
yay -S --needed --noconfirm ab-download-manager alsa-firmware alsa-utils $ucode_package ark awesome-terminal-fonts base bluez-hid2hci bluez-utils brave-bin btop btrfs-assistant cantarell-fonts cpupower dmraid dolphin duf efibootmgr efitools ethtool fastfetch ffmpegthumbnailer fisher fsarchiver glances gwenview haruna haveged hdparm hwdetect hwinfo inetutils jfsutils kate kcalc kde-gtk-config kdeplasma-addons kleopatra kvantum  kwallet-pam libgsf libva-nvidia-driver  libwnck3 logrotate lsscsi man-pages meld mtools mullvad-vpn nano-syntax-highlighting netctl networkmanager-openvpn nfs-utils noto-color-emoji-fontconfig ntp octopi pavucontrol plasma-browser-integration plasma-firewall plasma-systemmonitor plasma-thunderbolt poppler-glib prismlauncher pv qt$([[ $USE_QT5 == "true" ]] && echo 5 || echo 6)-wayland rebuild-detector reflector sddm-kcm sg3_utils sof-firmware spectacle systemd-boot-manager ttf-jetbrains-mono-nerd ttf-meslo-nerd ttf-opensans vi vlc-plugins-all xl2tpd xorg-xinit xorg-xinput xorg-xkill zip zoxide unzip

# Setup folder
if [[ $rice_directory == ~* ]]; then
    rice_directory="${rice_directory/#\~/$HOME}"
fi

sudo rm -rf "$rice_directory"
mkdir -p "$rice_directory"
cd "$rice_directory"

# Contains config.fish, fastfetch.jsonc and brave-policies.json aswell as this script.
clone https://github.com/mtctx/rice.git "$rice_directory"

# Base Cattpuccin Setup
cpmm_prefix="CPMM"
cpmm_kde="$cpmm_prefix KDE"
cpmm_kvantum="$cpmm_prefix Kvantum"
cpmm_whereismysddmtheme="$cpmm_prefix Where is my SDDM theme.conf"

sudo touch ".$cpmm_prefix stands for Catppuccin Mocha Mauve"

# KDE
echo "Downloading KDE Catppuccin Mocha Mauve theme..."
sudo rm -rf "$cpmm_kde"
clone "https://github.com/catppuccin/kde.git" "$cpmm_kde" true

echo "Running KDE Catppuccin installer..."

sudo rm -rf $HOME/.local/share/kpackage/generic/Catppuccin-Mocha-Mauve
sudo rm -rf $HOME/.local/share/plasma/look-and-feel
sudo rm -rf $HOME/.local/share/plasma/look-and-feel/Catppuccin-Mocha-Mauve/contents
sudo rm -rf $HOME/.local/share/plasma/look-and-feel/Catppuccin-Mocha-Mauve/contents/previews
sudo rm -rf $HOME/.local/share/icons/Catppuccin-Mocha-Mauve-Cursors
sudo rm -rf $HOME/.local/share/icons/Catppuccin-Mocha-Dark-Cursors

sed -i "s/clear//g" "$cpmm_kde/install.sh"
sed -i '/You may want to run the following in your terminal if you notice any inconsistencies for the cursor theme:/{
N
s|You may want to run the following in your terminal if you notice any inconsistencies for the cursor theme:\nln -s ~/.local/share/icons/ ~/.icons|NEW_TEXT_HERE|
}' "$cpmm_kde/install.sh"
cd "$cpmm_kde"
echo -e "y\ny" | ./install.sh 1 4 1
sudo rm -rf ~/.icons
sudo ln -sf ~/.local/share/icons/ ~/.icons
cd ..

# Kvantum
echo "Downloading Kvantum Catppuccin Mocha Mauve theme..."
sudo rm -rf "$cpmm_kvantum"
mkdir -p "$cpmm_kvantum/catppuccin-mocha-mauve"
curl -LO --output-dir "$cpmm_kvantum/catppuccin-mocha-mauve" https://raw.githubusercontent.com/catppuccin/kvantum/refs/heads/main/themes/catppuccin-mocha-mauve/catppuccin-mocha-mauve.kvconfig
curl -LO --output-dir "$cpmm_kvantum/catppuccin-mocha-mauve" https://github.com/catppuccin/kvantum/raw/refs/heads/main/themes/catppuccin-mocha-mauve/catppuccin-mocha-mauve.svg

echo "Installing and applying Kvantum theme..."
mkdir -p "$HOME/.config/Kvantum/catppuccin-mocha-mauve"
sudo ln -sf "$cpmm_kvantum/catppuccin-mocha-mauve" "$HOME/.config/Kvantum/catppuccin-mocha-mauve"
kvantummanager --set catppuccin-mocha-mauve
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle kvantum-dark

# Konsole
sudo mkdir -p ~/.local/share/konsole/
curl -LO -o konsole-catppuccin-mocha.colorscheme https://raw.githubusercontent.com/catppuccin/konsole/refs/heads/main/themes/catppuccin-mocha.colorscheme
sudo ln -sf "$rice_directory/konsole-catppuccin-mocha.colorscheme" ~/.local/share/konsole/catppuccin-mocha.colorscheme
sudo ln -sf "$rice_directory/konsole-fish.profile" ~/.local/share/konsole/fish.profile

# SDDM & Where is my SDDM theme? Setup
if sudo pacman -Q sddm &>/dev/null && systemctl is-active sddm; then
    sudo mkdir -p /usr/share/sddm/themes/
    echo "Downloading Where is my SDDM theme?..."
    rm -rf "Where is my SDDM theme"
    clone https://github.com/stepanzubkov/where-is-my-sddm-theme.git "Where is my SDDM theme" true

    echo "Installing Where is my SDDM theme?..."
    sudo "Where is my SDDM theme/install.sh" current

    echo "Downloading Where is my SDDM theme? Catppuccin Mocha Mauve theme..."
    curl -LO -o "$cpmm_whereismysddmtheme" https://raw.githubusercontent.com/catppuccin/where-is-my-sddm-theme/refs/heads/main/themes/catppuccin-mocha.conf

    sudo rm -rf /usr/share/sddm/themes/where_is_my_sddm_theme/theme.conf
    sudo rm -rf /usr/share/sddm/themes/where_is_my_sddm_theme/theme.conf.user
    sudo rm -rf ~/.local/share/sddm/themes/where_is_my_sddm_theme/theme.conf
    sudo rm -rf ~/.local/share/sddm/themes/where_is_my_sddm_theme/theme.conf.user

    echo "Symlinking the theme to sddm theme directories..."
    sudo ln -sf "$cpmm_whereismysddmtheme" /usr/share/sddm/themes/where_is_my_sddm_theme/theme.conf
    sudo ln -sf "$cpmm_whereismysddmtheme" ~/.local/share/sddm/themes/where_is_my_sddm_theme/theme.conf
else
    echo "SDDM is not installed or inactive -> Skipping Where is my SDDM theme? setup!"
fi

# Fish
# Changing default shell to fish
if ! sudo chsh "$USER" -s /usr/bin/fish; then
    if grep -q "^$USER:" /etc/passwd | grep -q "/usr/bin/fish$"; then
        echo "Shell is already set to Fish – continuing."
    else
        echo "Failed to change shell to Fish." >&2
        exit 1
    fi
fi

echo "Copying fish config"
sudo mkdir -p ~/.config/fish/
sudo rm -rf ~/.config/fish/functions/
sudo rm -rf ~/.config/fish/conf.d/gitnow.fish
sudo rm -rf ~/.config/fish/config.fish
sudo ln -sf "$rice_directory/config.fish" ~/.config/fish/config.fish

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

# Fastfetch
echo "Copying Fastfetch config"
sudo mkdir -p ~/.config/fastfetch/
sudo rm -rf ~/.config/fastfetch/config.jsonc
sudo ln -sf "$rice_directory/fastfetch.jsonc" ~/.config/fastfetch/config.jsonc

# Brave Setup
echo "Copying Brave policies"
sudo mkdir -p /etc/brave/policies/managed/
sudo rm -rf /etc/brave/policies/managed/policies.json
sudo ln -sf "$rice_directory/brave-policies.json" /etc/brave/policies/managed/policies.json

echo "Done setting up the rice."
echo "Note: This script cannot setup brave, discord, or the rest of applications and system settings used."

echo
echo "Updating the system a last time."

declare reboot_after_update
while true; do
    read -p "Do you want to reboot after the update? [y/N]: " input_reboot_after_update
    case "${input_reboot_after_update:-N}" in
        [Yy]* )
            reboot_after_update=true
            break
        ;;
        [Nn]* )
            reboot_after_update=false
            echo "You need to logout or reboot for everything to apply correctly!"
            break
        ;;
        * )
            echo "Please answer y or n."
        ;;
    esac
done

if [[ $reboot_after_update == true ]]; then
    yay -Syyu --noconfirm && reboot
else
    yay -Syyu --noconfirm
fi