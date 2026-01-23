#!/usr/bin/env bash
# set invocation settings:
# -e: Exit on error
# -u: Error on unset variables
# -o pipefail: Catch errors in pipelines
set -eu -o pipefail

# 1. Check for sudo/root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo or as root."
  exit 1
fi

# Identify the real user (the one who called sudo) to set as operator later
REAL_USER=${SUDO_USER:-$(whoami)}

# save the current directory silently
pushd . > /dev/null

# 2. Create a temporary directory and move into it
dir="$(mktemp -d)"
cd "${dir}"

echo -n "Getting version..."
# get info for the latest version of Tailscale
tarball="$(curl -s 'https://pkgs.tailscale.com/stable/?mode=json' | jq -r .Tarballs.amd64)"
version="$(echo ${tarball} | cut -d_ -f2)"
echo "got ${version}."

echo "Downloading..."
wget -q --show-progress -O tailscale.tgz "https://pkgs.tailscale.com/stable/${tarball}"

echo -n "Cleaning up existing service..."
# Stop and disable the systemd service if it exists
systemctl stop tailscaled 2>/dev/null || true
systemctl disable tailscaled 2>/dev/null || true
echo "done."

echo -n "Installing to /opt/tailscale..."
# extract the tailscale binaries
tar xzf tailscale.tgz
tar_dir="$(echo ${tarball} | cut -d. -f1-3)"

# Create binaries directory in /opt (persistent on most immutable distros)
mkdir -p /opt/tailscale
cp -rf "$tar_dir/tailscale" /opt/tailscale/tailscale
cp -rf "$tar_dir/tailscaled" /opt/tailscale/tailscaled

# Add binaries to path via profile.d
if ! test -f /etc/profile.d/tailscale.sh; then
  echo 'PATH="$PATH:/opt/tailscale"' > /etc/profile.d/tailscale.sh
fi

# Copy the systemd file into place
cp -rf "$tar_dir/systemd/tailscaled.service" /etc/systemd/system/tailscaled.service

# Copy in the defaults file if it doesn't already exist
if ! test -f /etc/default/tailscaled; then
  cp -rf "$tar_dir/systemd/tailscaled.defaults" /etc/default/tailscaled
fi

# 3. Apply Systemd Override
# This ensures the service uses our /opt paths and handles port/flags correctly
mkdir -p /etc/systemd/system/tailscaled.service.d
cat <<EOF > /etc/systemd/system/tailscaled.service.d/override.conf
[Service]
ExecStartPre=
ExecStartPre=/opt/tailscale/tailscaled --cleanup
ExecStart=
ExecStart=/opt/tailscale/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/run/tailscale/tailscaled.sock --port=\${PORT} \$FLAGS
ExecStopPost=
ExecStopPost=/opt/tailscale/tailscaled --cleanup
EOF

# capture the above override file in systemd
systemctl daemon-reload
echo "done."

# return to original directory and clean up temp files
popd > /dev/null
rm -rf "${dir}"

echo "Starting required services..."
systemctl enable --now tailscaled

# 4. Set operator
# Give the daemon a moment to initialize the socket
sleep 2
echo "Setting operator to $REAL_USER..."
/opt/tailscale/tailscale set --operator="$REAL_USER"

echo "Installation Complete."
echo "Operator: $REAL_USER"
echo "If 'tailscale' command is not found, run: source /etc/profile.d/tailscale.sh"
