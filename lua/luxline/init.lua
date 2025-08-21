--[[
nvim-luxline - A highly optimized, modular statusline and winbar plugin for Neovim

Features:
- Dual-bar system (statusline + winbar) with context-aware item selection
- Schema-driven configuration with filetype/buftype specificity
- Strategy-based highlight system (semantic + positional)
- Modular item system with reusable base patterns
- Performance-optimized with intelligent caching and throttling
- Extensive theme support with automatic lux colorscheme detection
- Git integration with async operations and debounced updates

Architecture:
- Core: lifecycle, state, events, utils, update management
- Config: schema-driven validation, defaults, unified key building
- Items: base patterns for buffer options, file paths, encoding, etc.
- Rendering: strategy-based highlights, bar building, caching
- Themes: validation, data separation, gradient support
- Integrations: git with caching, parser, commands
--]]

local M = {}

-- Core modules
local config = require('luxline.config')
local lifecycle = require('luxline.core.lifecycle')
local update_manager = require('luxline.core.update_manager')
local themes = require('luxline.themes')

-- Configuration access
M.config = config

-- Core functionality
M.setup = lifecycle.setup
M.reset = lifecycle.reset
M.reload = lifecycle.reload
M.get_stats = lifecycle.get_stats

-- Update system
M.update = update_manager.update
M.throttled_update = update_manager.throttled_update

-- Theme management
M.set_theme = themes.set_theme
M.get_theme = themes.get_theme
M.get_theme_names = themes.get_theme_names
M.create_theme = themes.create_theme
M.create_gradient_theme = themes.create_gradient_theme

-- Rendering system
M.bar_builder = function()
    return require('luxline.rendering.bar_builder')
end

-- Item system
M.items = function()
    return require('luxline.items')
end

M.create_item = function(name, opts)
    local base = require('luxline.items.base')
    if opts.type == 'buffer_option' then
        return base.create_buffer_option_item(name, opts.option, opts)
    elseif opts.type == 'file_path' then
        return base.create_file_path_item(name, opts)
    elseif opts.type == 'encoding' then
        return base.create_encoding_item(name, opts)
    elseif opts.type == 'vim_function' then
        return base.create_vim_function_item(name, opts.func, opts)
    else
        error('Unknown item type: ' .. tostring(opts.type))
    end
end

-- Highlight system
M.highlight = function()
    return require('luxline.rendering.highlight')
end

M.highlight_strategies = function()
    return require('luxline.rendering.highlight_strategies')
end

-- Configuration helpers
M.validate_config = function(user_config)
    local validation = require('luxline.config.validation')
    return validation.validate_config(user_config)
end

M.get_config_schema = function()
    return require('luxline.config.schema')
end

-- Debug functionality (lazy loaded)
M.debug = function()
    return require('luxline.debug').debug()
end

M.preview_config = function(config_override)
    return require('luxline.debug').preview_config(config_override)
end

-- Version info
M._VERSION = '2.0.0'
M._DESCRIPTION = 'nvim-luxline: Optimized statusline and winbar plugin'
M._HOMEPAGE = 'https://github.com/LuxVim/nvim-luxline'

return M
