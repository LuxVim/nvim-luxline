local assert = dofile(vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h') .. '/helpers/assert.lua')
local definition = require('luxline.items.definition')
local items = require('luxline.items')

describe('items.definition', function()
    it('dispatches variant, then format, then tostring', function()
        definition.define('def_spec_item', {
            get = function() return 42 end,
            variants = { double = function(raw) return tostring(raw * 2) end },
            format = function(raw) return 'v' .. raw end,
        })
        assert.eq(items.get_value('def_spec_item', 'double', { bufnr = 0 }), '84')
        assert.eq(items.get_value('def_spec_item', nil, { bufnr = 0 }), 'v42')
        assert.eq(items.get_value('def_spec_item', 'unknown', { bufnr = 0 }), 'v42')

        definition.define('def_spec_plain', { get = function() return 7 end })
        assert.eq(items.get_value('def_spec_plain', nil, { bufnr = 0 }), '7')
    end)

    it('returns empty string when get yields nil', function()
        definition.define('def_spec_nil', { get = function() return nil end })
        assert.eq(items.get_value('def_spec_nil', nil, { bufnr = 0 }), '')
    end)

    it('exposes variants as a sorted array of names in item metadata', function()
        definition.define('def_spec_meta', {
            get = function() return '' end,
            variants = { zeta = function() return '' end, alpha = function() return '' end },
            description = 'meta test',
            category = 'spec',
        })
        local info = items.get_item_info('def_spec_meta')
        assert.eq(info.variants, { 'alpha', 'zeta' })
        assert.eq(info.category, 'spec')
        assert.eq(info.description, 'meta test')
    end)

    it('passes context to get and variant functions', function()
        definition.define('def_spec_ctx', {
            get = function(ctx) return ctx.filetype end,
            variants = { upper = function(raw, ctx) return raw:upper() .. '/' .. ctx.filetype end },
        })
        local ctx = { bufnr = 0, filetype = 'lua' }
        assert.eq(items.get_value('def_spec_ctx', 'upper', ctx), 'LUA/lua')
    end)
end)
