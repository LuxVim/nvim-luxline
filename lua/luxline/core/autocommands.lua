local M = {}

function M.setup()
    local group = vim.api.nvim_create_augroup('Luxline', { clear = true })
    local update_manager = require('luxline.core.update_manager')
    local events = require('luxline.core.events')
    
    vim.api.nvim_create_autocmd('ColorScheme', {
        group = group,
        callback = function()
            events.emit('colorscheme_changed')
        end,
    })
    
    vim.api.nvim_create_autocmd({ 'VimEnter', 'BufEnter', 'WinEnter' }, {
        group = group,
        callback = function()
            update_manager.update()
        end,
    })
    
    vim.api.nvim_create_autocmd({ 'BufLeave', 'WinLeave' }, {
        group = group,
        callback = function()
            update_manager.update()
        end,
    })
    
    vim.api.nvim_create_autocmd('FileType', {
        group = group,
        callback = function()
            update_manager.update()
        end,
    })
    
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        group = group,
        callback = function()
            update_manager.throttled_update()
        end,
    })
    
    vim.api.nvim_create_autocmd('VimResized', {
        group = group,
        callback = function()
            update_manager.update()
        end,
    })
end

return M