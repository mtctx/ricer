#!/bin/bash

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

echo """
    Welcome to Ricer by mtctx (https://github.com/mtctx/ricer)
    This shell script is exclusively for Arch-based Distros.
    Officially supported are CachyOS and Vanilla Arch.
    If you are on a different Arch-based Distro run this script with --trustmeiamonarch.

    Ricer will setup your KDE enviroment to use Catppuccin Mocha Mauve everywhere.
    What will Ricer setup?
    - KDE -> https://github.com/catppuccin/kde
    - SDDM -> https://github.com/catppuccin/sddm
    - Konsole -> https://github.com/catppuccin/konsole & https://github.com/mtctx/rice/blob/main/konsole-fish.profile
    - Kvantum -> https://github.com/tsujan/Kvantum/tree/master/Kvantum & https://github.com/catppuccin/kvantum
    - Fish shell -> https://github.com/catppuccin/fish & https://github.com/mtctx/rice/blob/main/config.fish & https://github.com/jorgebucaran/fisher
    - Fastfetch -> https://github.com/mtctx/rice/blob/main/fastfetch.jsonc

    Requirements:
    - KDE Plasma 6
    - QT 5 and/or 6
"""

check_kde_installed
check_kde_version

sleep 1.25s

declare rice_directory
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dir)
            rice_directory="$2"
            shift
        ;;
        -h|--help) echo """
    Usage: $0 [--dir PATH_TO_DIR] [--qt 5|6] [--trustmeiamonarch]
    
    Options:
    --dir: Set the directory to save all configs.
    --trustmeiamonarch: Skip the OS check (Use if you are on an different Arch-based distro and not on vanilla Arch or CachyOS)
"""
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
echo

sudo -v

# Setup Rice Directory
if [[ $rice_directory == ~* ]]; then
    rice_directory="${rice_directory/#\$HOME/$HOME}"
fi

rice_directory="$(realpath "$rice_directory")"

sudo rm -rf "$rice_directory"
mkdir -p "$rice_directory"

# Contains config.fish, fastfetch.jsonc and brave-policies.json as well as this script.
clone https://github.com/mtctx/rice.git "$rice_directory"
cd "$rice_directory" || exit 1

./scripts/yay-pacman.sh "$rice_directory"
./scripts/kde.sh "$rice_directory"
./scripts/sddm.sh "$rice_directory"
./scripts/kvantum.sh "$rice_directory"
./scripts/konsole.sh "$rice_directory"
./scripts/fish.sh "$rice_directory"
./scripts/fastfetch.sh "$rice_directory"
./scripts/brave.sh "$rice_directory"

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