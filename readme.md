# Tailscale on KDE Linux

> [!WARNING] 
> This is an UNOFFICIAL Tailscale installation script. 
> Part of the script is written by AI, but reviewed by a human. 
> Proceed with caution

This script is derived from the [original guide](https://github.com/tailscale-dev/deck-tailscale).

## Installing Tailscale

   ```bash
   git clone https://github.com/xuars/kdelinux-tailscale.git ~/kdelinux-tailscale
   cd ~/kdelinux-tailscale

   chmod +x ./*.sh 
   sudo ./install.sh

   source /etc/profile.d/tailscale.sh # adds Tailscale to PATH without needing to reboot 
   tailscale up --qr
   ```
> [!TIP]
> The script automatically sets your user to be the tailscale operator, letting you run `tailscale` commands without sudo

## Updating Tailscale

Tailscale should be able to update itself now! Try running
`sudo /opt/tailscale/tailscale update`, and if that works, `tailscale set --auto-update`.

## Known issues

- `sudo tailscale` : `sudo: tailscale: command not found`
  Tailscale operator is set to the user who runs the installation script.
  If you need to use it with sudo, run `sudo /opt/tailscale/tailscale`
   

## How it works

The Tailscale binaries `tailscale` and `tailscaled` are installed in `/opt/tailscale/`. The Tailscale systemd unit file is installed at `/etc/systemd/system/tailscale.service`. The override file to reconfigure the services `Exec` commands is installed at `/etc/systemd/system/tailscaled.service.d/override.conf`. The defaults file for the variables `PORT` and `FLAGS` is installed at `/etc/default/tailscaled`

The service is then started and enabled via `systemctl`.



