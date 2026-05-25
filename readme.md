# Tailscale on KDE Linux

> [!WARNING] 
> This is an UNOFFICIAL Tailscale installation script. 

This script is derived from the [original guide](https://github.com/tailscale-dev/deck-tailscale).

## Installing Tailscale

   ```zsh
   git clone https://github.com/xuars/kdelinux-tailscale.git ~/kdelinux-tailscale
   cd ~/kdelinux-tailscale

   chmod +x ./*.sh 
   ./install.sh --set-operator $USER

   # After rebooting the system, you don't need to write the full path
   /opt/tailscale/tailscale up --qr
   ```
> [!TIP]
> The script automatically sets your user to be the tailscale operator, letting you run `tailscale` commands without sudo

## Updating Tailscale

Tailscale should be able to update itself now! Try running
`sudo tailscale update`, and if that works, `tailscale set --auto-update`.

## Known issues

- ~~`sudo tailscale` : `sudo: tailscale: command not found`
  Tailscale operator is set to the user who runs the installation script.
  If you need to use it with sudo, run `sudo /opt/tailscale/tailscale`~~ - Fixed. Reinstall Tailscale to permanently fix it.
   

## How it works

The Tailscale binaries `tailscale` and `tailscaled` are installed in `/opt/tailscale/`. The Tailscale systemd unit file is installed at `/etc/systemd/system/tailscale.service`. The override file to reconfigure the services `Exec` commands is installed at `/etc/systemd/system/tailscaled.service.d/override.conf`. The defaults file for the variables `PORT` and `FLAGS` is installed at `/etc/default/tailscaled`

The service is then started and enabled via `systemctl`.




