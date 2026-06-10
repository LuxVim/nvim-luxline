local assert = dofile(vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h') .. '/helpers/assert.lua')

describe('core render wiring', function()
    it('owns render wiring solely in the Luxline augroup (LuxlineUpdate is gone)', function()
        require('luxline').setup({ git_enabled = false })
        local luxline_autocmds = vim.api.nvim_get_autocmds({ group = 'Luxline' })
        assert.truthy(#luxline_autocmds > 0)
        assert.errors(function()
            vim.api.nvim_get_autocmds({ group = 'LuxlineUpdate' })
        end, 'LuxlineUpdate augroup must no longer exist')
    end)

    it('triggers exactly one update per BufEnter', function()
        require('luxline').setup({ git_enabled = false })
        local update_manager = require('luxline.core.update_manager')
        local original = update_manager.update
        local original_throttled = update_manager.throttled_update
        local calls = 0
        update_manager.update = function() calls = calls + 1 end
        update_manager.throttled_update = function() calls = calls + 1 end
        vim.api.nvim_exec_autocmds('BufEnter', {})
        update_manager.update = original
        update_manager.throttled_update = original_throttled
        assert.eq(calls, 1)
    end)

    it('routes BufWritePost and CursorMoved through the throttled path', function()
        require('luxline').setup({ git_enabled = false })
        local update_manager = require('luxline.core.update_manager')
        local original = update_manager.throttled_update
        local calls = 0
        update_manager.throttled_update = function() calls = calls + 1 end
        vim.api.nvim_exec_autocmds('BufWritePost', {})
        vim.api.nvim_exec_autocmds('CursorMoved', {})
        update_manager.throttled_update = original
        assert.eq(calls, 2)
    end)
end)
