local M = {}

local definition = require('luxline.items.definition')

local factories = {}

function M.register_factory(type_name, factory)
    factories[type_name] = factory
end

function M.get_factory(type_name)
    return factories[type_name]
end

function M.create_buffer_option_item(name, option_name, opts)
    opts = opts or {}
    definition.define(name, {
        description = opts.description or (name .. ' indicator'),
        category = opts.category or 'file',
        cache = opts.cache,
        cache_ttl = opts.cache_ttl,
        variants = opts.variants,
        format = opts.default_format,
        get = function(ctx)
            if ctx and ctx.bufnr then
                return vim.api.nvim_get_option_value(option_name, { buf = ctx.bufnr })
            end
            return vim.bo[option_name]
        end,
    })
end

function M.create_file_path_item(name, opts)
    opts = opts or {}
    local variants = {
        full = function() return vim.fn.expand('%:p') end,
        relative = function() return vim.fn.expand('%:~:.') end,
        tail = function(filename) return filename end,
    }
    for variant_name, fn in pairs(opts.variants or {}) do
        variants[variant_name] = fn
    end
    definition.define(name, {
        description = opts.description or 'File name',
        category = opts.category or 'file',
        cache = opts.cache,
        cache_ttl = opts.cache_ttl,
        variants = variants,
        format = function(filename)
            return filename ~= '' and filename or '[No Name]'
        end,
        get = function(ctx)
            return ctx and ctx.filename or vim.fn.expand('%:t')
        end,
    })
end

function M.create_encoding_item(name, opts)
    opts = opts or {}
    local short_names = opts.short_names or {
        ['utf-8'] = 'UTF8',
        ['utf-16'] = 'UTF16',
        ['latin1'] = 'LAT1',
    }
    definition.define(name, {
        description = opts.description or 'File encoding',
        category = 'file',
        variants = {
            short = function(enc) return short_names[enc] or enc end,
        },
        format = function(enc) return enc end,
        get = function()
            local enc = vim.bo.fileencoding
            return enc ~= '' and enc or vim.o.encoding
        end,
    })
end

M.register_factory('buffer_option', function(name, opts)
    M.create_buffer_option_item(name, opts.option, opts)
end)

M.register_factory('file_path', function(name, opts)
    M.create_file_path_item(name, opts)
end)

M.register_factory('encoding', function(name, opts)
    M.create_encoding_item(name, opts)
end)

return M