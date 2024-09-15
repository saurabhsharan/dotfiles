local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.default_prog = { "fish" }

-- To debug key events, un-comment this and run `wezterm start --always-new-process` from GNOME Console
-- config.debug_key_events = true

config.color_scheme = "Tokyo Night"

config.enable_scroll_bar = true

config.hide_tab_bar_if_only_one_tab = true

config.font = wezterm.font("Source Code Pro", { weight = "Regular", stretch = "Normal", style = "Normal" })
config.font_size = 13
config.warn_about_missing_glyphs = false

config.window_background_opacity = 0.9
config.window_decorations = "RESIZE"

config.keys = {
	{
		key = "t",
		mods = "SUPER",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "w",
		mods = "SUPER",
		action = wezterm.action.CloseCurrentTab({ confirm = true }),
	},
	{
		key = "{",
		mods = "SHIFT|ALT",
		action = wezterm.action.ActivateTabRelative(-1),
	},
	{
		key = "}",
		mods = "SHIFT|ALT",
		action = wezterm.action.ActivateTabRelative(1),
	},
}

-- Without this, wezterm can't open on display with any display scaling other than 100%
-- https://github.com/wez/wezterm/issues/5263
config.enable_wayland = false

return config
