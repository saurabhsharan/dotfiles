local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.default_prog = { "fish" }

config.color_scheme = "GitHub Dark"

config.enable_scroll_bar = true

config.font = wezterm.font("Source Code Pro", { weight = "Regular", stretch = "Normal", style = "Normal" })
config.font_size = 13

config.window_background_opacity = 0.9
config.window_decorations = "RESIZE"

return config
