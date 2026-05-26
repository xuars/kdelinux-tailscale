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
if [[ ! -d /etc/environment.d ]];then
  sudo mkdir -p /etc/environment.d
fi
echo 'PATH=$PATH:/opt/tailscale' | sudo tee /etc/environment.d/70-tailscale-path.conf > /dev/null

# Copy the service file
sudo cp -f $tar_dir/systemd/tailscaled.service /etc/systemd/system/tailscaled.service

# copy the defaults file
if [[ ! -f /etc/default/tailscaled ]]; then
  sudo cp -f $tar_dir/systemd/tailscaled.defaults /etc/default/tailscaled
fi

# Add an override file with updated paths for binaries
if [[ ! -d /etc/systemd/tailscaled.service.d ]];then
  sudo mkdir -p /etc/systemd/system/tailscaled.service.d
fi
cat $tar_dir/systemd/tailscaled.service | sed 's/\/usr\/sbin\/tailscaled/\/opt\/tailscale\/tailscaled/g' | sudo tee /etc/systemd/system/tailscaled.service.d/override.conf > /dev/null

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

# Set Tailscale operator to the user who ran the installation (optional)
if [[ $# -gt 1 ]]; then
  if [[ $1 == "--set-operator" ]];then
   echo "Setting $2 to be the Tailscale operator..."
   sudo /opt/tailscale/tailscale set --operator=$2
   echo "Done."
  fi
fi

echo "Tailscale is installed and running but the binaries are not in your path yet."
echo "Restart your system to complete the installation"

echo "Finished"
