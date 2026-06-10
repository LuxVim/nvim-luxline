local assert = dofile(vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h') .. '/helpers/assert.lua')
local tbl = require('luxline.primitives.table')

describe('primitives.table', function()
    it('deep-merges nested maps, source wins', function()
        local target = { a = { x = 1, y = 2 }, b = 1 }
        local result = tbl.deep_merge(target, { a = { y = 3, z = 4 }, c = 5 })
        assert.eq(result, { a = { x = 1, y = 3, z = 4 }, b = 1, c = 5 })
    end)

    it('returns the source when it is not a table', function()
        assert.eq(tbl.deep_merge({ a = 1 }, 'scalar'), 'scalar')
    end)

    it('reverses lists', function()
        assert.eq(tbl.reverse({ 1, 2, 3 }), { 3, 2, 1 })
        assert.eq(tbl.reverse({}), {})
    end)
end)
