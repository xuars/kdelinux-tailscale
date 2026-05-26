#!/usr/bin/env bash

set -eu -o pipefail

# Save the current directory silently
pushd . > /dev/null

# Make a temporary directory, save the name, and move into it
dir="$(mktemp -d)"
cd "${dir}"

echo -n "Getting latest Tailscale version..."
tarball="$(curl -s 'https://pkgs.tailscale.com/stable/?mode=json' | jq -r .Tarballs.amd64)"
version="$(echo ${tarball} | cut -d_ -f2)"

echo "Downloading ${version}..."
wget -q --show-progress -O tailscale.tgz "https://pkgs.tailscale.com/stable/${tarball}"
echo "Done."

# extract the tailscale binaries
tar xzf tailscale.tgz
tar_dir="$(echo ${tarball} | cut -d. -f1-3)"
test -d $tar_dir


echo "Installing..."

# Create binaries directory
if [[ ! -d /opt/tailscale ]];then
  sudo mkdir -p /opt/tailscale
fi

# Install binaries
sudo cp -rf $tar_dir/tailscale /opt/tailscale/tailscale
sudo cp -rf $tar_dir/tailscaled /opt/tailscale/tailscaled

# Add binaries to PATH
echo 'export PATH=$PATH:/opt/tailscale' | sudo tee /etc/profile.d/70-tailscale-path.sh > /dev/null

# Copy the service file
sudo cp -f $tar_dir/systemd/tailscaled.service /etc/systemd/system/tailscaled.service

# Copy the defaults file
if [[ ! -f /etc/default/tailscaled ]]; then
  sudo cp -f $tar_dir/systemd/tailscaled.defaults /etc/default/tailscaled
fi

# Add an override file with updated paths for binaries
if [[ ! -d /etc/systemd/system/tailscaled.service.d ]];then
  sudo mkdir -p /etc/systemd/system/tailscaled.service.d
fi
cat << 'EOF' | sudo tee /etc/systemd/system/tailscaled.service.d/override.conf > /dev/null
[Service]
ExecStartPre=
ExecStartPre=/opt/tailscale/tailscaled --cleanup
ExecStart=
ExecStart=/opt/tailscale/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/run/tailscale/tailscaled.sock --port=${PORT} $FLAGS
ExecStopPost=
ExecStopPost=/opt/tailscale/tailscaled --cleanup
EOF

echo "Done."

# Return to the original directory
popd > /dev/null

echo "Cleaning downladed artifacts..."
rm -rf "${dir}"

echo "Enabling (and starting) Tailscale service..."
# Reload systemd for the new services
sudo systemctl daemon-reload
sudo systemctl enable --now tailscaled &>/dev/null || echo "ERROR: Could not enable tailscaled service" && exit 1

echo "Done."


echo "Tailscale is installed and running but the binaries are not in your path yet."
echo "Restart your system to complete the installation"

echo "Finished"
