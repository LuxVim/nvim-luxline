local M = {}

local color = require('luxline.primitives.color')
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
    local validation = require('luxline.themes.validation')
    return validation.validate_theme(theme, name)
end

function M.set_theme(theme_name)
    theme_name = theme_name or vim.g.colors_name or 'default'

    local theme = M.get_theme(theme_name)

    if not theme then
        local auto = require('luxline.themes.auto')
        theme = auto.generate(vim.g.colors_name)

        if theme then
            theme = M.validate_theme(theme, 'auto:' .. (vim.g.colors_name or 'unknown'))
        end
    end

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

function M.create_gradient_theme(name, start_color, end_color, foreground)
    local colors = color.interpolate(start_color, end_color, 7)
    foreground = foreground or '#ffffff'

    local gradient = {}
    for i, bg in ipairs(colors) do
        gradient[i] = { bg = bg, fg = foreground }
    end

    M.register(name, {
        gradient = gradient,
        middle = colors[2],
    })
    return name
end

function M.preview_theme(theme_name)
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

function M.setup()
    require('luxline.themes.default')

    local lux_themes = require('luxline.themes.data.lux-themes')

    for name, theme_data in pairs(lux_themes) do
        M.register(name, theme_data)
    end

    events.on('colorscheme_changed', function()
        local auto = require('luxline.themes.auto')
        auto.invalidate(vim.g.colors_name)
        M.set_theme(vim.g.colors_name)
    end)
end

return M