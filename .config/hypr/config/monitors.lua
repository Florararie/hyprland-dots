-- See https://wiki.hypr.land/configuring/core/monitors

hl.monitor({
    output = "DP-2",
    mode = "2560x1440@180",
    position = "0x0",
    scale = 1,
    bitdepth = 10,

    sdrbrightness = 1.3,
    sdrsaturation = 0.95,
})

hl.monitor({
    output = "HDMI-A-1",
    mode = "1920x1080@120",
    position = "2560x-240",
    scale = 1,
    transform = 1,
    disabled = 0
})


hl.config({
    general = {
        allow_tearing = false, -- you may want this, but false is a safe default
    },

    render = {
        direct_scanout = 0,
        cm_enabled = true,
        cm_auto_hdr = 0,
    },
})
