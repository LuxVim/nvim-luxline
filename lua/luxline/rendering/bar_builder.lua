local M = {}

local config = require('luxline.config')
local items = require('luxline.items')
local highlight = require('luxline.rendering.highlight')
local utils = require('luxline.core.utils')
local events = require('luxline.core.events')

function M.build_for_context(context, bar_type)
    bar_type = bar_type or 'statusline'
    local status_type = context.active and 'active' or 'inactive'
    local left_section = M.build_section('left', status_type, context, bar_type)
    local right_section = M.build_section('right', status_type, context, bar_type)
    
    return table.concat(left_section, '') .. '%=' .. table.concat(right_section, '')
end

function M.build_section(side, status_type, context, bar_type)
    bar_type = bar_type or 'statusline'
    local item_list = config.get_items(side, status_type, context.filetype, bar_type, context.buftype)
    local separator = config.get_separator(side, bar_type)
    local section = {}
    
    if side == 'right' then
        item_list = utils.reverse_table(item_list)
    end
    
    for idx, item_spec in ipairs(item_list) do
        local item_name, variant = utils.split_item_variant(item_spec)
        local item_value = items.get_value(item_name, variant, context)
        
        if item_value and item_value ~= '' then
            local next_idx = M.find_next_valid_item(item_list, idx, context)
            
            local hl_item = highlight.item(item_value, side, idx, bar_type)
            local hl_sep = ''
            
            if side == 'left' then
                -- Left side: separator after item
                hl_sep = next_idx > 0 and highlight.separator(separator, side, idx, next_idx, bar_type) or 
                         highlight.separator(separator, side, idx, -1, bar_type) -- End separator
                table.insert(section, hl_item .. hl_sep)
            else
                -- Right side: separator before item (except for last item which is first in reversed order)
                if idx > 1 then
                    hl_sep = highlight.separator(separator, side, M.find_previous_valid_item(item_list, idx, context), idx, bar_type)
                else
                    -- First item in right side (last in original order) gets separator from default background
                    hl_sep = highlight.separator(separator, side, -1, idx, bar_type)
                end
                table.insert(section, hl_sep .. hl_item)
            end
        end
    end
    
    return section
end

function M.find_next_valid_item(item_list, current_idx, context)
    for i = current_idx + 1, #item_list do
        local item_name, variant = utils.split_item_variant(item_list[i])
        local item_value = items.get_value(item_name, variant, context)
        if item_value and item_value ~= '' then
            return i
        end
    end
    return -1
end

function M.find_previous_valid_item(item_list, current_idx, context)
    for i = current_idx - 1, 1, -1 do
        local item_name, variant = utils.split_item_variant(item_list[i])
        local item_value = items.get_value(item_name, variant, context)
        if item_value and item_value ~= '' then
            return i
        end
    end
    return -1
end

function M.update_all_windows(bar_type)
    bar_type = bar_type or 'statusline'
    local windows = utils.gather_window_info()
    local option_name = bar_type == 'winbar' and 'winbar' or 'statusline'
    
    for win, info in pairs(windows) do
        local content = M.build_for_context(info, bar_type)
        local ok, err = pcall(vim.api.nvim_set_option_value, option_name, content, { win = win })
        if not ok then
            vim.notify('Failed to set ' .. bar_type .. ' for window ' .. win .. ': ' .. err, vim.log.levels.WARN)
        end
    end
    
    events.emit(bar_type .. '_updated', { window_count = vim.tbl_count(windows) })
end

function M.update_window(winid, bar_type)
    bar_type = bar_type or 'statusline'
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local option_name = bar_type == 'winbar' and 'winbar' or 'statusline'
    
    local context = utils.create_context(winid, bufnr)
    local content = M.build_for_context(context, bar_type)
    vim.api.nvim_set_option_value(option_name, content, { win = winid })
    
    events.emit(bar_type .. '_window_updated', { winid = winid })
end

function M.preview(config_override, bar_type)
    bar_type = bar_type or 'statusline'
    local old_config = config.get()
    if config_override then
        config.setup(utils.deep_merge(vim.deepcopy(old_config), config_override))
    end
    
    local context = utils.get_current_context()
    context.active = true
    
    local preview = M.build_for_context(context, bar_type)
    
    if config_override then
        config.setup(old_config)
    end
    
    return preview
end

-- Convenience methods for statusline
function M.build_statusline_for_context(context)
    return M.build_for_context(context, 'statusline')
end

function M.build_statusline_section(side, status_type, context)
    return M.build_section(side, status_type, context, 'statusline')
end

function M.update_all_statusline()
    return M.update_all_windows('statusline')
end

function M.update_statusline_window(winid)
    return M.update_window(winid, 'statusline')
end

function M.preview_statusline(config_override)
    return M.preview(config_override, 'statusline')
end

-- Convenience methods for winbar
function M.build_winbar_for_context(context)
    return M.build_for_context(context, 'winbar')
end

function M.update_all_winbar()
    return M.update_all_windows('winbar')
end

function M.update_winbar_window(winid)
    return M.update_window(winid, 'winbar')
end

function M.preview_winbar(config_override)
    return M.preview(config_override, 'winbar')
end

return M