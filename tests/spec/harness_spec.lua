local assert = dofile(vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h') .. '/helpers/assert.lua')

describe('harness', function()
    it('asserts equality on tables and scalars', function()
        assert.eq(1 + 1, 2)
        assert.eq({ a = { 1, 2 } }, { a = { 1, 2 } })
    end)

    it('detects expected errors', function()
        assert.errors(function() error('boom') end)
    end)

    it('loads luxline from the repo runtimepath', function()
        assert.eq(require('luxline')._VERSION, '3.0.0')
    end)
end)
