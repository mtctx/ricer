#!/bin/bash

set -e

echo """
    Welcome to Ricer by mtctx (https://github.com/mtctx/rice)
    This shell script is exclusively for Arch-based Distros.
    Officially supported are CachyOS and Vanilla Arch.
    If you are on a different Arch-based Distro run this script with -f or --force.

    Ricer will setup your KDE enviroment to use Catppuccin Mocha Mauve everywhere.
    What will Ricer setup?
    - KDE -> https://github.com/catppuccin/kde
    - Konsole -> https://github.com/catppuccin/konsole & https://github.com/mtctx/rice/blob/main/konsole-fish.profile
    - Kvantum -> https://github.com/tsujan/Kvantum/tree/master/Kvantum & https://github.com/catppuccin/kvantum
    - Fish shell -> https://github.com/mtctx/rice/blob/main/config.fish
    - Fastfetch -> https://github.com/mtctx/rice/blob/main/fastfetch.jsonc
"""

sleep 1.25s

arch="ARCH"
cachyos="CACHYOS"

force=false

for arg in "$@"; do
    case $arg in
        -f|--force)
            echo "Force flag detected, will skip the os check!"
            force="true"
        ;;
        *) ;;
    esac
done

declare os
if [[ $force == "false" ]]; then
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
fi

sudo -v

# Update System
echo "Updating system..."
sudo pacman -Syyu --noconfirm

# YAY Setup
if [[ $os == $cachyos ]]; then
    echo "Installing YAY via CachyOS AUR"
    sudo pacman -S --needed git base-devel yay --noconfirm
elif [[ $os == $arch || $force == "true" ]]; then
    echo "Building YAY manually"
    sudo pacman -S --needed git base-devel --noconfirm && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
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
yay -S --needed --noconfirm ab-download-manager alsa-firmware alsa-utils $ucode_package ark awesome-terminal-fonts base bluez-hid2hci bluez-utils brave-bin btop btrfs-assistant cantarell-fonts cpupower dmraid dolphin duf efibootmgr efitools ethtool fastfetch ffmpegthumbnailer fisher fsarchiver glances gwenview haruna haveged hdparm hwdetect hwinfo inetutils jfsutils kate kcalc kde-gtk-config kdeplasma-addons kleopatra kvantum  kwallet-pam libgsf libva-nvidia-driver  libwnck3 logrotate lsscsi man-pages meld mtools mullvad-vpn nano-syntax-highlighting netctl networkmanager-openvpn nfs-utils noto-color-emoji-fontconfig ntp octopi pavucontrol plasma-browser-integration plasma-firewall plasma-systemmonitor plasma-thunderbolt poppler-glib prismlauncher pv qt6-wayland rebuild-detector reflector sddm-kcm sg3_utils sof-firmware spectacle systemd-boot-manager ttf-jetbrains-mono-nerd ttf-meslo-nerd ttf-opensans vi vlc-plugins-all xl2tpd xorg-xinit xorg-xinput xorg-xkill zip zoxide unzip

# Setup folder

folder_path="~/rice"
read -p "Enter the path to your desired folder (Default: $folder_path): " input_path
folder_path=${input_path:-"$folder_path"}

if [[ $folder_path == ~* ]]; then
    folder_path="${folder_path/#\~/$HOME}"
fi

sudo rm -rf $folder_path
mkdir -p $folder_path && cd $folder_path

# Contains config.fish, fastfetch.jsonc and brave-policies.json aswell as this script.
git clone https://github.com/mtctx/rice.git .

# Base Cattpuccin Setup
cpmm_prefix="CPMM"
cpmm_kde="$cpmm_prefix KDE"
cpmm_kvantum="$cpmm_prefix Kvantum"
cpmm_whereismysddmtheme="$cpmm_prefix Where is my SDDM theme.conf"

sudo touch ".$cpmm_prefix stands for Catppuccin Mocha Mauve.txt"

# KDE
echo "Downloading KDE Catppuccin Mocha Mauve theme..."
sudo rm -rf "$cpmm_kde"
git clone https://github.com/catppuccin/kde.git "$cpmm_kde"
echo "Running KDE Catppuccin installer..."

sudo rm -rf $HOME/.local/share/kpackage/generic/Catppuccin-Mocha-Mauve
sudo rm -rf $HOME/.local/share/plasma/look-and-feel
sudo rm -rf $HOME/.local/share/plasma/look-and-feel/Catppuccin-Mocha-Mauve/contents
sudo rm -rf $HOME/.local/share/plasma/look-and-feel/Catppuccin-Mocha-Mauve/contents/previews
sudo rm -rf $HOME/.local/share/icons/Catppuccin-Mocha-Mauve-Cursors
sudo rm -rf $HOME/.local/share/icons/Catppuccin-Mocha-Dark-Cursors

echo -e "y\ny" | "$cpmm_kde/install.sh" 1 4 1
sudo rm -rf ~/.icons
sudo ln -s ~/.local/share/icons/ ~/.icons

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
curl -LO --output-dir ~/.local/share/konsole/ https://raw.githubusercontent.com/catppuccin/konsole/refs/heads/main/themes/catppuccin-mocha.colorscheme
sudo ln -sf konsole-fish.profile ~/.local/share/konsole/fish.profile

# SDDM & Where is my SDDM theme? Setup
if sudo pacman -Q sddm &>/dev/null && systemctl is-active sddm; then
    sudo mkdir -p /usr/share/sddm/themes/
    echo "Downloading Where is my SDDM theme?..."
    git clone https://github.com/stepanzubkov/where-is-my-sddm-theme.git "Where is my SDDM theme"
    echo "Installing Where is my SDDM theme..."
    read -p "Which QT Version are you using? 5 or 6: " qt_version
    qt_version=${qt_version:-"6"}
    case "$qt_version" in
        5)
            export USE_QT5=true
            echo "Using QT5 version of Where is my SDDM theme?..."
            ;;
        6)
            unset USE_QT5
            echo "Using QT6 version of Where is my SDDM theme?..."
            ;;
        *)
            echo "Malformed input, defaulting to QT6"
            qt_version="6"
            ;;
    esac

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
sudo mkdir -p ~/.config/fish/
sudo rm -rf ~/.config/fish/config.fish
sudo ln -sf config.fish ~/.config/fish/config.fish

fisher install catppuccin/fish
fisher install reitzig/sdkman-for-fish
fisher install jorgebucaran/autopair.fish
fisher install patrickf1/fzf.fish
fisher install joseluisq/gitnow

# Fastfetch
sudo mkdir -p ~/.config/fastfetch/
sudo rm -rf ~/.config/fastfetch/config.jsonc
sudo ln -sf fastfetch.jsonc ~/.config/fastfetch/config.jsonc

# Brave Setup
sudo mkdir -p /etc/brave/policies/managed/
sudo rm -rf /etc/brave/policies/managed/policies.json
sudo ln -sf brave-policies.json /etc/brave/policies/managed/policies.json

echo "Done setting up the rice.\nNote: This script cannot setup brave, discord, or the rest of applications and system settings used."
echo "Updating the system a last time."

declare reboot_after_update
while true; do
    read -p "Do you want to reboot after the update? [y/N]: " input_reboot_after_update
    case "${input_reboot_after_update:-N}" in
        [Yy]* )
            reboot_after_update="true"
            break
        ;;
        [Nn]* )
            reboot_after_update="false"
            echo "You need to logout or reboot for everything to apply correctly!"
            break
        ;;
        * )
            echo "Please answer y or n."
        ;;
    esac
done

if [[ $reboot_after_update == "true" ]]; then
    yay -Syyu --noconfirm && reboot
else
    yay -Syyu --noconfirm
fi