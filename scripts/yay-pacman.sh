source "$1/scripts/shared.sh" "$1"

# Update System
echo "Updating system..."
sudo pacman -Syyu --noconfirm

source /etc/os-release

# YAY Setup
install_from_aur() {
    echo "Installing YAY via $NAME AUR"
    sudo pacman -S --needed git base-devel yay --noconfirm
}

build_manually() {
    echo "Building YAY manually"
    sudo pacman -S --needed git base-devel --noconfirm
    clone https://aur.archlinux.org/yay.git true
    cd yay && makepkg -si
}

case "$ID" in
    manjaro|endeavouros|garuda|arcolinux|cachyos|rebornos|blackarch|bioarch) install_from_aur ;;
    arch|*) build_manually ;;
esac

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
yay -S --needed --noconfirm ab-download-manager alsa-firmware alsa-utils $ucode_package ark awesome-terminal-fonts base bluez-hid2hci bluez-utils brave-bin btop btrfs-assistant cantarell-fonts cpupower dmraid dolphin duf efibootmgr efitools ethtool fastfetch ffmpegthumbnailer fisher fsarchiver glances gwenview haruna haveged hdparm hwdetect hwinfo inetutils jfsutils kate kcalc kde-gtk-config kdeplasma-addons kleopatra kvantum  kwallet-pam libgsf libva-nvidia-driver  libwnck3 logrotate lsscsi man-pages meld mtools mullvad-vpn nano-syntax-highlighting netctl networkmanager-openvpn nfs-utils noto-color-emoji-fontconfig ntp octopi pavucontrol plasma-browser-integration plasma-firewall plasma-systemmonitor plasma-thunderbolt poppler-glib prismlauncher pv rebuild-detector reflector sddm-kcm sg3_utils sof-firmware spectacle systemd-boot-manager ttf-jetbrains-mono-nerd ttf-meslo-nerd ttf-opensans vi vlc-plugins-all xl2tpd xorg-xinit xorg-xinput xorg-xkill zip zoxide unzip