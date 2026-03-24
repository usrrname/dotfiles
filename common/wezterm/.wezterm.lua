local wezterm = require("wezterm")
local config = {}
wezterm.log_info("Config file " .. wezterm.config_file)
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Window
config.adjust_window_size_when_changing_font_size = true
config.window_background_opacity = 1.0
config.scrollback_lines = 1000
config.enable_scroll_bar = true

-- Display
config.color_scheme = "Catppuccin Macchiato"
config.initial_cols = 1400
config.initial_rows = 800

-- Font
config.font = wezterm.font("Hack Nerd Font Mono", { weight = "Regular" })
config.font_size = 13.3
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
		intensity = "Normal",
		font = wezterm.font("JetBrains Mono"),
	},
}

-- Keyboard
config.enable_kitty_keyboard = true
config.enable_csi_u_key_encoding = true

-- Bell
config.audible_bell = "Disabled"

-- Tab bar
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true

-- Behavior
config.automatically_reload_config = true
config.detect_password_input = true

-- Keys
-- MacOS only: bind command key to ctrl in nvim --
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
	-- MacOS Only: map cmd to ctrl so CMD+s = save --
	{ key = "s", mods = "CMD", action = wezterm.action_callback(bind_cmd_to_nvim("s", "CTRL")) },
	-- MacOS only: CMD + shift + P opens Terminal Command Pallete --
	{ key = "P", mods = "SHIFT|CMD", action = wezterm.action.ActivateCommandPalette },
}

-- Mouse
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'SUPER',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
  {
    event = { Down = { streak = 1, button = 'Left' } },
    mods = 'SUPER',
    action = wezterm.action.Nop,
  },
}

wezterm.on('open-uri', function(window, pane, uri)
  if uri:find '^https?://' == 1 then
    return
  end
end)

return config
