local M = {}

function M.validate_config(user_config)
    local errors = {}
    
    local item_keys = {
        'left_active_items', 'left_inactive_items',
        'right_active_items', 'right_inactive_items',
        'left_active_items_winbar', 'left_inactive_items_winbar',
        'right_active_items_winbar', 'right_inactive_items_winbar'
    }
    
    for _, key in ipairs(item_keys) do
        if user_config[key] and type(user_config[key]) ~= 'table' then
            table.insert(errors, key .. ' must be a table/array')
        end
    end
    
    local number_keys = {
        'update_throttle', 'git_cache_timeout', 'git_diff_debounce'
    }
    
    for _, key in ipairs(number_keys) do
        local value = user_config[key]
        if value and (type(value) ~= 'number' or value < 0) then
            table.insert(errors, key .. ' must be a positive number')
        end
    end
    
    local string_keys = {
        'left_separator', 'right_separator', 'default_theme'
    }
    
    local string_or_nil_keys = {
        'winbar_left_separator', 'winbar_right_separator',
        'left_separator_winbar', 'right_separator_winbar'
    }
    
    for _, key in ipairs(string_keys) do
        if user_config[key] and type(user_config[key]) ~= 'string' then
            table.insert(errors, key .. ' must be a string')
        end
    end
    
    for _, key in ipairs(string_or_nil_keys) do
        local value = user_config[key]
        if value ~= nil and type(value) ~= 'string' then
            table.insert(errors, key .. ' must be a string or nil')
        end
    end
    
    if user_config.buffer_exclude and type(user_config.buffer_exclude) ~= 'table' then
        table.insert(errors, 'buffer_exclude must be a table/array')
    end
    
    if user_config.git_enabled and type(user_config.git_enabled) ~= 'boolean' then
        table.insert(errors, 'git_enabled must be a boolean')
    end
    
    if user_config.winbar_enabled and type(user_config.winbar_enabled) ~= 'boolean' then
        table.insert(errors, 'winbar_enabled must be a boolean')
    end
    
    if #errors > 0 then
        error('Luxline configuration errors:\n' .. table.concat(errors, '\n'))
    end
    
    return true
end

return M