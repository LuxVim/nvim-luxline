local M = {}

local utils = require('luxline.core.utils')
local events = require('luxline.core.events')
local strategies = require('luxline.rendering.highlight_strategies')

local active_groups = {}
local separator_cache = {}
local item_highlight_mappings = {}

function M.item(value, side, idx, bar_type, item_name)
    bar_type = bar_type or 'statusline'
    
    -- Get the appropriate highlight strategy and group name
    local strategy_name, group_name = strategies.get_highlight_strategy(item_name, side, idx, bar_type)
    
    if not strategy_name or not group_name then
        return value -- Return plain value if no highlight available
    end
    
    -- Ensure the highlight group exists
    M.ensure_highlight_exists(strategy_name, group_name, side, idx, bar_type, item_name)
    
    -- Store the group for separator logic
    M.store_item_highlight_mapping(side, idx, bar_type, group_name)
    
    return utils.format_highlight(group_name, value)
end


function M.ensure_highlight_exists(strategy_name, group_name, side, idx, bar_type, item_name)
    if active_groups[group_name] then
        return group_name
    end
    
    local hl_def
    if strategy_name == 'semantic' then
        hl_def = strategies.create_highlight_group('semantic', group_name, bar_type)
    elseif strategy_name == 'positional' then
        hl_def = strategies.create_highlight_group('positional', group_name, side, idx, bar_type)
    end
    
    if not hl_def then
        vim.notify('No theme available for highlight group: ' .. group_name, vim.log.levels.WARN)
        return group_name
    end
    
    vim.api.nvim_set_hl(0, group_name, hl_def)
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
    local strategy_name, group_name = strategies.get_highlight_strategy(item_name, side, rendered_idx, bar_type)
    
    if strategy_name and group_name then
        M.ensure_highlight_exists(strategy_name, group_name, side, rendered_idx, bar_type, item_name)
        return group_name
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
    local cache_key = string.format('%s_%s_%s_%s', bar_type, side, 
                                    current_hl_group or 'default', 
                                    next_hl_group or 'default')
    
    if separator_cache[cache_key] then
        return separator_cache[cache_key]
    end
    
    local sep_info = strategies.create_separator_highlight(separator, side, current_hl_group, next_hl_group, bar_type)
    active_groups[sep_info.group_name] = true
    
    separator_cache[cache_key] = sep_info.formatted
    return sep_info.formatted
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

-- Delegate to strategies module
M.adjust_color = strategies.adjust_color

return M