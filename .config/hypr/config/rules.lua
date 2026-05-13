-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules

hl.window_rule({ match = { class = "org.pulseaudio.pavucontrol" }, float = true, center = true, size = "660, 540" })
hl.window_rule({ match = { title = "Save File" }, float = true })
hl.window_rule({ match = { title = "Open File" }, float = true })
hl.window_rule({ match = { class = "blueman-manager" }, float = true })
hl.window_rule({ match = { class = "^(xdg-desktop-portal-(gtk|kde|hyprland))$" }, float = true })
hl.window_rule({ match = { class = "org.freedesktop.impl.portal.desktop.kde" }, float = true, center = true, size = "1165 685" })
hl.window_rule({ match = { class = "^(polkit-gnome-authentication-agent-1|hyprpolkitagent|org\\.kde\\.polkit-kde-authentication-agent-1).*$" }, float = true })
hl.window_rule({ match = { class = "CachyOSHello" }, float = true })
hl.window_rule({ match = { class = "zenity" }, float = true, center = true, size = "630 700" })

hl.window_rule({ match = { class = "org.kde.plasma-systemmonitor" }, float = true, center = true, size = "1434 916" })
hl.window_rule({ match = { title = "Picture-in-Picture" }, float = true, center = true, size = "960 540" })
hl.window_rule({ match = { class = "steam", title = "Friends List" }, float = true, center = true, size = "350 800" })
hl.window_rule({ match = { class = "steam", title = "Steam - Self Updater" }, float = true, center = true })
hl.window_rule({ match = { title = "Protontricks at Home" }, float = true })

hl.window_rule({ match = { class = "discord" }, workspace = "5" })
hl.window_rule({ match = { class = "vesktop" }, workspace = "5" })

--hl.window_rule({
--    -- Ignore maximize requests from all apps. You'll probably like this.
--    name  = "suppress-maximize-events",
--    match = { class = ".*" },
--
--    suppress_event = "maximize",
--})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})


-- Workspace Rules
hl.workspace_rule({ workspace = "1", monitor = "DP-2", default = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-2" })
hl.workspace_rule({ workspace = "3", monitor = "DP-2" })
hl.workspace_rule({ workspace = "4", monitor = "DP-2" })

hl.workspace_rule({ workspace = "5", monitor = "HDMI-A-1", default = true })
hl.workspace_rule({ workspace = "6", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "7", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "8", monitor = "HDMI-A-1" })