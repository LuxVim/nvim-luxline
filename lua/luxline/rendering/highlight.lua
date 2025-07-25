local M = {}

local utils = require('luxline.core.utils')
local events = require('luxline.core.events')

local active_groups = {}
local separator_cache = {}
local item_highlight_mappings = {}

function M.item(value, side, idx, bar_type, item_name)
    bar_type = bar_type or 'statusline'
    local prefix = bar_type == 'winbar' and 'LuxlineWinbar' or 'Luxline'
    
    -- Use semantic highlight group if item_name is provided and theme defines it
    local semantic_hl_name = item_name and M.get_semantic_highlight_name(item_name, bar_type)
    if semantic_hl_name and M.theme_defines_semantic_group(semantic_hl_name) then
        M.ensure_semantic_highlight_exists(semantic_hl_name, bar_type)
        -- Store the semantic group for separator logic
        M.store_item_highlight_mapping(side, idx, bar_type, semantic_hl_name)
        return utils.format_highlight(semantic_hl_name, value)
    end
    
    -- Fallback to positional highlighting
    local hl_name = prefix .. 'Item' .. side:gsub('^%l', string.upper) .. idx
    M.ensure_highlight_exists(hl_name, side, idx, bar_type)
    M.store_item_highlight_mapping(side, idx, bar_type, hl_name)
    return utils.format_highlight(hl_name, value)
end

function M.separator(separator, side, current_idx, next_idx, bar_type)
    if not separator or separator == '' then
        return ''
    end
    
    bar_type = bar_type or 'statusline'
    local cache_key = string.format('%s_%s_%d_%d', bar_type, side, current_idx, next_idx)
    if separator_cache[cache_key] then
        return separator_cache[cache_key]
    end
    
    local default_bg = '1A1B26'
    local winid = vim.api.nvim_get_current_win()
    local prefix = bar_type == 'winbar' and 'LuxlineWinbarSep' or 'LuxlineSeparator'
    local hl_name = prefix .. winid .. '_' .. cache_key
    
    -- Get actual highlight groups used by items (could be semantic or positional)
    local current_hl = M.get_item_highlight_group(side, current_idx, bar_type)
    local next_hl = M.get_item_highlight_group(side, next_idx, bar_type)
    
    -- For right side, the logic is reversed since items are in reverse order
    local fg_bg, bg_bg
    if side == 'right' then
        -- Right side: separator fg = next item bg, separator bg = current item bg
        if next_idx > 0 and next_hl then
            fg_bg = M.get_highlight_value(next_hl, 'bg')
        else
            fg_bg = default_bg
        end
        
        if current_idx > 0 and current_hl then
            bg_bg = M.get_highlight_value(current_hl, 'bg')
        else
            bg_bg = default_bg
        end
    else
        -- Left side: separator fg = current item bg, separator bg = next item bg
        if current_idx > 0 and current_hl then
            fg_bg = M.get_highlight_value(current_hl, 'bg')
        else
            fg_bg = default_bg
        end
        
        if next_idx > 0 and next_hl then
            bg_bg = M.get_highlight_value(next_hl, 'bg')
        else
            bg_bg = default_bg
        end
    end
    
    M.create_highlight(hl_name, fg_bg, bg_bg)
    
    local result = '%#' .. hl_name .. '#' .. separator
    separator_cache[cache_key] = result
    
    return result
end

function M.ensure_highlight_exists(group_name, side, idx, bar_type)
    if active_groups[group_name] then
        return group_name
    end
    
    local themes = require('luxline.themes')
    local theme = themes.get_current_theme()
    
    if not theme then
        vim.notify('No theme available for highlight group: ' .. group_name, vim.log.levels.WARN)
        return group_name
    end
    
    local bg_key = 'item' .. side:gsub('^%l', string.upper) .. idx
    local bg = theme[bg_key] or theme.fallback or '#808080'
    local fg = theme.foreground or '#d0d0d0'
    
    -- For winbar, use a slightly darker/lighter bg for distinction
    if bar_type == 'winbar' then
        bg = M.adjust_color(bg, -10) -- Slightly darker for winbar
    end
    
    vim.api.nvim_set_hl(0, group_name, {
        fg = fg,
        bg = bg,
    })
    
    active_groups[group_name] = true
    return group_name
end

function M.get_highlight_value(hl_name, attr)
    if not active_groups[hl_name] then
        return '000000'
    end
    
    local hl = vim.api.nvim_get_hl(0, { name = hl_name })
    if attr == 'bg' then
        return hl.bg and string.format('%06x', hl.bg) or '000000'
    elseif attr == 'fg' then
        return hl.fg and string.format('%06x', hl.fg) or 'ffffff'
    end
    return '000000'
end

function M.create_highlight(name, fg, bg)
    vim.api.nvim_set_hl(0, name, {
        fg = '#' .. fg,
        bg = '#' .. bg,
    })
    active_groups[name] = true
end

function M.get_semantic_highlight_name(item_name, bar_type)
    local prefix = bar_type == 'winbar' and 'LuxlineWinbar' or 'Luxline'
    return prefix .. item_name:gsub('^%l', string.upper):gsub('_(%l)', string.upper)
end

function M.theme_defines_semantic_group(group_name)
    local themes = require('luxline.themes')
    local theme = themes.get_current_theme()
    
    if not theme then
        return false
    end
    
    -- Check if theme has semantic groups defined
    return theme.semantic and theme.semantic[group_name] ~= nil
end

function M.ensure_semantic_highlight_exists(group_name, bar_type)
    if active_groups[group_name] then
        return group_name
    end
    
    local themes = require('luxline.themes')
    local theme = themes.get_current_theme()
    
    if not theme or not theme.semantic or not theme.semantic[group_name] then
        return group_name
    end
    
    local semantic_def = theme.semantic[group_name]
    local fg = semantic_def.fg or theme.foreground or '#d0d0d0'
    local bg = semantic_def.bg or theme.fallback or '#808080'
    
    -- For winbar, use a slightly darker/lighter bg for distinction
    if bar_type == 'winbar' then
        bg = M.adjust_color(bg, -10)
    end
    
    vim.api.nvim_set_hl(0, group_name, {
        fg = fg,
        bg = bg,
        bold = semantic_def.bold,
        italic = semantic_def.italic,
        underline = semantic_def.underline,
    })
    
    active_groups[group_name] = true
    return group_name
end

function M.store_item_highlight_mapping(side, idx, bar_type, highlight_group)
    local winid = vim.api.nvim_get_current_win()
    local key = string.format('%d_%s_%s_%d', winid, bar_type, side, idx)
    item_highlight_mappings[key] = highlight_group
end

function M.get_item_highlight_group(side, idx, bar_type)
    if idx <= 0 then
        return nil
    end
    
    local winid = vim.api.nvim_get_current_win()
    local key = string.format('%d_%s_%s_%d', winid, bar_type, side, idx)
    return item_highlight_mappings[key]
end

function M.get_item_highlight_group_name(item_name, bar_type, rendered_idx, side)
    if not item_name then
        return nil
    end
    
    -- Try semantic name first
    local semantic_hl_name = M.get_semantic_highlight_name(item_name, bar_type)
    if semantic_hl_name and M.theme_defines_semantic_group(semantic_hl_name) then
        M.ensure_semantic_highlight_exists(semantic_hl_name, bar_type)
        return semantic_hl_name
    end
    
    -- Fallback to positional highlighting if semantic is not available
    if rendered_idx and side then
        local prefix = bar_type == 'winbar' and 'LuxlineWinbar' or 'Luxline'
        local hl_name = prefix .. 'Item' .. side:gsub('^%l', string.upper) .. rendered_idx
        M.ensure_highlight_exists(hl_name, side, rendered_idx, bar_type)
        return hl_name
    end
    
    return nil
end

function M.extract_highlight_group(formatted_text)
    -- Extract highlight group name from formatted text like '%#GroupName#text'
    local group_name = formatted_text:match('%%#([^#]+)#')
    return group_name
end

function M.separator_direct(separator, side, current_hl_group, next_hl_group, bar_type)
    if not separator or separator == '' then
        return ''
    end
    
    bar_type = bar_type or 'statusline'
    local current_name = current_hl_group or 'default'
    local next_name = next_hl_group or 'default'
    local cache_key = string.format('%s_%s_%s_%s', bar_type, side, current_name, next_name)
    
    if separator_cache[cache_key] then
        return separator_cache[cache_key]
    end
    
    local default_bg = '1A1B26'
    local winid = vim.api.nvim_get_current_win()
    local prefix = bar_type == 'winbar' and 'LuxlineWinbarSep' or 'LuxlineSeparator'
    local hl_name = prefix .. winid .. '_' .. cache_key
    
    -- Get background colors from the actual highlight groups
    local fg_bg, bg_bg
    if side == 'right' then
        -- Right side: separator fg = next item bg, separator bg = current item bg
        fg_bg = next_hl_group and M.get_highlight_value(next_hl_group, 'bg') or default_bg
        bg_bg = current_hl_group and M.get_highlight_value(current_hl_group, 'bg') or default_bg
    else
        -- Left side: separator fg = current item bg, separator bg = next item bg
        fg_bg = current_hl_group and M.get_highlight_value(current_hl_group, 'bg') or default_bg
        bg_bg = next_hl_group and M.get_highlight_value(next_hl_group, 'bg') or default_bg
    end
    
    M.create_highlight(hl_name, fg_bg, bg_bg)
    
    local result = '%#' .. hl_name .. '#' .. separator
    separator_cache[cache_key] = result
    
    return result
end

function M.clear_cache()
    separator_cache = {}
    item_highlight_mappings = {}
    events.emit('highlight_cache_cleared')
end

function M.clear_highlights()
    for group_name in pairs(active_groups) do
        pcall(vim.api.nvim_set_hl, 0, group_name, {})
    end
    active_groups = {}
    M.clear_cache()
    events.emit('highlights_cleared')
end

function M.refresh_all()
    local old_groups = vim.tbl_keys(active_groups)
    M.clear_highlights()
    
    events.emit('highlights_refreshed', { 
        cleared_count = #old_groups 
    })
end

function M.get_active_groups()
    return vim.tbl_keys(active_groups)
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

return M