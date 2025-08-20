local M = {}

local state = require('luxline.core.state')

local cache = setmetatable({}, { __mode = "k" })

function M.ensure_string(value, default)
    if type(value) == 'string' and value ~= '' then
        return value
    end
    return default or ''
end

function M.safe_call(fn, default, ...)
    local ok, result = pcall(fn, ...)
    return ok and result or (default or '')
end

function M.format_highlight(name, content)
    if not name or not content or content == '' then
        return ''
    end
    return string.format('%%#%s# %s ', name, content)
end

function M.reverse_table(tbl)
    local reversed = {}
    for i = #tbl, 1, -1 do
        table.insert(reversed, tbl[i])
    end
    return reversed
end

function M.cache_get(namespace, key)
    local ns_cache = cache[namespace]
    if not ns_cache then
        return nil
    end
    
    local entry = ns_cache[key]
    if not entry then
        return nil
    end
    
    if entry.expires and vim.loop.now() > entry.expires then
        ns_cache[key] = nil
        return nil
    end
    
    return entry.value
end

function M.cache_set(namespace, key, value, ttl)
    if not cache[namespace] then
        cache[namespace] = {}
    end
    
    cache[namespace][key] = {
        value = value,
        expires = ttl and (vim.loop.now() + ttl) or nil,
        created = vim.loop.now()
    }
end

function M.cache_clear(namespace, key)
    if not namespace then
        cache = setmetatable({}, { __mode = "k" })
        return
    end
    
    if not cache[namespace] then
        return
    end
    
    if key then
        cache[namespace][key] = nil
    else
        cache[namespace] = nil
    end
end

function M.deep_merge(target, source)
    target = target or {}
    if type(source) ~= 'table' then
        return source
    end
    
    for key, value in pairs(source) do
        if type(value) == 'table' and type(target[key]) == 'table' then
            target[key] = M.deep_merge(target[key], value)
        else
            target[key] = value
        end
    end
    
    return target
end

function M.split_item_variant(item_spec)
    local name, variant = item_spec:match('^([^:]+):?(.*)$')
    return name, variant ~= '' and variant or nil
end

local function create_context_fields(winid, bufnr, current_win)
    return {
        active = winid == current_win,
        winid = winid,
        bufnr = bufnr,
        filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr }),
        buftype = vim.api.nvim_get_option_value('buftype', { buf = bufnr }),
        filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t'),
        cwd = vim.fn.getcwd()
    }
end

function M.create_context(winid, bufnr)
    winid = winid or vim.api.nvim_get_current_win()
    bufnr = bufnr or vim.api.nvim_win_get_buf(winid)
    local current_win = vim.api.nvim_get_current_win()
    
    return create_context_fields(winid, bufnr, current_win)
end

function M.get_current_context()
    return M.create_context()
end

function M.gather_window_info()
    local windows = {}
    local current_win = vim.api.nvim_get_current_win()
    
    for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
            local bufnr = vim.api.nvim_win_get_buf(win)
            windows[win] = create_context_fields(win, bufnr, current_win)
        end
    end
    
    return windows
end

function M.validate_config_section(config, section, validator)
    if not config[section] then
        return {}
    end
    
    local errors = {}
    for key, expected_type in pairs(validator) do
        local value = config[section][key]
        if value ~= nil then
            local actual_type = type(value)
            if actual_type ~= expected_type then
                table.insert(errors, string.format(
                    '%s.%s expected %s, got %s',
                    section, key, expected_type, actual_type
                ))
            end
        end
    end
    
    return errors
end

function M.create_cache_key(item_name, variant, bufnr)
    return string.format('%s_%s_%s', item_name, variant or 'default', bufnr)
end

return M