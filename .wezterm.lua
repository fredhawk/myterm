local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.default_prog = {'/bin/bash'}
config.color_scheme = 'Tokyo Night Storm'
config.enable_tab_bar = false
config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 12.5
config.line_height = 1.2
config.window_background_opacity = 0.8
-- config.enable_wayland = false

return config
