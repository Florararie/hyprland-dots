-- See https://wiki.hypr.land/Configuring/Basics/Autostart

hl.on("hyprland.start", function () 
    hl.exec_cmd("kill kded6")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("wayle panel start")
    --hl.exec_cmd("qs -c noctalia-shell")
    hl.exec_cmd("hypridle -c ~/.config/hypr/hypridle.conf")
    hl.exec_cmd("corectrl --minimize-systray")
    --hl.exec_cmd("~/.config/hypr/scripts/moveOpenedGames.sh") -- disabled by default since this behavior may not be desirable

    -- Choose only one
    --hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    --hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
end)
