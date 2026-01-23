# Tailscale on KDE Linux

> [!WARNING] 
> This is an UNOFFICIAL Tailscale installation script. 
> Most of the script is written by AI, but reviewed by a human. 
> Proceed with caution

This script is derived from the [original guide](https://github.com/tailscale-dev/deck-tailscale).

## Installing Tailscale

1. Clone this repo to your system, switch to root and enter the directory:
   1. `git clone https://github.com/xuars/kdelinux-tailscale.git ~/kdelinux-tailscale`
   2. `cd ~/kdelinux-tailscale` 
2. Run `chmod +x ./*.sh && sudo ./install.sh` to install Tailscale
3. Run `source /etc/profile.d/tailscale.sh` to put the binaries in your path
4. Run `tailscale up --qr` to have Tailscale generate
   a login QR code.

## Updating Tailscale

Tailscale should be able to update itself now! Try running
`sudo tailscale update`, and if that works, `sudo tailscale set --auto-update`.

## How it works

The Tailscale binaries `tailscale` and `tailscaled` are installed in `/opt/tailscale/`. The Tailscale systemd unit file is installed at `/etc/systemd/system/tailscale.service`. The override file to reconfigure the services `Exec` commands is installed at `/etc/systemd/system/tailscaled.service.d/override.conf`. The defaults file for the variables `PORT` and `FLAGS` is installed at `/etc/default/tailscaled`

The service is then started and enabled via `systemctl`.
