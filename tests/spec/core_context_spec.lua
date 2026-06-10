local assert = dofile(vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h') .. '/helpers/assert.lua')
local context = require('luxline.core.context')

describe('core.context', function()
    it('builds a context for the current window with all documented fields', function()
        local ctx = context.get_current_context()
        assert.eq(ctx.winid, vim.api.nvim_get_current_win())
        assert.eq(ctx.bufnr, vim.api.nvim_win_get_buf(ctx.winid))
        assert.eq(ctx.active, true)
        assert.truthy(ctx.filetype ~= nil)
        assert.truthy(ctx.buftype ~= nil)
        assert.truthy(ctx.filename ~= nil)
        assert.eq(ctx.cwd, vim.fn.getcwd())
    end)

    it('gathers one context per window across tabpages', function()
        vim.cmd('split')
        local windows = context.gather_window_info()
        local count = 0
        for winid, ctx in pairs(windows) do
            count = count + 1
            assert.eq(ctx.winid, winid)
        end
        assert.eq(count, #vim.api.nvim_list_wins())
        vim.cmd('only')
    end)
end)
