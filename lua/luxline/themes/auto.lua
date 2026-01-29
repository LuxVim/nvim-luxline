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

return M
