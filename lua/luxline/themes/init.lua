local M = {}

local utils = require('luxline.core.utils')
local events = require('luxline.core.events')
local state = require('luxline.core.state')

local themes = {}
local current_theme = nil

function M.register(name, theme_func_or_table)
    if type(theme_func_or_table) == 'function' then
        themes[name] = theme_func_or_table
    elseif type(theme_func_or_table) == 'table' then
        themes[name] = function() return theme_func_or_table end
    else
        error('Theme must be a function or table')
    end
    
    events.emit('theme_registered', { name = name })
end

function M.get_theme_names()
    return vim.tbl_keys(themes)
end

function M.get_theme(name)
    if not themes[name] then
        return nil
    end
    
    local theme = themes[name]()
    if not theme then
        vim.notify('Theme function returned nil: ' .. name, vim.log.levels.WARN)
        return nil
    end
    
    return M.validate_theme(theme, name)
end

function M.get_current_theme()
    return current_theme
end

function M.validate_theme(theme, name)
    local defaults = {
        foreground = '#d0d0d0',
        fallback = '#808080'
    }
    
    theme = utils.deep_merge(defaults, theme)
    
    local required_sides = { 'Left', 'Right' }
    for _, side in ipairs(required_sides) do
        for i = 1, 7 do
            local key = 'item' .. side .. i
            if not theme[key] then
                local gray_value = math.floor(0x40 + (i - 1) * 0x10)
                theme[key] = string.format('#%02x%02x%02x', gray_value, gray_value, gray_value)
            end
        end
    end
    
    return theme
end

function M.set_theme(theme_name)
    theme_name = theme_name or vim.g.colors_name or 'default'
    
    local theme = M.get_theme(theme_name)
    if not theme then
        if theme_name ~= 'default' then
            vim.notify('Theme not found: ' .. theme_name .. ', falling back to default', vim.log.levels.WARN)
            theme = M.get_theme('default')
        end
        
        if not theme then
            vim.notify('Default theme not available!', vim.log.levels.ERROR)
            return false
        end
    end
    
    current_theme = theme
    state.set('theme', theme_name)
    
    local highlight = require('luxline.rendering.highlight')
    highlight.clear_highlights()
    
    events.emit('theme_changed', { 
        name = theme_name, 
        theme = theme 
    })
    
    return true
end

function M.create_inherited_theme(base_name, overrides, new_name)
    local base_theme = M.get_theme(base_name)
    if not base_theme then
        error('Base theme not found: ' .. base_name)
    end
    
    local new_theme = utils.deep_merge(vim.deepcopy(base_theme), overrides)
    
    if new_name then
        M.register(new_name, new_theme)
        return new_name
    end
    
    return new_theme
end

function M.interpolate_colors(color1, color2, steps)
    local function hex_to_rgb(hex)
        hex = hex:gsub('#', '')
        return {
            r = tonumber(hex:sub(1, 2), 16),
            g = tonumber(hex:sub(3, 4), 16),
            b = tonumber(hex:sub(5, 6), 16)
        }
    end
    
    local function rgb_to_hex(rgb)
        return string.format('#%02x%02x%02x', 
            math.floor(rgb.r + 0.5),
            math.floor(rgb.g + 0.5),
            math.floor(rgb.b + 0.5)
        )
    end
    
    local rgb1 = hex_to_rgb(color1)
    local rgb2 = hex_to_rgb(color2)
    
    local colors = {}
    for i = 0, steps - 1 do
        local t = i / (steps - 1)
        local rgb = {
            r = rgb1.r + (rgb2.r - rgb1.r) * t,
            g = rgb1.g + (rgb2.g - rgb1.g) * t,
            b = rgb1.b + (rgb2.b - rgb1.b) * t
        }
        table.insert(colors, rgb_to_hex(rgb))
    end
    
    return colors
end

function M.create_gradient_theme(name, start_color, end_color, foreground)
    local colors = M.interpolate_colors(start_color, end_color, 7)
    
    local theme = {
        foreground = foreground or '#ffffff',
        fallback = colors[4]
    }
    
    for i = 1, 7 do
        theme['itemLeft' .. i] = colors[i]
        theme['itemRight' .. i] = colors[i]
    end
    
    M.register(name, theme)
    return name
end

function M.preview_theme(theme_name)
    local old_theme = current_theme
    local old_theme_name = state.get('theme')
    
    if M.set_theme(theme_name) then
        vim.schedule(function()
            local statusline = require('luxline.rendering.statusline')
            statusline.update_all()
            
            vim.defer_fn(function()
                M.set_theme(old_theme_name)
                statusline.update_all()
            end, 3000)
        end)
    end
end

function M.export_theme(theme_name, format)
    format = format or 'lua'
    local theme = M.get_theme(theme_name)
    if not theme then
        return nil
    end
    
    if format == 'lua' then
        local lines = { 'return {' }
        for key, value in pairs(theme) do
            table.insert(lines, string.format('    %s = %q,', key, value))
        end
        table.insert(lines, '}')
        return table.concat(lines, '\n')
    elseif format == 'json' then
        return vim.json.encode(theme)
    end
    
    return nil
end

function M.setup()
    require('luxline.themes.base')
    require('luxline.themes.default')
    require('luxline.themes.lux-vesper')
    require('luxline.themes.lux-aurora')
    require('luxline.themes.lux-chroma')
    require('luxline.themes.lux-eos')
    require('luxline.themes.lux-umbra')
    
    events.on('colorscheme_changed', function()
        local current_theme_name = state.get('theme')
        if current_theme_name then
            M.set_theme(current_theme_name)
        end
    end)
end

return M