local M = {}

function M.parse(hex)
    if type(hex) ~= 'string' then
        return nil
    end
    local r, g, b = hex:match('^#(%x%x)(%x%x)(%x%x)$')
    if not r then
        return nil
    end
    return { r = tonumber(r, 16), g = tonumber(g, 16), b = tonumber(b, 16) }
end

function M.format(rgb)
    return string.format('#%02x%02x%02x', rgb.r, rgb.g, rgb.b)
end

function M.is_hex(value)
    return type(value) == 'string' and value:match('^#%x%x%x%x%x%x$') ~= nil
end

local function clamp(component)
    return math.max(0, math.min(255, component))
end

function M.adjust(hex, amount)
    local rgb = M.parse(hex)
    if not rgb then
        return hex
    end
    return M.format({
        r = clamp(rgb.r + amount),
        g = clamp(rgb.g + amount),
        b = clamp(rgb.b + amount),
    })
end

function M.interpolate(from, to, steps)
    local rgb_from = M.parse(from)
    local rgb_to = M.parse(to)
    local colors = {}
    for i = 0, steps - 1 do
        local t = steps == 1 and 0 or i / (steps - 1)
        table.insert(colors, M.format({
            r = math.floor(rgb_from.r + (rgb_to.r - rgb_from.r) * t + 0.5),
            g = math.floor(rgb_from.g + (rgb_to.g - rgb_from.g) * t + 0.5),
            b = math.floor(rgb_from.b + (rgb_to.b - rgb_from.b) * t + 0.5),
        }))
    end
    return colors
end

function M.from_highlight(group)
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
    if not ok or not hl then
        return { bg = nil, fg = nil }
    end
    return {
        bg = hl.bg and string.format('#%06x', hl.bg) or nil,
        fg = hl.fg and string.format('#%06x', hl.fg) or nil,
    }
end

return M
