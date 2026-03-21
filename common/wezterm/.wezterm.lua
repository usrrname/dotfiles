local wezterm = require("wezterm")
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.adjust_window_size_when_changing_font_size = true
config.window_background_opacity = 1.0
config.scrollback_lines = 1000
config.enable_scroll_bar = true

config.initial_cols = 1400
config.initial_rows = 800
config.font = wezterm.font("Hack Nerd Font Mono", { weight = "Regular" })
config.font_size = 13
config.line_height = 1.3
config.font_rules = {
	{
		intensity = "Normal",
		font = wezterm.font("Hack Nerd Font Mono", { weight = "Regular" }),
	},
	{
		intensity = "Normal",
		italic = true,
		font = wezterm.font("Hack Nerd Font Mono", { weight = "Regular", italic = true }),
	},
	{
		intensity = "Bold",
		font = wezterm.font("Hack Nerd Font Mono", { weight = "Bold" }),
	},
}

config.enable_kitty_keyboard = true
config.audible_bell = "Disabled"
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.automatically_reload_config = true
config.detect_password_input = true
config.enable_csi_u_key_encoding = true

-- MacOS only: bind command key to ctrl in nvim --
local function bind_cmd_to_nvim(key, mods)
	return function(window, pane)
		local process_name = pane:get_foreground_process_name()
		if process_name and process_name:match("nvim") then
			window:perform_action({ SendKey = { key = key, mods = mods } }, pane)
		else
			-- Fall back to default CMD behavior
			window:perform_action({ SendKey = { key = key, mods = "CMD" } }, pane)
		end
	end
end

config.keys = {
	-- MacOS Only: map cmd to ctrl so CMD+s = save --.
	{ key = "s", mods = "CMD", action = wezterm.action_callback(bind_cmd_to_nvim("s", "CTRL")) },
	-- MacOS only: CMD + shift + P opens Terminal Command Pallete --
	{ key = "P", mods = "SHIFT|CMD", action = wezterm.action.ActivateCommandPalette },
}
return config
