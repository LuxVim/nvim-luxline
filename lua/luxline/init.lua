--[[
nvim-luxline - A modular statusline and winbar plugin for Neovim

Architecture:
- Primitives: color, timing, cache, table, autocmd (generic, dependency-free)
- Core: lifecycle, state, events, context, autocommands, update management
- Config: schema-driven validation, defaults, specificity resolver
- Items: declarative definition seam, factories, self-registering items
- Rendering: strategy-based highlights, bar building, separator blending
- Themes: validation, lux palettes, auto-theming from the active colorscheme
- Integrations: async git with debounced updates
--]]

local M = {}

local config = require('luxline.config')
local lifecycle = require('luxline.core.lifecycle')
local update_manager = require('luxline.core.update_manager')
local themes = require('luxline.themes')

M.config = config

M.setup = lifecycle.setup
M.reset = lifecycle.reset
M.reload = lifecycle.reload
M.get_stats = lifecycle.get_stats

M.update = update_manager.update
M.throttled_update = update_manager.throttled_update

M.set_theme = themes.set_theme
M.get_theme = themes.get_theme
M.get_theme_names = themes.get_theme_names
M.create_gradient_theme = themes.create_gradient_theme

M.debug = function()
    return require('luxline.debug').debug()
end

M.preview_config = function(config_override)
    return require('luxline.debug').preview_config(config_override)
end

M._VERSION = '3.0.0'
M._DESCRIPTION = 'nvim-luxline: Modular statusline and winbar plugin'
M._HOMEPAGE = 'https://github.com/LuxVim/nvim-luxline'

return M
