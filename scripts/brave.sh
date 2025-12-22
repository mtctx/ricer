source "./shared.sh"

echo "Copying Brave policies"
sudo mkdir -p /etc/brave/policies/managed/
sudo rm -rf /etc/brave/policies/managed/policies.json
sudo ln -sf "$rice_directory/configs/brave-policies.json" /etc/brave/policies/managed/policies.json