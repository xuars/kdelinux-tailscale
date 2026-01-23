#!/usr/bin/env bash
sudo systemctl stop tailscaled
sudo systemctl disable tailscaled
sudo rm /etc/systemd/system/tailscaled.service
sudo rm /etc/default/tailscaled
sudo rm /etc/profile.d/tailscale.sh
sudo rm -rf /opt/tailscale/tailscale
