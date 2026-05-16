# hyprland-dots

A very simple setup script has now been included. It was made on CachyOS after having selected Hyprland in the Calamares installation process. As such I do not know if every dependency needed has been included, but the basics should be there. As always run at your own risk. This repo is mainly meant for my own personal use.  

Install Script: [View](/Install.sh) - [Download](https://raw.githubusercontent.com/Florararie/hyprland-dots/refs/heads/main/Install.sh)
 

Alternatively run like so

```bash
sh -c "$(curl -sS https://raw.githubusercontent.com/Florararie/hyprland-dots/refs/heads/main/Install.sh)"
```

<img src="/preview/desktop.png"/>

## Monitor Configuration
This setup is configured for two monitors named `DP-2` (primary) and `HDMI-A-1` (secondary).
If your monitor names differ you will need to update them in the following files:

- `~/.config/hypr/config/monitors.lua`
- `~/.config/hypr/config/rules.lua`
- `~/.config/hypr/hyprlock.conf`
- `~/.config/noctalia/settings.json`
- `~/.config/wayle/config.toml`

Run `hyprctl monitors` to find your monitor names.