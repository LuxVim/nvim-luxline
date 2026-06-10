local M = {}

local context = require('luxline.core.context')
local cache = require('luxline.primitives.cache')
local events = require('luxline.core.events')

local items = {}
local item_cache = cache.namespace('items')

local function create_cache_key(item_name, variant, bufnr)
    return string.format('%s_%s_%s', item_name, variant or 'default', bufnr)
end

function M.parse_spec(item_spec)
    local name, variant = item_spec:match('^([^:]+):?(.*)$')
    return name, variant ~= '' and variant or nil
end

function M.register(name, func, opts)
    opts = opts or {}

    if type(func) ~= 'function' then
        error('Item function must be a function')
    end

    items[name] = {
        func = func,
        description = opts.description or '',
        category = opts.category or 'misc',
        variants = opts.variants or {},
        cache = opts.cache or false,
        cache_ttl = opts.cache_ttl or 1000
    }

    events.emit('item_registered', {
        name = name,
        category = opts.category,
        variants = opts.variants
    })
end

function M.get_value(item_name, variant, ctx)
    local item = items[item_name]
    if not item then
        return ''
    end

    ctx = ctx or context.get_current_context()

    local cache_key
    if item.cache then
        cache_key = create_cache_key(item_name, variant, ctx.bufnr)
        local cached = item_cache:get(cache_key)
        if cached then
            return cached
        end
    end

    local ok, result = pcall(item.func, variant, ctx)
    if not ok then
        vim.notify('Item error (' .. item_name .. '): ' .. tostring(result), vim.log.levels.ERROR)
        return ''
    end

    result = (type(result) == 'string' and result ~= '') and result or ''

    if item.cache and result ~= '' then
        item_cache:set(cache_key, result, item.cache_ttl)
    end

    return result
end

function M.get_item_info(name)
    return items[name]
end

function M.get_all_items()
    return vim.tbl_keys(items)
end

function M.clear_cache(item_name)
    item_cache:clear()
    events.emit('item_cache_cleared', { item_name = item_name })
end

function M.auto_discover()
    local runtime_files = vim.api.nvim_get_runtime_file('lua/luxline/items/*.lua', true)
    local loaded_count = 0

    for _, file in ipairs(runtime_files) do
        local module_name = vim.fn.fnamemodify(file, ':t:r')
        if module_name ~= 'init' and module_name ~= 'metadata'
            and module_name ~= 'base' and module_name ~= 'definition' then
            local ok, _ = pcall(require, 'luxline.items.' .. module_name)
            if ok then
                loaded_count = loaded_count + 1
            else
                vim.notify('Failed to load item module: ' .. module_name, vim.log.levels.WARN)
            end
        end
    end

    events.emit('items_auto_discovered', { count = loaded_count })
    return loaded_count
end

function M.setup()
    M.auto_discover()
end

return M