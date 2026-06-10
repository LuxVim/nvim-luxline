local assert = dofile(vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h') .. '/helpers/assert.lua')
local base = require('luxline.items.base')
local items = require('luxline.items')

describe('items.base', function()
    it('exposes a factory registry with the three shipped factories', function()
        assert.truthy(base.get_factory('buffer_option'))
        assert.truthy(base.get_factory('file_path'))
        assert.truthy(base.get_factory('encoding'))
        assert.eq(base.get_factory('vim_function'), nil, 'create_vim_function_item is removed')
    end)

    it('registers new factories through the registry', function()
        base.register_factory('constant', function(name, opts)
            require('luxline.items.definition').define(name, { get = function() return opts.value end })
        end)
        base.get_factory('constant')('base_spec_constant', { value = 'fixed' })
        assert.eq(items.get_value('base_spec_constant', nil, { bufnr = 0 }), 'fixed')
    end)

    it('buffer_option factory reads the context buffer and applies variants', function()
        local buf = vim.api.nvim_create_buf(false, false)
        base.create_buffer_option_item('base_spec_modified', 'modified', {
            variants = {
                short = function(modified) return modified and '[+]' or '' end,
            },
            default_format = function(modified) return modified and '[Modified]' or '' end,
        })
        local ctx = { bufnr = buf }
        assert.eq(items.get_value('base_spec_modified', 'short', ctx), '')
        vim.api.nvim_set_option_value('modified', true, { buf = buf })
        assert.eq(items.get_value('base_spec_modified', 'short', ctx), '[+]')
        assert.eq(items.get_value('base_spec_modified', nil, ctx), '[Modified]')
    end)

    it('file_path factory falls back to [No Name] and supports tail variant', function()
        base.create_file_path_item('base_spec_filename', {})
        assert.eq(items.get_value('base_spec_filename', nil, { bufnr = 0, filename = '' }), '[No Name]')
        assert.eq(items.get_value('base_spec_filename', 'tail', { bufnr = 0, filename = 'x.lua' }), 'x.lua')
        assert.eq(items.get_item_info('base_spec_filename').variants, { 'full', 'relative', 'tail' })
    end)

    it('encoding factory shortens known encodings', function()
        base.create_encoding_item('base_spec_encoding', {})
        local value = items.get_value('base_spec_encoding', 'short', { bufnr = 0 })
        assert.truthy(value == 'UTF8' or value == vim.o.encoding, 'short maps utf-8 to UTF8')
    end)
end)
