local M = {}

local config = require('luxline.config')
local items = require('luxline.items')
local highlight = require('luxline.rendering.highlight')
local utils = require('luxline.core.utils')
local events = require('luxline.core.events')

function M.build_for_context(context)
    local status_type = context.active and 'active' or 'inactive'
    local left_section = M.build_section('left', status_type, context, 'winbar')
    local right_section = M.build_section('right', status_type, context, 'winbar')
    
    return table.concat(left_section, '') .. '%=' .. table.concat(right_section, '')
end

function M.build_section(side, status_type, context, bar_type)
    bar_type = bar_type or 'winbar'
    local item_list = config.get_items(side, status_type, context.filetype, bar_type)
    local separator = config.get_separator(side)
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
            local hl_sep = next_idx > 0 and highlight.separator(separator, side, idx, next_idx, bar_type) or ''
            
            table.insert(section, hl_item .. hl_sep)
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

function M.update_all()
    local windows = utils.gather_window_info()
    
    for win, info in pairs(windows) do
        local winbar_content = M.build_for_context(info)
        local ok, err = pcall(vim.api.nvim_set_option_value, 'winbar', winbar_content, { win = win })
        if not ok then
            vim.notify('Failed to set winbar for window ' .. win .. ': ' .. err, vim.log.levels.WARN)
        end
    end
    
    events.emit('winbar_updated', { window_count = vim.tbl_count(windows) })
end

function M.update_window(winid)
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local current_win = vim.api.nvim_get_current_win()
    
    local context = {
        active = winid == current_win,
        bufnr = bufnr,
        filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr }),
        filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t'),
        winid = winid
    }
    
    local winbar_content = M.build_for_context(context)
    vim.api.nvim_set_option_value('winbar', winbar_content, { win = winid })
    
    events.emit('winbar_window_updated', { winid = winid })
end

function M.preview(config_override)
    local old_config = config.get()
    if config_override then
        config.setup(utils.deep_merge(vim.deepcopy(old_config), config_override))
    end
    
    local context = utils.get_current_context()
    context.active = true
    
    local preview = M.build_for_context(context)
    
    if config_override then
        config.setup(old_config)
    end
    
    return preview
end

return M