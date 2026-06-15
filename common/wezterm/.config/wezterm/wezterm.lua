local wezterm = require "wezterm"

return {
  font = wezterm.font "JetBrains Mono",
  font_size = 12.0,
  line_height = 1.2,
  color_scheme = "Catppuccin Mocha",
  enable_tab_bar = false,
  window_background_opacity = 0.85,
  macos_window_background_blur = 30,
  keys = {
    { key = "v", mods = "ALT", action = wezterm.action { PasteFrom = "Clipboard" } },
    { key = "c", mods = "ALT", action = wezterm.action { CopyTo = "ClipboardAndPrimarySelection" } },
    { key = "t", mods = "ALT", action = wezterm.action { SpawnTab = "CurrentPaneDomain" } },
    { key = "w", mods = "ALT", action = wezterm.action { CloseCurrentTab = { confirm = true } } },
    { key = "n", mods = "ALT", action = wezterm.action { ActivateTabRelative = 1 } },
    { key = "N", mods = "ALT", action = wezterm.action { ActivateTabRelative = -1 } },
  },
}
