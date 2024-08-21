local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.default_prog = { "fish" }
config.color_scheme = "GitHub Dark"

return config
