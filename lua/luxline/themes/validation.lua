local M = {}

local tbl = require('luxline.primitives.table')

M.DEFAULT_THEME = {
    gradient = {},
    middle = '#1a1a2e',
}

function M.get_default_theme()
    local default = vim.deepcopy(M.DEFAULT_THEME)
    local normal_fg = '#d0d0d0'

    for i = 1, 7 do
        local gray_value = math.floor(0x40 + (i - 1) * 0x10)
        local bg = string.format('#%02x%02x%02x', gray_value, gray_value, gray_value)
        default.gradient[i] = { bg = bg, fg = normal_fg }
    end

    default.middle = default.gradient[2].bg
    return default
end

function M.validate_theme(theme, name)
    if type(theme) ~= 'table' then
        vim.notify('Theme must be a table: ' .. (name or 'unknown'), vim.log.levels.WARN)
        return M.get_default_theme()
    end

    local validated = tbl.deep_merge(M.get_default_theme(), theme)

    if not validated.gradient or #validated.gradient ~= 7 then
        if name then
            vim.notify('Theme gradient must have exactly 7 colors: ' .. name, vim.log.levels.WARN)
        end
        validated = M.get_default_theme()
    end

    for i, entry in ipairs(validated.gradient) do
        if type(entry) ~= 'table' or not entry.bg then
            vim.notify('Invalid gradient entry at position ' .. i, vim.log.levels.WARN)
            validated.gradient[i] = { bg = '#808080', fg = '#d0d0d0' }
        end
    end

    return validated
end

function M.validate_color(color)
    if type(color) ~= 'string' then
        return false
    end

    return color:match('^#%x%x%x%x%x%x$') ~= nil
end

function M.validate_gradient(gradient)
    if type(gradient) ~= 'table' then
        return false, 'Gradient must be a table'
    end

    if #gradient ~= 7 then
        return false, 'Gradient must have exactly 7 entries'
    end

    for i, entry in ipairs(gradient) do
        if type(entry) ~= 'table' then
            return false, 'Gradient entry ' .. i .. ' must be a table'
        end
        if not M.validate_color(entry.bg) then
            return false, 'Invalid bg color at position ' .. i
        end
        if entry.fg and not M.validate_color(entry.fg) then
            return false, 'Invalid fg color at position ' .. i
        end
    end

    return true
end

function M.validate_semantic_groups(semantic)
    if type(semantic) ~= 'table' then
        return false, 'Semantic groups must be a table'
    end

    for group_name, group_def in pairs(semantic) do
        if type(group_def) ~= 'table' then
            return false, 'Semantic group definition must be a table: ' .. group_name
        end

        if group_def.fg and not M.validate_color(group_def.fg) then
            return false, 'Invalid foreground color in group: ' .. group_name
        end

        if group_def.bg and not M.validate_color(group_def.bg) then
            return false, 'Invalid background color in group: ' .. group_name
        end
    end

    return true
end

return M
