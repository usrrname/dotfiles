local wezterm = require("wezterm")
local config = {}
local action = wezterm.action
wezterm.log_info("Config file " .. wezterm.config_file)
if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.adjust_window_size_when_changing_font_size = true
config.window_background_opacity = 1.0
config.scrollback_lines = 1000
config.enable_scroll_bar = true

config.color_scheme = "Catppuccin Macchiato"
config.initial_cols = 1400
config.initial_rows = 800

config.font = wezterm.font("Hack Nerd Font Mono", { weight = "Regular" })
config.font_size = 13.3
config.line_height = 1.3
config.font_rules = {
	{ intensity = "Normal", font = wezterm.font("Hack Nerd Font Mono", { weight = "Regular" }) },
	{ intensity = "Normal", italic = true, font = wezterm.font("Hack Nerd Font Mono", { weight = "Regular", italic = true }) },
	{ intensity = "Normal", font = wezterm.font("JetBrains Mono") },
}

config.enable_kitty_keyboard = true
config.enable_csi_u_key_encoding = true
config.audible_bell = "Disabled"
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.automatically_reload_config = true
config.detect_password_input = true

local function bind_cmd_to_nvim(key, mods)
	return function(window, pane)
		local process_name = pane:get_foreground_process_name()
		if process_name and process_name:match("nvim") then
			window:perform_action({ SendKey = { key = key, mods = mods } }, pane)
		else
			window:perform_action({ SendKey = { key = key, mods = "CMD" } }, pane)
		end
	end
end

config.keys = {
	{ key = "s", mods = "CMD", action = wezterm.action_callback(bind_cmd_to_nvim("s", "CTRL")) },
	{ key = "P", mods = "SHIFT|CMD", action = action.ActivateCommandPalette },
	{ key = "b", mods = "CTRL", action = "ActivateKeyTable", arg = "tmux_leader", one_shot = true },
}

config.key_tables = {
	tmux_leader = {
		{ key = "h", action = action.ActivatePaneDirection("Left") },
		{ key = "j", action = action.ActivatePaneDirection("Down") },
		{ key = "k", action = action.ActivatePaneDirection("Up") },
		{ key = "l", action = action.ActivatePaneDirection("Right") },
		{ key = '"', action = action.SplitHorizontal { domain = "CurrentPaneDomain" } },
		{ key = "%", action = action.SplitVertical { domain = "CurrentPaneDomain" } },
		{ key = "d", action = action.CloseCurrentPane { confirm = true } },
		{ key = "x", action = action.CloseCurrentPane { confirm = true } },
		{ key = "z", action = action.TogglePaneZoomState },
		{ key = "c", action = action.SpawnWindow },
		{ key = "n", action = action.ActivatePaneDirection("Next") },
		{ key = "p", action = action.ActivatePaneDirection("Prev") },
		{ key = "LeftArrow",  mods = "ALT|SHIFT", action = action.AdjustPaneSize { "Left", 5 } },
		{ key = "RightArrow", mods = "ALT|SHIFT", action = action.AdjustPaneSize { "Right", 5 } },
		{ key = "UpArrow",    mods = "ALT|SHIFT", action = action.AdjustPaneSize { "Up", 5 } },
		{ key = "DownArrow",  mods = "ALT|SHIFT", action = action.AdjustPaneSize { "Down", 5 } },
		{ key = "q", action = action.PaneSelect },
		{ key = "o", action = action.ActivatePaneDirection("Next") },
		{ key = "[", action = action.ActivateCopyMode },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},
}

config.mouse_bindings = {
	{ event = { Up = { streak = 1, button = "Left" } }, mods = "SUPER", action = action.OpenLinkAtMouseCursor },
	{ event = { Down = { streak = 1, button = "Left" } }, mods = "SUPER", action = action.Nop },
}

wezterm.on("open-uri", function(window, pane, uri)
	if uri:find "^https?://" == 1 then return end
end)

return config