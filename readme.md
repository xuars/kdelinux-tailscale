# Tailscale on KDE Linux

> [!WARNING] 
> This is an UNOFFICIAL Tailscale installation script. 

This script is derived from the [original guide](https://github.com/tailscale-dev/deck-tailscale).

## Installing Tailscale

   ```zsh
   git clone https://github.com/xuars/kdelinux-tailscale.git ~/kdelinux-tailscale
   cd ~/kdelinux-tailscale

   chmod +x ./*.sh 
   ./install.sh

   # After rebooting the system, you don't need to write the full path
   sudo /opt/tailscale/tailscale up --qr
   ```
> [!TIP]
> Run `sudo tailscale set --operator=$USER` once to be able to run `tailscale` without sudo.

## Updating Tailscale

Tailscale should be able to update itself now! Try running
`sudo tailscale update`, and if that works, `tailscale set --auto-update`.

## Known issues

- ~~`sudo tailscale` : `sudo: tailscale: command not found`~~ - Fixed. Reinstall Tailscale to permanently fix it.
   

## How it works

The Tailscale binaries `tailscale` and `tailscaled` are installed in `/opt/tailscale/`. The Tailscale systemd unit file is installed at `/etc/systemd/system/tailscale.service`. The override file to reconfigure the services `Exec` commands is installed at `/etc/systemd/system/tailscaled.service.d/override.conf`. The defaults file for the variables `PORT` and `FLAGS` is installed at `/etc/default/tailscaled`

The service is then started and enabled via `systemctl`.




