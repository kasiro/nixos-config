--  _   _                  _                 _     _____              __ _
-- | | | |                | |               | |   /  __ \            / _(_)
-- | |_| |_   _ _ __  _ __| | __ _ _ __   __| |   | /  \/ ___  _ __ | |_ _  __ _
-- |  _  | | | | '_ \| '__| |/ _` | '_ \ / _` |   | |    / _ \| '_ \|  _| |/ _` |
-- | | | | |_| | |_) | |  | | (_| | | | | (_| |   | \__/\ (_) | | | | | | | (_| |
-- \_| |_/\__, | .__/|_|  |_|\__,_|_| |_|\__,_|    \____/\___/|_| |_|_| |_|\__, |
--         __/ | |                                                          __/ |
--        |___/|_|                                                         |___/
--
-- Based on swrneko/dots-next
-- Lua config for Hyprland >= 0.55 (hyprlang deprecated since 0.55)
-- Place at ~/.config/hypr/hyprland.lua

-- ======== --
-- FEATURES --
-- ======== --

local features = {
    dynamic_cursors = false,
    nvidia = false,
    extra_autostart = false,
}

-- ======== --
-- PROGRAMS --
-- ======== --

local terminal     = "kitty"
local fileManager  = "nemo"
local browser      = "firefox" -- zen-browser в системе не установлен
local taskManager  = terminal .. " -e btop"
local menu         = "noctalia msg panel-toggle launcher"

-- ======== --
-- MONITORS --
-- ======== --

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

-- ========= --
-- AUTOSTART --
-- ========= --

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpm reload")
    hl.exec_cmd("noctalia -d")
    hl.exec_cmd("/run/wrappers/bin/xdg-desktop-portal-hyprland")
    hl.exec_cmd("/run/wrappers/bin/xdg-desktop-portal-gtk")

    if features.extra_autostart then
        hl.exec_cmd("Telegram -startintray")
        hl.exec_cmd("udiskie -s -m flat --menu-update-workaround")
        hl.exec_cmd("steam -silent", { workspace = "10 silent" })
        hl.exec_cmd("discord --start-minimized", { workspace = "10 silent" })
        hl.exec_cmd("firefox", { workspace = "1 silent" })
    end
end)

-- ===================== --
-- ENVIRONMENT VARIABLES --
-- ===================== --

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("QT_SCALE_FACTORS", "1.3")
hl.env("QT_ENABLE_HIGHDPI_SCALING", "1")
hl.env("QT_FONT_DPI", "81")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_SCALE_FACTOR_ROUNDING_POLICY", "RoundPreferFloor")
hl.env("GTK_SCALE", "1")
hl.env("GDK_DPI_SCALE", "1")
hl.env("GTK_USE_PORTAL", "1")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "afterglow")
hl.env("HYPRCURSOR_SIZE", "24")

-- NVIDIA (GTX 950, legacy_580) — выставляем всегда, независимо от features.nvidia
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")

if features.nvidia then
    hl.env("LIBVA_DRIVER_NAME", "nvidia")
    hl.env("XDG_SESSION_TYPE", "wayland")
    hl.env("GBM_BACKEND", "nvidia-drm")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
end

-- ============= --
-- LOOK AND FEEL --
-- ============= --

hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 15,
        border_size = 3,

        col = {
            active_border   = "rgb(7366bd)",
            inactive_border = "rgb(4c4f69)",
        },

        layout                  = "dwindle",
        allow_tearing           = false,
        resize_on_border        = true,
        extend_border_grab_area = 15,
    },

    decoration = {
        rounding           = 18,
        active_opacity     = 1.0,
        fullscreen_opacity = 1.0,

        blur = {
            enabled            = true,
            size               = 8,
            passes             = 3,
            new_optimizations  = true,
            popups             = false,
            popups_ignorealpha = 0.15,
            ignore_opacity     = true,
        },

        shadow = {
            enabled = false,
        },

        dim_inactive = true,
        dim_strength = 0.25,
        dim_around   = 0.1,
    },

    input = {
        kb_layout      = "us, ru",
        kb_options     = "grp:alt_shift_toggle",
        force_no_accel = true,   -- отключает акселерацию мыши (flat profile)
        follow_mouse   = 1,
        sensitivity    = 0,      -- 0 = нет ускорения/замедления (диапазон: -1.0 до 1.0)

        touchpad = {
            natural_scroll = false,
        },
    },

    dwindle = {
        preserve_split = true,
        force_split    = 2,
    },

    cursor = {
        no_warps            = true,
        no_hardware_cursors = true,
    },

    xwayland = {
        enabled              = true,
        force_zero_scaling   = true,
        use_nearest_neighbor = true,
    },

    group = {
        auto_group = false,
    },

    misc = {
        force_default_wallpaper   = 0,
        disable_hyprland_logo     = true,
        layers_hog_keyboard_focus = true,
    },

    animations = {
        enabled = true,
    },
})

-- Plugin options
if features.dynamic_cursors then
    hl.config({
        plugin = {
            ["dynamic-cursors"] = {
                enabled   = true,
                mode      = "tilt",
                threshold = 1,

                rotate  = { length = 20, offset = 0.0 },
                tilt    = { limit = 5000, ["function"] = "negative_quadratic", window = 100, full_tilt = 60 },
                stretch = { limit = 3000, ["function"] = "quadratic", window = 100 },
                shake   = { enabled = false },

                hyprcursor = {
                    nearest    = true,
                    enabled    = true,
                    resolution = -1,
                    fallback   = "clientside",
                },
            },
        },
    })
end

-- ========== --
-- ANIMATIONS --
-- ========== --

hl.curve("wind",   { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1 } } })
hl.curve("winIn",  { type = "bezier", points = { { 0.1, 1 }, { 0.1, 1.05 } } })
hl.curve("winOut", { type = "bezier", points = { { 0.3, 0 }, { 0, 1 } } })
hl.curve("layIn",  { type = "bezier", points = { { 0.1, 1 }, { 0.1, 1.1 } } })
hl.curve("layOut", { type = "bezier", points = { { 0.3, 0 }, { 0, 1 } } })
hl.curve("liner",  { type = "bezier", points = { { 1, 1 }, { 1, 1 } } })

hl.animation({ leaf = "windows",             enabled = true, speed = 6,  bezier = "wind",   style = "slide" })
hl.animation({ leaf = "windowsIn",           enabled = true, speed = 6,  bezier = "winIn",  style = "slide" })
hl.animation({ leaf = "windowsOut",          enabled = true, speed = 6,  bezier = "winOut", style = "slide" })
hl.animation({ leaf = "windowsMove",         enabled = true, speed = 6,  bezier = "wind",   style = "slide" })
hl.animation({ leaf = "border",              enabled = true, speed = 1,  bezier = "liner" })
hl.animation({ leaf = "borderangle",         enabled = true, speed = 30, bezier = "liner",  style = "loop" })
hl.animation({ leaf = "fade",                enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "workspaces",          enabled = true, speed = 5,  bezier = "wind" })
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 5,  bezier = "winIn",  style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 6,  bezier = "winOut", style = "slidevert" })
hl.animation({ leaf = "layersIn",            enabled = true, speed = 5,  bezier = "layIn",  style = "slide" })
hl.animation({ leaf = "layersOut",           enabled = true, speed = 5,  bezier = "layOut", style = "slide" })

-- ======== --
-- KEYBINDS --
-- ======== --

local mainMod = "SUPER"

local function bind(keys, dispatcher, opts)
    return hl.bind(mainMod .. " + " .. keys, dispatcher, opts)
end

-- Program launch (Sway-style)
bind("Return", hl.dsp.exec_cmd(terminal))        -- SUPER+Return: терминал
bind("A",      hl.dsp.exec_cmd("fuzzel"))        -- SUPER+A: fuzzel launcher
bind("SHIFT + A", hl.dsp.exec_cmd("wofi --show drun"))  -- SUPER+Shift+A: wofi fallback
bind("E",      hl.dsp.exec_cmd(fileManager))
bind("Y",      hl.dsp.exec_cmd(browser))
bind("D",      hl.dsp.exec_cmd(menu))
bind("U",      hl.dsp.exec_cmd(taskManager))

-- Window management (Sway-style)
bind("Q",         hl.dsp.exec_cmd("hyprctl dispatch killactive"))  -- SUPER+Q: kill window
bind("F",         hl.dsp.window.fullscreen({ action = "toggle" }))  -- SUPER+F: fullscreen
bind("G",         hl.dsp.window.float({ action = "toggle" }))       -- SUPER+G: floating toggle
bind("SPACE",     hl.dsp.exec_cmd("hyprctl dispatch focusmode_toggle"))  -- SUPER+Space: focus mode
bind("D",         hl.dsp.exec_cmd("hyprctl dispatch focusparent"))  -- SUPER+D: focus parent (дублирует menu, оставить для совместимости)
bind("SHIFT + Q", hl.dsp.window.close())         -- SUPER+Shift+Q: close window (альтернатива)
bind("SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle" }))  -- дубль для совместимости
bind("SHIFT + T", hl.dsp.layout("togglesplit"))
bind("SHIFT + M", hl.dsp.window.move({ workspace = "special:magic" }))
bind("SHIFT + S", hl.dsp.window.float({ action = "toggle" }))  -- дубль
bind("SHIFT + P", hl.dsp.window.pseudo({ action = "toggle" }))

-- Smart move (COSMIC-style: на краю экрана — переход на соседний workspace)
bind("SHIFT + LEFT",  hl.dsp.exec_cmd("/home/kasiro/nixos-config/.venv/bin/python3 /home/kasiro/nixos-config/home/kasiro/desktop/sway/scripts/smart-move.py left"))
bind("SHIFT + RIGHT", hl.dsp.exec_cmd("/home/kasiro/nixos-config/.venv/bin/python3 /home/kasiro/nixos-config/home/kasiro/desktop/sway/scripts/smart-move.py right"))

-- Resize mode
bind("R", hl.dsp.exec_cmd("hyprctl dispatch togglespecialworkflow resize"))  -- SUPER+R: resize mode

-- System
bind("SHIFT + E", hl.dsp.exec_cmd("hyprctl dispatch exit"))  -- SUPER+Shift+E: выход из сессии
bind("SHIFT + ALT + E", hl.dsp.exit())
bind("CONTROL + L", hl.dsp.exec_cmd("hyprlock"))

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set +2%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 2%-"), { locked = true, repeating = true })

-- Volume & media
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),       { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),     { locked = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"),                             { locked = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),                                   { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),                               { locked = true })

-- Alt-tab
bind("Tab", hl.dsp.window.cycle_next({ next = false }))
hl.bind("ALT + Tab", hl.dsp.window.bring_to_top())

-- Screenshots (Sway-style)
hl.bind("Print", hl.dsp.exec_cmd([[grim - | wl-copy]]))  -- полный скриншот в буфер
hl.bind("SHIFT + Print", hl.dsp.exec_cmd([[grim -g "$(slurp -d)" - | wl-copy]]))  -- область в буфер
hl.bind("CONTROL + Print", hl.dsp.exec_cmd(
    [[mkdir -p ~/Pictures/Screenshots && grim -g "$(slurp -d)" - ]] ..
    [[| tee ~/Pictures/Screenshots/$(date +'%Y-%m-%d-%H%M%S').png | wl-copy]]
))  -- область с сохранением

-- Focus / move / resize with HJKL
local directions = { H = "left", L = "right", K = "up", J = "down" }
local resizeStep = { H = { -20, 0 }, L = { 20, 0 }, K = { 0, -20 }, J = { 0, 20 } }

for key, dir in pairs(directions) do
    bind(key, hl.dsp.focus({ direction = dir }))
    bind("SHIFT + " .. key, hl.dsp.window.swap({ direction = dir }))
    bind("ALT + " .. key, hl.dsp.window.move({ direction = dir }))

    local step = resizeStep[key]
    bind("CONTROL + " .. key,
        hl.dsp.window.resize({ x = step[1], y = step[2], relative = true }),
        { repeating = true })
end

-- Стрелки: навигация / перемещение / ресайз (дублируют HJKL)
local arrowDirections = { left = "left", right = "right", up = "up", down = "down" }
local arrowResize = { left = { -20, 0 }, right = { 20, 0 }, up = { 0, -20 }, down = { 0, 20 } }

for key, dir in pairs(arrowDirections) do
    bind(key, hl.dsp.focus({ direction = dir }))
    bind("SHIFT + " .. key, hl.dsp.window.swap({ direction = dir }))
    bind("ALT + " .. key, hl.dsp.window.move({ direction = dir }))

    local step = arrowResize[key]
    bind("CONTROL + " .. key,
        hl.dsp.window.resize({ x = step[1], y = step[2], relative = true }),
        { repeating = true })
end

-- Cycle floating / tiled
bind("N",         hl.dsp.window.cycle_next({ floating = true }))
bind("SHIFT + N", hl.dsp.window.cycle_next({ tiled = true }))

-- Workspaces (Sway-style: Control+Num для переключения, SUPER+Num тоже оставить)
for i = 1, 10 do
    local key = (i == 10) and 0 or i
    bind(tostring(key), hl.dsp.focus({ workspace = i }))           -- SUPER+1-10: переключение
    bind("SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))  -- SUPER+Shift+1-10: перемещение окна
    bind("CONTROL + " .. key, hl.dsp.focus({ workspace = i }))      -- CONTROL+1-10: переключение (Sway-style)
end

bind("mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind("mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move / resize with mouse
bind("mouse:272", hl.dsp.window.drag(),   { mouse = true })
bind("mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ============ --
-- WINDOW RULES --
-- ============ --

hl.window_rule({
    name  = "waydroid-fullscreen",
    match = { class = "Waydroid" },
    float      = true,
    fullscreen = true,
})

hl.window_rule({
    name    = "xwayland-no-blur",
    match   = { xwayland = true },
    no_blur = true,
})

hl.window_rule({
    name             = "xwayland-float-no-initial-focus",
    match            = { xwayland = true, float = true },
    no_initial_focus = true,
})

hl.window_rule({
    name   = "float-no-dim",
    match  = { float = true },
    no_dim = true,
})

hl.window_rule({
    name   = "dialogs-float-center",
    match  = { title = "^(Open|Save|Choose|Select|Library|File Upload|Choose wallpaper)(.*)$" },
    float  = true,
    center = true,
})

-- =========== --
-- LAYER RULES --
-- =========== --

hl.layer_rule({
    name  = "noctalia-blur",
    match = { namespace = "^noctalia-(bar|desktop-widget)-.*$" },
    blur         = true,
    ignore_alpha = 0.35,
})

hl.layer_rule({
    name      = "fade-logout-dialog",
    match     = { namespace = "logout_dialog" },
    animation = "fade",
})

hl.layer_rule({
    name      = "fade-selection",
    match     = { namespace = "selection" },
    animation = "fade",
})

-- =============== --
-- WORKSPACE RULES --
-- =============== --

local workspaceNames = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" }

for i, name in ipairs(workspaceNames) do
    hl.workspace_rule({
        workspace    = tostring(i),
        default_name = name,
    })
end
