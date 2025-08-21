local M = {}

function M.create_buffer_option_item(name, option_name, opts)
    opts = opts or {}
    local variants = opts.variants or {}
    local category = opts.category or 'file'
    local cache = opts.cache or false
    local cache_ttl = opts.cache_ttl or 1000
    
    local function get_option_value(context)
        if context and context.bufnr then
            return vim.api.nvim_get_option_value(option_name, { buf = context.bufnr })
        else
            return vim.bo[option_name]
        end
    end
    
    local function format_value(value, variant)
        if variants[variant] then
            return variants[variant](value)
        elseif opts.default_format then
            return opts.default_format(value)
        else
            return tostring(value)
        end
    end
    
    local items = require('luxline.items')
    items.register(name, function(variant, context)
        local value = get_option_value(context)
        return format_value(value, variant)
    end, {
        description = opts.description or (name .. " indicator"),
        category = category,
        variants = vim.tbl_keys(variants),
        cache = cache,
        cache_ttl = cache_ttl
    })
end

function M.create_file_path_item(name, opts)
    opts = opts or {}
    local variants = opts.variants or {}
    local category = opts.category or 'file'
    local cache = opts.cache or false
    local cache_ttl = opts.cache_ttl or 1000
    
    local function get_filename(context)
        return context and context.filename or vim.fn.expand('%:t')
    end
    
    local function format_filename(filename, variant)
        if variants[variant] then
            return variants[variant](filename)
        elseif variant == 'full' then
            return vim.fn.expand('%:p')
        elseif variant == 'relative' then
            return vim.fn.expand('%:~:.')
        elseif variant == 'tail' then
            return filename
        else
            return filename ~= '' and filename or '[No Name]'
        end
    end
    
    local items = require('luxline.items')
    items.register(name, function(variant, context)
        local filename = get_filename(context)
        return format_filename(filename, variant)
    end, {
        description = opts.description or "File name",
        category = category,
        variants = vim.tbl_keys(variants),
        cache = cache,
        cache_ttl = cache_ttl
    })
end

function M.create_vim_function_item(name, vim_func, opts)
    opts = opts or {}
    local variants = opts.variants or {}
    local category = opts.category or 'misc'
    
    local function format_value(value, variant)
        if variants[variant] then
            return variants[variant](value)
        elseif opts.default_format then
            return opts.default_format(value)
        else
            return tostring(value)
        end
    end
    
    local items = require('luxline.items')
    items.register(name, function(variant, context)
        local value = vim.fn[vim_func]()
        return format_value(value, variant)
    end, {
        description = opts.description or (name .. " value"),
        category = category,
        variants = vim.tbl_keys(variants),
        cache = opts.cache or false,
        cache_ttl = opts.cache_ttl or 1000
    })
end

function M.create_encoding_item(name, opts)
    opts = opts or {}
    local short_names = opts.short_names or {
        ['utf-8'] = 'UTF8',
        ['utf-16'] = 'UTF16',
        ['latin1'] = 'LAT1'
    }
    
    local variants = {
        short = function(enc)
            return short_names[enc] or enc
        end
    }
    
    local items = require('luxline.items')
    items.register(name, function(variant, context)
        local enc = vim.bo.fileencoding
        if enc == '' then
            enc = vim.o.encoding
        end
        
        if variants[variant] then
            return variants[variant](enc)
        else
            return enc
        end
    end, {
        description = opts.description or "File encoding",
        category = "file",
        variants = { 'short' }
    })
end

return M