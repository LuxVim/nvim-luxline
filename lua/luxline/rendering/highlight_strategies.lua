local M = {}

local utils = require('luxline.core.utils')

-- Highlight strategy interface
local highlight_strategies = {}

-- Semantic highlight strategy
highlight_strategies.semantic = {
    get_group_name = function(item_name, bar_type)
        if not item_name then return nil end
        local prefix = bar_type == 'winbar' and 'LuxlineWinbar' or 'Luxline'
        return prefix .. item_name:gsub('^%l', string.upper):gsub('_(%l)', string.upper)
    end,
    
    is_available = function(group_name)
        local themes = require('luxline.themes')
        local theme = themes.get_current_theme()
        return theme and theme.semantic and theme.semantic[group_name] ~= nil
    end,
    
    create_highlight = function(group_name, bar_type)
        local themes = require('luxline.themes')
        local theme = themes.get_current_theme()
        
        if not theme or not theme.semantic or not theme.semantic[group_name] then
            return nil
        end
        
        local semantic_def = theme.semantic[group_name]
        local fg = semantic_def.fg or theme.foreground or '#d0d0d0'
        local bg = semantic_def.bg or theme.fallback or '#808080'
        
        -- For winbar, use a slightly darker/lighter bg for distinction
        if bar_type == 'winbar' then
            bg = M.adjust_color(bg, -10)
        end
        
        return {
            fg = fg,
            bg = bg,
            bold = semantic_def.bold,
            italic = semantic_def.italic,
            underline = semantic_def.underline,
        }
    end
}

-- Positional highlight strategy
highlight_strategies.positional = {
    get_group_name = function(side, idx, bar_type)
        if not side or not idx then return nil end
        local prefix = bar_type == 'winbar' and 'LuxlineWinbar' or 'Luxline'
        return prefix .. 'Item' .. side:gsub('^%l', string.upper) .. idx
    end,
    
    is_available = function() 
        return true -- Always available as fallback
    end,
    
    create_highlight = function(group_name, side, idx, bar_type)
        local themes = require('luxline.themes')
        local theme = themes.get_current_theme()
        
        if not theme then
            return nil
        end
        
        local bg_key = 'item' .. side:gsub('^%l', string.upper) .. idx
        local bg = theme[bg_key] or theme.fallback or '#808080'
        local fg = theme.foreground or '#d0d0d0'
        
        -- For winbar, use a slightly darker/lighter bg for distinction
        if bar_type == 'winbar' then
            bg = M.adjust_color(bg, -10)
        end
        
        return {
            fg = fg,
            bg = bg,
        }
    end
}

-- Strategy selector
function M.get_highlight_strategy(item_name, side, idx, bar_type)
    -- Try semantic first
    if item_name then
        local semantic_group = highlight_strategies.semantic.get_group_name(item_name, bar_type)
        if semantic_group and highlight_strategies.semantic.is_available(semantic_group) then
            return 'semantic', semantic_group
        end
    end
    
    -- Fallback to positional
    if side and idx then
        local positional_group = highlight_strategies.positional.get_group_name(side, idx, bar_type)
        return 'positional', positional_group
    end
    
    return nil, nil
end

function M.create_highlight_group(strategy_name, group_name, ...)
    local strategy = highlight_strategies[strategy_name]
    if not strategy then
        return nil
    end
    
    return strategy.create_highlight(group_name, ...)
end

function M.adjust_color(color, amount)
    if not color or not color:match('^#') then
        return color
    end
    
    local r = tonumber(color:sub(2, 3), 16)
    local g = tonumber(color:sub(4, 5), 16)
    local b = tonumber(color:sub(6, 7), 16)
    
    r = math.max(0, math.min(255, r + amount))
    g = math.max(0, math.min(255, g + amount))
    b = math.max(0, math.min(255, b + amount))
    
    return string.format('#%02x%02x%02x', r, g, b)
end

-- Unified separator creation
function M.create_separator_highlight(separator, side, current_hl_group, next_hl_group, bar_type)
    if not separator or separator == '' then
        return ''
    end
    
    local default_bg = '1A1B26'
    local winid = vim.api.nvim_get_current_win()
    local prefix = bar_type == 'winbar' and 'LuxlineWinbarSep' or 'LuxlineSeparator'
    local current_name = current_hl_group or 'default'
    local next_name = next_hl_group or 'default'
    local cache_key = string.format('%s_%s_%s_%s', bar_type, side, current_name, next_name)
    local hl_name = prefix .. winid .. '_' .. cache_key
    
    -- Get background colors from the actual highlight groups
    local get_bg = function(hl_group)
        if not hl_group then return default_bg end
        local hl = vim.api.nvim_get_hl(0, { name = hl_group })
        return hl.bg and string.format('%06x', hl.bg) or default_bg
    end
    
    local fg_bg, bg_bg
    if side == 'right' then
        fg_bg = get_bg(next_hl_group)
        bg_bg = get_bg(current_hl_group)
    else
        fg_bg = get_bg(current_hl_group)
        bg_bg = get_bg(next_hl_group)
    end
    
    vim.api.nvim_set_hl(0, hl_name, {
        fg = '#' .. fg_bg,
        bg = '#' .. bg_bg,
    })
    
    return {
        group_name = hl_name,
        formatted = '%#' .. hl_name .. '#' .. separator,
        cache_key = cache_key
    }
end

return M