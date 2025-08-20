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
    
    -- Ensure gradient exists and has 7 colors
    if not theme.gradient then
        -- Legacy fallback: generate gradient from existing structure or defaults
        theme.gradient = {}
        for i = 1, 7 do
            local left_key = 'itemLeft' .. i
            if theme[left_key] then
                theme.gradient[i] = theme[left_key]
            else
                local gray_value = math.floor(0x40 + (i - 1) * 0x10)
                theme.gradient[i] = string.format('#%02x%02x%02x', gray_value, gray_value, gray_value)
            end
        end
    elseif #theme.gradient ~= 7 then
        vim.notify('Theme gradient must have exactly 7 colors: ' .. (name or 'unknown'), vim.log.levels.WARN)
        -- Fill missing colors with fallback
        for i = #theme.gradient + 1, 7 do
            theme.gradient[i] = theme.fallback
        end
    end
    
    -- Generate itemLeft/Right from gradient for compatibility
    for i = 1, 7 do
        theme['itemLeft' .. i] = theme.gradient[i]
        theme['itemRight' .. i] = theme.gradient[i]
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
        fallback = colors[4],
        gradient = colors
    }
    
    M.register(name, theme)
    return name
end

function M.preview_theme(theme_name)
    local old_theme = current_theme
    local old_theme_name = state.get('theme')
    
    if M.set_theme(theme_name) then
        vim.schedule(function()
            local bar_builder = require('luxline.rendering.bar_builder')
            bar_builder.statusline.update_all()
            
            vim.defer_fn(function()
                M.set_theme(old_theme_name)
                bar_builder.statusline.update_all()
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

function M.create_theme(name, theme_config)
    M.register(name, theme_config)
end

function M.setup()
    require('luxline.themes.base')
    require('luxline.themes.default')
    
    -- Register lux themes using consolidated data
    local lux_themes = {
        ['lux-vesper'] = {
            foreground = '#e0e7ff',
            fallback = '#4a3674',
            gradient = {
                '#0f0f23', '#1a1a2e', '#2A305E', '#4a3674',
                '#7c3aed', '#8b5cf6', '#a855f7'
            },
            middle = '#1a1a2e',
            semantic = {
                LuxlineFilename = { fg = '#e0e7ff', bg = '#7c3aed' },
                LuxlineWinbarFilename = { fg = '#e0e7ff', bg = '#6d28d9' },
                LuxlineModified = { fg = '#fbbf24', bg = '#dc2626', bold = true },
                LuxlineWinbarModified = { fg = '#fbbf24', bg = '#b91c1c', bold = true },
                LuxlineGit = { fg = '#22c55e', bg = '#4a3674' },
                LuxlineWinbarGit = { fg = '#22c55e', bg = '#3c2e60' },
                LuxlinePosition = { fg = '#e0e7ff', bg = '#8b5cf6' },
                LuxlineWinbarPosition = { fg = '#e0e7ff', bg = '#7c3aed' },
                LuxlinePercent = { fg = '#e0e7ff', bg = '#a855f7' },
                LuxlineWinbarPercent = { fg = '#e0e7ff', bg = '#9333ea' },
                LuxlineWindownumber = { fg = '#fbbf24', bg = '#4a3674', bold = true },
                LuxlineWinbarWindownumber = { fg = '#fbbf24', bg = '#3c2e60', bold = true },
                LuxlineSpacer = { fg = '#1a1a2e', bg = '#1a1a2e' },
                LuxlineWinbarSpacer = { fg = '#1a1a2e', bg = '#1a1a2e' }
            }
        },
        ['lux-aurora'] = {
            foreground = '#1a1a1a',
            fallback = '#00bfa5',
            gradient = {
                '#f2f8f9', '#ecf4f6', '#e0ecef', '#b3e5fc',
                '#00bfa5', '#00e5ff', '#7c4dff'
            },
            middle = '#ecf4f6'
        },
        ['lux-chroma'] = {
            foreground = '#1a1a1a',
            fallback = '#20b2aa',
            gradient = {
                '#fdfbf3', '#faf7ed', '#f4f0e1', '#fffdd0',
                '#20b2aa', '#ff8c42', '#ff69b4'
            },
            middle = '#faf7ed'
        },
        ['lux-eos'] = {
            foreground = '#1a1a1a',
            fallback = '#ff8e53',
            gradient = {
                '#fef4f1', '#fdefeb', '#fbe4df', '#ffab91',
                '#ff8e53', '#26d0ce', '#ff6b6b'
            },
            middle = '#fdefeb'
        },
        ['lux-umbra'] = {
            foreground = '#f4edff',
            fallback = '#5b3094',
            gradient = {
                '#0a0310', '#180c24', '#2c1a42', '#5b3094',
                '#6b60e3', '#c471ed', '#d776dd'
            },
            middle = '#180c24'
        }
    }
    
    for name, theme_data in pairs(lux_themes) do
        M.register(name, theme_data)
    end
    
    events.on('colorscheme_changed', function()
        -- Auto-detect lux themes when colorscheme changes
        if vim.g.colors_name and vim.g.colors_name:match("^lux%-") then
            M.set_theme(vim.g.colors_name)
        else
            local current_theme_name = state.get('theme')
            if current_theme_name then
                M.set_theme(current_theme_name)
            else
                -- Fallback: refresh theme based on new colorscheme
                M.set_theme()
            end
        end
    end)
end

return M