local M = {}

local config = require('luxline.config')
local lifecycle = require('luxline.core.lifecycle')
local update_manager = require('luxline.core.update_manager')
local debug = require('luxline.debug')
local themes = require('luxline.themes')

M.config = config

-- Core functionality delegates
M.setup = lifecycle.setup
M.reset = lifecycle.reset
M.reload = lifecycle.reload
M.get_stats = lifecycle.get_stats

-- Update functionality delegates  
M.update = update_manager.update
M.throttled_update = update_manager.throttled_update

-- Debug functionality delegates
M.debug = debug.debug
M.preview_config = debug.preview_config

-- Theme functionality delegates
M.set_theme = themes.set_theme

return M