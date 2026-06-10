local assert = dofile(vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h') .. '/helpers/assert.lua')
local autocmd = require('luxline.primitives.autocmd')

describe('primitives.autocmd', function()
    it('binds declarative specs into a cleared augroup', function()
        local calls = { user = 0, multi = 0 }
        autocmd.bind('LuxAutocmdSpec', {
            { events = { 'User' }, pattern = 'LuxSpecEvent', handler = function() calls.user = calls.user + 1 end },
            { events = { 'BufNew', 'BufAdd' }, handler = function() calls.multi = calls.multi + 1 end },
        })
        vim.api.nvim_exec_autocmds('User', { pattern = 'LuxSpecEvent' })
        assert.eq(calls.user, 1)
        local registered = vim.api.nvim_get_autocmds({ group = 'LuxAutocmdSpec' })
        assert.eq(#registered, 3, 'one per (event, spec) pair: User + BufNew + BufAdd')
    end)

    it('re-binding the same group clears previous registrations', function()
        local count = 0
        autocmd.bind('LuxAutocmdSpec2', {
            { events = { 'User' }, pattern = 'LuxSpecEvent2', handler = function() count = count + 1 end },
        })
        autocmd.bind('LuxAutocmdSpec2', {
            { events = { 'User' }, pattern = 'LuxSpecEvent2', handler = function() count = count + 10 end },
        })
        vim.api.nvim_exec_autocmds('User', { pattern = 'LuxSpecEvent2' })
        assert.eq(count, 10, 'only the second binding fires')
    end)
end)
