#!/usr/bin/env bash
if [[ -d /opt/tailscale ]];then
  sudo rm -rf /opt/tailscale
fi

if [[ -f /etc/default/tailscaled ]];then
  sudo rm /etc/default/tailscaled
fi

# Legacy
if [[ -f /etc/profile.d/tailscale.sh ]];then
  sudo rm /etc/profile.d/tailscale.sh
fi

if [[ -f /etc/profile.d/70-tailscale-path.sh ]];then
  sudo rm /etc/profile.d/70-tailscale-path.sh
fi

if [[ -f /etc/systemd/system/tailscaled.service ]];then
  sudo rm /etc/systemd/system/tailscaled.service
fi

if [[ -d /etc/systemd/system/tailscaled.service.d ]];then
  sudo rm -rf /etc/systemd/system/tailscaled.service.d
fi

sudo systemctl stop tailscaled
sudo systemctl disable tailscaled

echo "Done."



