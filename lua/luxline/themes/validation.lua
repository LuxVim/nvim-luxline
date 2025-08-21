local M = {}

local utils = require('luxline.core.utils')

-- Default theme structure
M.DEFAULT_THEME = {
    foreground = '#d0d0d0',
    fallback = '#808080',
    gradient = {}
}

function M.get_default_theme()
    local default = vim.deepcopy(M.DEFAULT_THEME)
    
    -- Generate default gradient if not provided
    for i = 1, 7 do
        local gray_value = math.floor(0x40 + (i - 1) * 0x10)
        default.gradient[i] = string.format('#%02x%02x%02x', gray_value, gray_value, gray_value)
    end
    
    return default
end

function M.validate_theme(theme, name)
    if type(theme) ~= 'table' then
        vim.notify('Theme must be a table: ' .. (name or 'unknown'), vim.log.levels.WARN)
        return M.get_default_theme()
    end
    
    -- Start with defaults and merge user theme
    local validated = utils.deep_merge(M.get_default_theme(), theme)
    
    -- Ensure gradient has exactly 7 colors
    if not validated.gradient or #validated.gradient ~= 7 then
        if name then
            vim.notify('Theme gradient must have exactly 7 colors: ' .. name, vim.log.levels.WARN)
        end
        
        -- Fill missing colors or create new gradient
        validated.gradient = validated.gradient or {}
        for i = #validated.gradient + 1, 7 do
            validated.gradient[i] = validated.fallback
        end
        
        -- Trim if too many colors
        if #validated.gradient > 7 then
            for i = 8, #validated.gradient do
                validated.gradient[i] = nil
            end
        end
    end
    
    -- Generate legacy itemLeft/Right from gradient for compatibility
    for i = 1, 7 do
        validated['itemLeft' .. i] = validated.gradient[i]
        validated['itemRight' .. i] = validated.gradient[i]
    end
    
    return validated
end

function M.validate_color(color)
    if type(color) ~= 'string' then
        return false
    end
    
    -- Check if it's a valid hex color
    return color:match('^#%x%x%x%x%x%x$') ~= nil
end

function M.validate_gradient(gradient)
    if type(gradient) ~= 'table' then
        return false, 'Gradient must be a table'
    end
    
    if #gradient ~= 7 then
        return false, 'Gradient must have exactly 7 colors'
    end
    
    for i, color in ipairs(gradient) do
        if not M.validate_color(color) then
            return false, 'Invalid color at position ' .. i .. ': ' .. tostring(color)
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