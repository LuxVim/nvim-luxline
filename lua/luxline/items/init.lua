local M = {}

local utils = require('luxline.core.utils')
local events = require('luxline.core.events')

local items = {}
local item_cache = {}

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
        cache_ttl = opts.cache_ttl or 1000,
        async = opts.async or false
    }
    
    events.emit('item_registered', { 
        name = name, 
        category = opts.category,
        variants = opts.variants 
    })
end

function M.get_value(item_name, variant, context)
    local item = items[item_name]
    if not item then
        return ''
    end
    
    context = context or utils.get_current_context()
    
    if item.cache then
        local cache_key = string.format('%s_%s_%s', item_name, variant or 'default', context.bufnr)
        local cached = item_cache[cache_key]
        
        if cached and (vim.loop.now() - cached.timestamp) < item.cache_ttl then
            return cached.value
        end
    end
    
    local ok, result = pcall(item.func, variant, context)
    if not ok then
        vim.notify('Item error (' .. item_name .. '): ' .. tostring(result), vim.log.levels.ERROR)
        return ''
    end
    
    result = utils.ensure_string(result, '')
    
    if item.cache and result ~= '' then
        local cache_key = string.format('%s_%s_%s', item_name, variant or 'default', context.bufnr)
        item_cache[cache_key] = {
            value = result,
            timestamp = vim.loop.now()
        }
    end
    
    return result
end

function M.get_item_info(name)
    return items[name]
end

function M.get_all_items()
    return vim.tbl_keys(items)
end

function M.get_items_by_category(category)
    local result = {}
    for name, item in pairs(items) do
        if item.category == category then
            table.insert(result, name)
        end
    end
    return result
end

function M.clear_cache(item_name)
    if item_name then
        for key, _ in pairs(item_cache) do
            if key:match('^' .. vim.pesc(item_name) .. '_') then
                item_cache[key] = nil
            end
        end
    else
        item_cache = {}
    end
    
    events.emit('item_cache_cleared', { item_name = item_name })
end

function M.auto_discover()
    local runtime_files = vim.api.nvim_get_runtime_file('lua/luxline/items/*.lua', true)
    local loaded_count = 0
    
    for _, file in ipairs(runtime_files) do
        local module_name = vim.fn.fnamemodify(file, ':t:r')
        if module_name ~= 'init' and module_name ~= 'metadata' then
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
    
    events.on('buffer_changed', function()
        M.clear_cache()
    end)
end

return M