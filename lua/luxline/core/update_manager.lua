local M = {}

local config = require('luxline.config')
local statusline = require('luxline.rendering.statusline')
local winbar = require('luxline.rendering.winbar')
local events = require('luxline.core.events')
local debounce = require('luxline.core.debounce')
local state = require('luxline.core.state')

function M.setup_events()
    events.on('theme_changed', function()
        statusline.update_all()
        if config.get().winbar_enabled then
            winbar.update_all()
        end
    end)
    
    events.on('git_command_completed', function()
        M.update()
    end)
    
    events.on('statusline_update_requested', function()
        M.update()
    end)
    
    events.on('config_updated', function()
        statusline.update_all()
        if config.get().winbar_enabled then
            winbar.update_all()
        end
    end)
end

function M.update()
    if not state.get('initialized') then
        return
    end
    
    statusline.update_all()
    if config.get().winbar_enabled then
        winbar.update_all()
    end
end

function M.throttled_update()
    if not state.get('initialized') then
        return
    end
    
    debounce.throttle('statusline_update', config.get().update_throttle, function()
        statusline.update_all()
        if config.get().winbar_enabled then
            winbar.update_all()
        end
    end)
end

return M