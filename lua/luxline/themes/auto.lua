local M = {}

local theme_cache = {}

local function get_hl_colors(group)
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
    if not ok or not hl then
        return { bg = nil, fg = nil }
    end
    return {
        bg = hl.bg and string.format('#%06x', hl.bg) or nil,
        fg = hl.fg and string.format('#%06x', hl.fg) or nil,
    }
end

local function get_color_with_fallbacks(primary, fallbacks, attr, default)
    local colors = get_hl_colors(primary)
    if colors[attr] then
        return colors
    end

    for _, fallback in ipairs(fallbacks or {}) do
        colors = get_hl_colors(fallback)
        if colors[attr] then
            return colors
        end
    end

    return { bg = default, fg = default }
end

local GRADIENT_MAPPING = {
    { primary = 'Normal', fallbacks = { 'StatusLine' }, attr = 'bg', default = '#1a1a1a' },
    { primary = 'CursorLine', fallbacks = { 'StatusLineNC' }, attr = 'bg', default = nil },
    { primary = 'Visual', fallbacks = { 'Pmenu' }, attr = 'bg', default = nil },
    { primary = 'StatusLine', fallbacks = { 'Normal' }, attr = 'bg', default = nil },
    { primary = 'Search', fallbacks = { 'WildMenu' }, attr = 'bg', default = nil },
    { primary = 'IncSearch', fallbacks = { 'Substitute' }, attr = 'bg', default = nil },
    { primary = 'Cursor', fallbacks = { 'Title', 'MatchParen' }, attr = 'bg', default = nil },
}

local function build_gradient()
    local gradient = {}
    local normal_fg = get_hl_colors('Normal').fg or '#d0d0d0'

    for i, mapping in ipairs(GRADIENT_MAPPING) do
        local colors = get_color_with_fallbacks(mapping.primary, mapping.fallbacks, mapping.attr, mapping.default)
        local bg = colors.bg
        local fg = colors.fg or normal_fg

        if not bg and i > 1 then
            bg = gradient[i - 1].bg
        end

        if not bg then
            bg = mapping.default or '#1a1a1a'
        end

        gradient[i] = { bg = bg, fg = fg }
    end

    return gradient
end

M._build_gradient = build_gradient

return M
