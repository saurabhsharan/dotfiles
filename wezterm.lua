local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- from https://github.com/wez/wezterm/discussions/4728
local is_darwin = wezterm.target_triple:find("darwin") ~= nil
local is_linux = wezterm.target_triple:find("linux") ~= nil

if is_darwin then
	config.default_prog = { "/opt/homebrew/bin/fish" }
else
	config.default_prog = { "fish" }
end

-- To debug key events, un-comment this and run `wezterm start --always-new-process` from GNOME Console
-- config.debug_key_events = true

config.color_scheme = "Tokyo Night"

config.enable_scroll_bar = true

config.hide_tab_bar_if_only_one_tab = true

config.skip_close_confirmation_for_processes_named = {
	-- default list from https://wezfurlong.org/wezterm/config/lua/config/skip_close_confirmation_for_processes_named.html
	"bash",
	"sh",
	"zsh",
	"fish",
	"tmux",
	"nu",
	"cmd.exe",
	"pwsh.exe",
	"powershell.exe",
	-- my custom additions
	"btop",
}

config.font = wezterm.font("Source Code Pro", { weight = "Regular", stretch = "Normal", style = "Normal" })
if is_darwin then
	config.font_size = 16
else
	config.font_size = 13
end
config.warn_about_missing_glyphs = false

config.window_background_opacity = 0.9

if is_linux then
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
end

return config
