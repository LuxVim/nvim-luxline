local M = {}

local autocmd = require('luxline.primitives.autocmd')

function M.setup()
    local update_manager = require('luxline.core.update_manager')
    local events = require('luxline.core.events')

    autocmd.bind('Luxline', {
        {
            events = { 'ColorScheme' },
            handler = function() events.emit('colorscheme_changed') end,
        },
        {
            events = { 'VimEnter', 'BufEnter', 'WinEnter', 'BufLeave', 'WinLeave', 'FileType', 'VimResized' },
            handler = function() update_manager.update() end,
        },
        {
            events = { 'CursorMoved', 'CursorMovedI', 'BufWritePost' },
            handler = function() update_manager.throttled_update() end,
        },
    })
end

return M