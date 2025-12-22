source "./shared.sh"

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
s|You may want to run the following in your terminal if you notice any inconsistencies for the cursor theme:\nln -s $HOME/.local/share/icons/ $HOME/.icons|NEW_TEXT_HERE|
}' "$cpmm_kde/install.sh"
cd "$cpmm_kde"
echo -e "y\ny" | ./install.sh 1 4 1
sudo rm -rf $HOME/.icons
ln -sf $HOME/.local/share/icons/ $HOME/.icons
cd $rice_directory/scripts

kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "3" --group "Applets" --group "8" --group "General" --key "extraItems" "org.kde.kdeconnect,org.kde.plasma.cameraindicator,org.kde.plasma.clipboard,org.kde.plasma.manage-inputmethod,org.kde.plasma.devicenotifier,org.kde.plasma.mediacontroller,org.kde.plasma.notifications,org.kde.plasma.volume,org.kde.plasma.keyboardindicator,org.kde.plasma.weather"
kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "3" --group "Applets" --group "8" --group "General" --key "hiddenItems" "Arch-Update"
kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "3" --group "Applets" --group "8" --group "General" --key "knownItems" "org.kde.plasma.bluetooth,org.kde.kdeconnect,org.kde.plasma.cameraindicator,org.kde.plasma.clipboard,org.kde.plasma.manage-inputmethod,org.kde.plasma.keyboardlayout,org.kde.plasma.devicenotifier,org.kde.plasma.mediacontroller,org.kde.plasma.notifications,org.kde.kscreen,org.kde.plasma.battery,org.kde.plasma.brightness,org.kde.plasma.networkmanagement,org.kde.plasma.volume,org.kde.plasma.keyboardindicator,org.kde.plasma.weather"
kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "3" --group "Applets" --group "8" --group "General" --key "scaleIconsToFit" "true"

MAX_ID=$(grep -oP '\[Containments\]\[3\]\[Applets\]\[\K\d+' ~/.config/plasma-org.kde.plasma.desktop-appletsrc | sort -n | tail -1)
MAX_ID=$((MAX_ID + 1))
kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "3" --group "Applets" --group "$MAX_ID" --key "immutability" "1"
kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "3" --group "Applets" --group "$MAX_ID" --key "plugin" "org.kde.plasma.panelspacer"
MAX_ID=$((MAX_ID + 1))
kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "3" --group "Applets" --group "$MAX_ID" --key "immutability" "1"
kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "3" --group "Applets" --group "$MAX_ID" --key "plugin" "org.kde.plasma.panelspacer"

icontasks_id=$(grep -B 2 "plugin=org.kde.plasma.icontasks" ~/.config/plasma-org.kde.plasma.desktop-appletsrc | grep "\[Containments\]\[3\]\[Applets\]"| sed 's/.*\[\([0-9]*\)\]$/\1/')
current_order=$(kreadconfig6 --file "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" --group "Containments" --group "3" --group "General" --key "AppletOrder")
new_order=$(echo "$current_order" | sed "s/\b$icontasks_id\b/$((MAX_ID - 1));$icontasks_id;$MAX_ID/g")
kwriteconfig6 --file "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" --group "Containments" --group "3" --group "General" --key "AppletOrder" "$new_order"

unset MAX_ID
unset icontasks_id
unset current_order
unset new_order
