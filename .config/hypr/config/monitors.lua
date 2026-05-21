-- See https://wiki.hypr.land/Configuring/Basics/Monitors

-- HDR is somehow worse than it was before so I'm leaving related settings commented out

hl.monitor({
    output = "DP-2",
    mode = "2560x1440@180",
    position = "0x240",
    scale = 1,
    --vrr = 2,

    --cm = "auto",
    --bitdepth = 10,
    --supports_hdr = 1,
    --supports_wide_color = 1,

    --sdrbrightness = 1.3,
    --sdrsaturation = 0.95,
})

hl.monitor({
    output = "HDMI-A-1",
    mode = "1920x1080@120",
    position = "2560x0",
    scale = 1,
    transform = 1
})


hl.config({
    cursor = {
        no_hardware_cursors = 1
    },

    general = {
        allow_tearing = false, -- you may want this, but false is a safe default
    },

    --[[quirks = {
        prefer_hdr = 1
    },]]

    render = {
        direct_scanout = 1,
        --cm_enabled = true,
        --cm_auto_hdr = 1,
        --keep_unmodified_copy = 2,
    },
})
