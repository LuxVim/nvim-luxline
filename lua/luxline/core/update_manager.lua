local M = {}

local config = require('luxline.config')
local bar_builder = require('luxline.rendering.bar_builder')
local state = require('luxline.core.state')
local events = require('luxline.core.events')
local timing = require('luxline.primitives.timing')

local function render()
    bar_builder.statusline.update_all()
    if config.get().winbar_enabled then
        bar_builder.winbar.update_all()
    end
end

local throttled_render = timing.throttle(render, function()
    return config.get().update_throttle or 20
end)

function M.setup_events()
    events.on('theme_changed', function()
        vim.schedule(function()
            M.update()
        end)
    end)
end

function M.update()
    if not state.get('initialized') then
        return
    end
    render()
end

function M.throttled_update()
    if not state.get('initialized') then
        return
    end
    throttled_render()
end

return M