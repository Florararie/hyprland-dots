-- Refer to https://wiki.hypr.land/configuring/core

-- https://wiki.hypr.land/configuring/core/config-options/#general
hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 18,
        border_size = 6,

        col = {
            active_border   = { colors = {"rgba(d699b6ff)", "rgba(a79ad4ff)"}, angle = 45 },
            inactive_border = "rgba(3d3d4daa)",
        },

        resize_on_border        = true,
        extend_border_grab_area = 8,
        layout                  = "dwindle",
        --layout                  = "scrolling",
    },
})

-- https://wiki.hypr.land/configuring/layouts/dwindle-layout
hl.config({
    dwindle = {
        preserve_split = true,
    }
})

-- https://wiki.hypr.land/configuring/core/config-options/#decoration
hl.config({
    decoration = {
        rounding       = 8,
        rounding_power = 4.0,

        active_opacity   = 1.0,
        inactive_opacity = 0.88,
        dim_inactive     = true,
        dim_strength     = 0.25,

        shadow = {
            enabled        = true,
            range          = 80,
            render_power   = 3,
            color          = "rgba(0d0d1aee)",
            color_inactive = "rgba(0d0d1a88)",
            offset         = "0 4",
            scale          = 0.98,
        },

        glow = {
            enabled        = true, -- disable if you dont like it
            range          = 15,
            render_power   = 3,
            color          = "rgba(0d0d1aee)",
            color_inactive = "rgba(0d0d1a88)"
        },

        blur = {
            enabled           = true,
            xray              = false,
            size              = 8,
            passes            = 3,
            noise             = 0.08,
            contrast          = 0.9,
            brightness        = 0.85,
            vibrancy          = 0.22,
            vibrancy_darkness = 0.3,
            new_optimizations = true,
            popups            = true,
        },

        wobble = {
            enabled          = true,
            mesh             = 12,
            stiffness        = 200,
            damping          = 13,
            mass             = 1,
            intensity        = 0.3,
            value_epsilon    = 0.25,
            velocity_epsilon = 2
        }
    },
})


hl.config({
    animations = {
        enabled = true,
    },

    ecosystem = {
        no_donation_nag = true,
    },

    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
    }
})


-- https://wiki.hypr.land/configuring/core/animations/#general
-- Curves
hl.curve( "windowBounce",    { type = "spring", mass = 1, stiffness = 350, dampening = 24 })
hl.curve( "windowMove",      { type = "spring", mass = 1, stiffness = 350, dampening = 37 })
hl.curve( "workspaceBounce", { type = "spring", mass = 1, stiffness = 250, dampening = 22 })
hl.curve( "easeIn",  { type = "bezier", points = { {0.49, 0.04}, {0.98, 1.06} } })
hl.curve( "easeOut", { type = "bezier", points = { {0.00, 0.33}, {0.31, 1.23} } })
hl.curve( "linear",  { type = "bezier", points = { {0.00, 0.00}, {1.00, 1.00} } })

-- Windows
hl.animation({ leaf = "windowsIn",      enabled = true, speed = 1, spring  = "windowBounce", style = "popin 60%" })
hl.animation({ leaf = "windowsOut",     enabled = true, speed = 1, spring  = "windowBounce", style = "popin 90%" })
hl.animation({ leaf = "windowsMove",    enabled = true, speed = 1, spring  = "windowMove" })

-- Fades
hl.animation({ leaf = "fadeIn",         enabled = true, speed = 3,  bezier  = "easeOut" })
hl.animation({ leaf = "fadeOut",        enabled = true, speed = 3,  bezier  = "easeIn"  })
hl.animation({ leaf = "fadeSwitch",     enabled = true, speed = 3,  bezier  = "easeIn"  })
hl.animation({ leaf = "fadeShadow",     enabled = true, speed = 3,  bezier  = "easeIn"  })
hl.animation({ leaf = "fadeDim",        enabled = true, speed = 5,  bezier  = "easeOut" })
hl.animation({ leaf = "fadePopupsIn",   enabled = true, speed = 3,  bezier  = "easeOut" })
hl.animation({ leaf = "fadePopupsOut",  enabled = true, speed = 3,  bezier  = "easeOut" })
hl.animation({ leaf = "fadeDpms",       enabled = true, speed = 3,  bezier  = "easeOut" })

-- Border
hl.animation({ leaf = "border",         enabled = true, speed = 4,  bezier  = "easeIn" })
hl.animation({ leaf = "borderangle",    enabled = true, speed = 50, bezier  = "linear", style = "loop" })

-- Workspaces
hl.animation({ leaf = "workspacesIn",   enabled = true, speed = 1, spring  = "workspaceBounce", style = "slidefade 60%" })
hl.animation({ leaf = "workspacesOut",  enabled = true, speed = 1, spring  = "workspaceBounce", style = "slidefade 60%" })