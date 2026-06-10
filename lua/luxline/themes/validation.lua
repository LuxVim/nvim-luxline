local M = {}

local color = require('luxline.primitives.color')
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

function M.validate_color(value)
    return color.is_hex(value)
end

return M
