local M = {}

local config = require('luxline.config')
local bar_builder = require('luxline.rendering.bar_builder')
local state = require('luxline.core.state')

local update_timer = nil

function M.setup_events()
    local group = vim.api.nvim_create_augroup('LuxlineUpdate', { clear = true })
    
    vim.api.nvim_create_autocmd({'BufEnter', 'WinEnter', 'BufWritePost'}, {
        group = group,
        callback = function()
            M.throttled_update()
        end,
    })
end

function M.update()
    if not state.get('initialized') then
        return
    end
    
    bar_builder.statusline.update_all()
    if config.get().winbar_enabled then
        bar_builder.winbar.update_all()
    end
end

function M.throttled_update()
    if not state.get('initialized') then
        return
    end
    
    if update_timer then
        return
    end
    
    update_timer = vim.fn.timer_start(config.get().update_throttle, function()
        update_timer = nil
        bar_builder.statusline.update_all()
        if config.get().winbar_enabled then
            bar_builder.winbar.update_all()
        end
    end)
end

return M