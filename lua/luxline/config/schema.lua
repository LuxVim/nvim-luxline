local M = {}

-- Unified configuration schema
M.CONFIG_SCHEMA = {
    items = {
        type = 'table',
        sides = {'left', 'right'},
        statuses = {'active', 'inactive'},
        bar_types = {'statusline', 'winbar'},
        key_pattern = '%s_%s_items'
    },
    separators = {
        type = 'string',
        sides = {'left', 'right'},
        bar_types = {'statusline', 'winbar'},
        key_pattern = '%s_separator'
    },
    timeouts = {
        type = 'number',
        min = 0,
        keys = {'update_throttle', 'git_cache_timeout', 'git_diff_debounce'}
    },
    booleans = {
        type = 'boolean',
        keys = {'git_enabled', 'winbar_enabled'}
    },
    arrays = {
        type = 'table',
        keys = {'buffer_exclude', 'winbar_disabled_filetypes'}
    },
    strings = {
        type = 'string',
        keys = {'default_theme'}
    }
}

function M.build_config_key(parts)
    return table.concat(parts, '_')
end

function M.get_all_item_keys()
    local keys = {}
    local schema = M.CONFIG_SCHEMA.items
    
    for _, side in ipairs(schema.sides) do
        for _, status in ipairs(schema.statuses) do
            table.insert(keys, string.format(schema.key_pattern, side, status))
            for _, bar_type in ipairs(schema.bar_types) do
                if bar_type ~= 'statusline' then
                    table.insert(keys, string.format(schema.key_pattern .. '_%s', side, status, bar_type))
                end
            end
        end
    end
    
    return keys
end

function M.get_all_separator_keys()
    local keys = {}
    local schema = M.CONFIG_SCHEMA.separators
    
    for _, side in ipairs(schema.sides) do
        table.insert(keys, string.format(schema.key_pattern, side))
        for _, bar_type in ipairs(schema.bar_types) do
            if bar_type ~= 'statusline' then
                table.insert(keys, string.format(schema.key_pattern .. '_%s', side, bar_type))
            end
        end
    end
    
    return keys
end

function M.validate_by_schema(config, schema_section)
    local errors = {}
    local schema = M.CONFIG_SCHEMA[schema_section]
    
    if not schema then
        return errors
    end
    
    if schema.keys then
        for _, key in ipairs(schema.keys) do
            local value = config[key]
            if value ~= nil then
                local expected_type = schema.type
                local actual_type = type(value)
                
                if actual_type ~= expected_type then
                    table.insert(errors, string.format(
                        '%s expected %s, got %s',
                        key, expected_type, actual_type
                    ))
                elseif schema.min and value < schema.min then
                    table.insert(errors, string.format(
                        '%s must be >= %s',
                        key, schema.min
                    ))
                end
            end
        end
    end
    
    return errors
end

function M.validate_all_config(config)
    local errors = {}
    
    -- Validate each schema section
    for section_name, _ in pairs(M.CONFIG_SCHEMA) do
        if section_name ~= 'items' and section_name ~= 'separators' then
            local section_errors = M.validate_by_schema(config, section_name)
            vim.list_extend(errors, section_errors)
        end
    end
    
    -- Validate item configuration keys
    local item_keys = M.get_all_item_keys()
    for _, key in ipairs(item_keys) do
        if config[key] and type(config[key]) ~= 'table' then
            table.insert(errors, key .. ' must be a table/array')
        end
    end
    
    -- Validate separator keys
    local separator_keys = M.get_all_separator_keys()
    for _, key in ipairs(separator_keys) do
        if config[key] and type(config[key]) ~= 'string' then
            table.insert(errors, key .. ' must be a string')
        end
    end
    
    return errors
end

return M