-- Hyprland Lua config — Omarchy-style with Nordic theme
-- Hyprland 0.55+

local n = require("nordic")

-- Programs
local term     = "kitty"
local launcher = "rofi -show drun -show-icons"
local browser  = "firefox"
local fm       = "thunar"
local editor   = "kitty -e nvim"
local lock     = "loginctl lock-session"
local power    = "~/.config/rofi/powermenu.sh"
local night    = "~/.config/hypr/scripts/toggle-nightlight.sh"
local wallsw   = "~/.config/hypr/scripts/wallpaper-switcher.sh"
local screen   = "grim -g \"$(slurp)\" - | wl-copy && notify-send 'Screenshot' 'Copied to clipboard'"
local screen_f = "grim - | wl-copy && notify-send 'Screenshot' 'Fullscreen copied to clipboard'"
local screenshot = "flameshot gui -c"
local themesw  = "~/.config/hypr/scripts/theme-switcher.sh"
local mainMod  = "SUPER"

-- Autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("waybar")
    hl.exec_cmd("bash -c 'kill $(pgrep hyprsunset) 2>/dev/null; hyprsunset --identity'")
    hl.exec_cmd("dunst")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("xsettingsd")
    hl.exec_cmd("bash -c 'DIR_CACHE=$HOME/.cache/current-wallpaper-dir; WDIR=$(cat \"$DIR_CACHE\" 2>/dev/null || echo \"$HOME/Pictures/wallpapers\"); CACHE=$HOME/.cache/current-wallpaper; W=$(cat \"$CACHE\" 2>/dev/null); [[ -f \"$W\" ]] || W=$(find \"$WDIR\" -type f \\( -name \\*.png -o -name \\*.jpg -o -name \\*.jpeg -o -name \\*.gif \\) | sort | head -1); killall swaybg 2>/dev/null; swaybg -i \"$W\" -m fill &'")
end)

-- Environment
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")
hl.env("AQ_NO_MODIFIERS", "1")

-- Monitors
hl.monitor({ output = "eDP-1",    mode = "1920x1080@60", position = "auto", scale = 1.25 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@74.97", position = "auto", scale = 1 })

-- Bind workspaces to monitors
hl.workspace_rule({ workspace = "1", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "3", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "4", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "5", monitor = "eDP-1" })

-- General config
hl.config({
    general = {
        gaps_in        = 2,
        gaps_out       = 4,
        border_size    = 1,
        col = {
            active_border   = n.cyan,
            inactive_border = n.muted,
        },
        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
        no_focus_fallback = true,
    },
    decoration = {
        rounding = 0,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = false,
        },
        blur = {
            enabled = false,
        },
    },
    -- Note: animations are set via hl.animation() below (not in hl.config)
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        focus_on_activate       = true,
    },
    input = {
        kb_layout  = "us",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = { natural_scroll = false },
    },
})

-- Gestures
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

-- Fast minimal animations
hl.curve("snappy", { type = "bezier", points = {{0.3, 0.15}, {0.7, 0.85}} })
hl.animation({ leaf = "windows",    enabled = true,  style = "popin", speed = 1, bezier = "snappy" })
hl.animation({ leaf = "fade",       enabled = false })
hl.animation({ leaf = "workspaces", enabled = true,  style = "slide", speed = 1, bezier = "snappy" })

-- Keybinds: applications
hl.bind(mainMod .. " + Return",  hl.dsp.exec_cmd(term))
hl.bind(mainMod .. " + Space",   hl.dsp.exec_cmd(launcher))
hl.bind(mainMod .. " + B",       hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd(editor))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd(fm))

-- Keybinds: window management
hl.bind(mainMod .. " + Q",     hl.dsp.window.close())
hl.bind(mainMod .. " + T",     hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F",     hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + J",     hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + P",     hl.dsp.window.pseudo())
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.window.pin())

-- Keybinds: focus and movement
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Keybinds: workspaces
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + Tab",     hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.focus({ workspace = "e-1" }))

-- Keybinds: system
hl.bind(mainMod .. " + N",         hl.dsp.exec_cmd(night))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(wallsw))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("kitty -e rmpc"))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd(themesw .. " menu"))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd(lock))
hl.bind(mainMod .. " + Escape",   hl.dsp.exec_cmd(power))
hl.bind("Print",                  hl.dsp.exec_cmd(screen))
hl.bind("SHIFT + Print",          hl.dsp.exec_cmd(screen_f))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(screenshot))

-- Keybinds: help
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd("notify-send 'Keybinds' \"Super+Return: Terminal\\nSuper+Space: Launcher\\nSuper+W: Close\\nSuper+T: Float\\nSuper+F: Fullscreen\\nSuper+J: Toggle Split\\nSuper+P: Pseudo\\nSuper+B: Browser\\nSuper+N: Night light\\nSuper+Shift+N: Neovim\\nSuper+Shift+F: File Manager\\nSuper+Shift+W: Wallpaper\\nSuper+Shift+M: Music (rmpc)\\nSuper+Shift+S: Screenshot region\\nSuper+Shift+T: Theme menu\\nSuper+1-0: Workspace\\nSuper+Shift+1-0: Move to workspace\\nSuper+arrows: Focus\\nSuper+Shift+arrows: Move\" --icon=preferences-desktop-keyboard"))

-- Mouse bindings
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

-- Media & volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })

hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Window rules
hl.window_rule({
    name   = "float-pinentry",
    match  = { class = "(pinentry-.*|pinentry)" },
    float  = true,
})

hl.window_rule({
    name   = "float-pavucontrol",
    match  = { class = "(pavucontrol|blueman-manager)" },
    float  = true,
})

hl.window_rule({
    name   = "float-im-discord",
    match  = { class = "(.?(discord|webcord|discord-canary).?)" },
    float  = true,
})

hl.window_rule({
    name   = "float-firefox-pip",
    match  = { class = "firefox", title = "(Picture-in-Picture)" },
    float  = true,
    pin    = true,
})

hl.window_rule({
    name   = "float-xdg",
    match  = { class = "(xdg-desktop-portal.*|Xdg-desktop-portal.*)" },
    float  = true,
})

hl.window_rule({
    name   = "no-focus-xwayland-drags",
    match  = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})
