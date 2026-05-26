# Tailscale on KDE Linux

> [!WARNING] 
> This is an UNOFFICIAL Tailscale installation script. 

This script is derived from the [original guide](https://github.com/tailscale-dev/deck-tailscale).

## Installing Tailscale

   ```zsh
   git clone https://github.com/xuars/kdelinux-tailscale.git ~/kdelinux-tailscale
   cd ~/kdelinux-tailscale

   chmod +x ./*.sh  && ./install.sh

   sudo /opt/tailscale/tailscale up --qr
   ```
> [!TIP]
> Run `sudo /opt/tailscale/tailscale set --operator=$USER` once to be able to run `tailscale` commands without sudo.

## Updating Tailscale

Tailscale should be able to update itself now! Try running
`sudo tailscale update`, and if that works, `tailscale set --auto-update`.

## Uninstalling Tailscale
```zsh
./uninstall.sh
```

## Known issues

- `sudo tailscale` : `sudo: tailscale: command not found`
  This happens because root account uses a different PATH compared to normal user shells.
  If you need to use it with sudo, run `sudo /opt/tailscale/tailscale`
   

## How it works

The Tailscale binaries `tailscale` and `tailscaled` are installed in `/opt/tailscale/`. The Tailscale systemd unit file is installed at `/etc/systemd/system/tailscale.service`. The override file to reconfigure the services `Exec` commands is installed at `/etc/systemd/system/tailscaled.service.d/override.conf`. The defaults file for the variables `PORT` and `FLAGS` is installed at `/etc/default/tailscaled`

The service is then started and enabled via `systemctl`.




