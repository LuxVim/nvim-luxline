local M = {}

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

local function base_keys_for(section)
    local keys = {}
    if section.statuses then
        for _, side in ipairs(section.sides) do
            for _, status in ipairs(section.statuses) do
                table.insert(keys, string.format(section.key_pattern, side, status))
            end
        end
    else
        for _, side in ipairs(section.sides) do
            table.insert(keys, string.format(section.key_pattern, side))
        end
    end
    return keys
end

function M.enumerate_keys(section_name)
    local section = M.CONFIG_SCHEMA[section_name]
    if not section or not section.sides then
        return {}
    end

    local keys = {}
    for _, base in ipairs(base_keys_for(section)) do
        table.insert(keys, base)
        for _, bar_type in ipairs(section.bar_types or {}) do
            if bar_type ~= 'statusline' then
                table.insert(keys, base .. '_' .. bar_type)
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

    for section_name, _ in pairs(M.CONFIG_SCHEMA) do
        if section_name ~= 'items' and section_name ~= 'separators' then
            local section_errors = M.validate_by_schema(config, section_name)
            vim.list_extend(errors, section_errors)
        end
    end

    for _, key in ipairs(M.enumerate_keys('items')) do
        if config[key] and type(config[key]) ~= 'table' then
            table.insert(errors, key .. ' must be a table/array')
        end
    end

    for _, key in ipairs(M.enumerate_keys('separators')) do
        if config[key] and type(config[key]) ~= 'string' then
            table.insert(errors, key .. ' must be a string')
        end
    end

    return errors
end

return M