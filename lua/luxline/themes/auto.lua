local M = {}

local color = require('luxline.primitives.color')

local theme_cache = {}

local function get_hl_colors(group)
    return color.from_highlight(group)
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

local SEMANTIC_MAPPING = {
    LuxlineFilename = { primary = 'Title', fallback_pos = 5 },
    LuxlineWinbarFilename = { primary = 'Title', fallback_pos = 4 },
    LuxlineModified = { primary = 'DiagnosticWarn', fallbacks = { 'WarningMsg' }, bold = true },
    LuxlineWinbarModified = { primary = 'DiagnosticWarn', fallbacks = { 'WarningMsg' }, bold = true },
    LuxlineGit = { primary = 'GitSignsAdd', fallbacks = { 'DiffAdd', 'String' } },
    LuxlineWinbarGit = { primary = 'GitSignsAdd', fallbacks = { 'DiffAdd', 'String' } },
    LuxlinePosition = { primary = 'StatusLine', fallback_pos = 5 },
    LuxlineWinbarPosition = { primary = 'WinBar', fallback_pos = 4 },
    LuxlinePercent = { primary = 'Search', fallback_pos = 6 },
    LuxlineWinbarPercent = { primary = 'IncSearch', fallback_pos = 5 },
    LuxlineWindownumber = { primary = 'Title', fallback_pos = 3, bold = true },
    LuxlineWinbarWindownumber = { primary = 'WinBar', fallback_pos = 2, bold = true },
    LuxlineSpacer = { primary = 'StatusLine', fallback_pos = 2 },
    LuxlineWinbarSpacer = { primary = 'WinBar', fallback_pos = 2 },
}

local function build_semantic(gradient)
    local semantic = {}

    for group_name, mapping in pairs(SEMANTIC_MAPPING) do
        local colors = get_color_with_fallbacks(mapping.primary, mapping.fallbacks, 'bg', nil)
        local bg = colors.bg
        local fg = colors.fg

        if not bg and mapping.fallback_pos and gradient[mapping.fallback_pos] then
            bg = gradient[mapping.fallback_pos].bg
            fg = fg or gradient[mapping.fallback_pos].fg
        end

        if bg then
            semantic[group_name] = {
                bg = bg,
                fg = fg or gradient[1].fg or '#d0d0d0',
                bold = mapping.bold,
            }
        end
    end

    return semantic
end

function M.generate(colorscheme_name)
    colorscheme_name = colorscheme_name or vim.g.colors_name or 'default'

    if theme_cache[colorscheme_name] then
        return theme_cache[colorscheme_name]
    end

    local gradient = build_gradient()
    local semantic = build_semantic(gradient)

    local theme = {
        gradient = gradient,
        middle = gradient[2].bg,
        semantic = semantic,
    }

    theme_cache[colorscheme_name] = theme
    return theme
end

function M.invalidate(colorscheme_name)
    if colorscheme_name then
        theme_cache[colorscheme_name] = nil
    end
end

M._build_gradient = build_gradient
M._build_semantic = build_semantic

return M
