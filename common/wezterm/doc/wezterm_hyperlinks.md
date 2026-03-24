# Wezterm Hyperlink Integration

## Overview

Wezterm supports OSC 8 hyperlinks for clickable URLs and filepaths. This enables:

- **Cmd+Click URLs** → open in system browser
- **Cmd+Click `file://` paths** → open in Finder
- **Right-click** → native context menu

## Requirements

- Wezterm with OSC 8 support (enabled by default)
- `open-uri` handler in `.wezterm.lua` for URL handling

## Configuration

See `.wezterm.lua` for the current setup:

```lua
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
```

## Limitations

### Relative filepaths

Wezterm cannot resolve relative paths like `./foo.txt` to absolute paths at click time. The PWD is baked in when `hyperlink_rules` are evaluated, not dynamically.

**Solution**: Use shell tools that emit OSC 8 hyperlinks with absolute paths:

- `eza --hyperlink` — `ls` with clickable paths
- `bat --hyperlink=always` — source files with links
- `add-osc-8-hyperlink` — stdin filter wrapping paths

Example aliases:

```bash
alias ls='eza --hyperlink -la'
alias cat='bat --hyperlink=always'
```

### nvim terminal

Wezterm mouse bindings (including `OpenLinkAtMouseCursor`) do not fire when nvim owns the alternate screen. However, the `open-uri` event fires at the terminal level, so URLs in nvim output can still be clicked.

## Keybindings Summary

| Action | Result |
|--------|--------|
| `Cmd+LeftClick` | Open link/path at cursor |
| `Cmd+Nop` (Down) | Prevents default conflict |
| `RightClick` | Native context menu |
| Click URL | Browser (via default) |
| Click `file://` | Finder (via default) |
