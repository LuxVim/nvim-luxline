local M = {}

local events = require('luxline.core.events')
local strategies = require('luxline.rendering.highlight_strategies')

local active_groups = {}
local separator_cache = {}

local function format_highlight(name, content)
    if not name or not content or content == '' then
        return ''
    end
    return string.format('%%#%s# %s ', name, content)
end

function M.item(value, side, idx, bar_type, item_name)
    bar_type = bar_type or 'statusline'

    local strategy_name, group_name = strategies.get_highlight_strategy(item_name, side, idx, bar_type)

    if not strategy_name or not group_name then
        return value
    end

    M.ensure_highlight_exists(strategy_name, group_name, side, idx, bar_type)

    return format_highlight(group_name, value)
end

function M.ensure_highlight_exists(strategy_name, group_name, side, idx, bar_type)
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

function M.extract_highlight_group(formatted_text)
    return formatted_text:match('%%#([^#]+)#')
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

function M.get_active_groups()
    return vim.tbl_keys(active_groups)
end

return M