local M = {}

local config = require('luxline.config')
local items = require('luxline.items')
local highlight = require('luxline.rendering.highlight')
local window_context = require('luxline.core.context')
local tbl = require('luxline.primitives.table')
local events = require('luxline.core.events')

function M.build_for_context(ctx, bar_type)
    bar_type = bar_type or 'statusline'
    local status_type = ctx.active and 'active' or 'inactive'
    local left_section = M.build_section('left', status_type, ctx, bar_type)
    local right_section = M.build_section('right', status_type, ctx, bar_type)

    return table.concat(left_section, '') .. '%=' .. table.concat(right_section, '')
end

function M.build_section(side, status_type, ctx, bar_type)
    bar_type = bar_type or 'statusline'
    local item_list = config.get_items(side, status_type, ctx.filetype, bar_type, ctx.buftype)
    local separator = config.get_separator(side, bar_type)
    local section = {}

    if side == 'right' then
        item_list = tbl.reverse(item_list)
    end

    local valid_items = {}
    local rendered_position = 1

    for idx, item_spec in ipairs(item_list) do
        local item_name, variant = items.parse_spec(item_spec)
        local item_value = items.get_value(item_name, variant, ctx)

        if item_value and item_value ~= '' then
            valid_items[#valid_items + 1] = {
                original_idx = idx,
                rendered_idx = rendered_position,
                item_name = item_name,
                item_value = item_value,
                item_spec = item_spec
            }
            rendered_position = rendered_position + 1
        end
    end

    local item_highlights = {}
    for i, item_info in ipairs(valid_items) do
        local hl_formatted = highlight.item(item_info.item_value, side, item_info.rendered_idx, bar_type, item_info.item_name)
        local hl_group_name = highlight.extract_highlight_group(hl_formatted)
        item_highlights[i] = {
            formatted = hl_formatted,
            group_name = hl_group_name,
        }
    end

    for i, hl_info in ipairs(item_highlights) do
        if side == 'left' then
            local next_hl_group = (i < #item_highlights) and item_highlights[i + 1].group_name or nil
            local hl_sep = highlight.separator_direct(separator, side, hl_info.group_name, next_hl_group, bar_type)
            table.insert(section, hl_info.formatted .. hl_sep)
        else
            local prev_hl_group = (i > 1) and item_highlights[i - 1].group_name or nil
            local hl_sep = highlight.separator_direct(separator, side, prev_hl_group, hl_info.group_name, bar_type)
            table.insert(section, hl_sep .. hl_info.formatted)
        end
    end

    return section
end

local function render_window(win, ctx, bar_type)
    if bar_type == 'winbar' and config.is_winbar_disabled_for_filetype(ctx.filetype) then
        return
    end

    local content = M.build_for_context(ctx, bar_type)
    local ok, err = pcall(vim.api.nvim_set_option_value, bar_type, content, { win = win })
    if not ok then
        vim.notify('Failed to set ' .. bar_type .. ' for window ' .. win .. ': ' .. err, vim.log.levels.WARN)
    end
end

function M.update_all_windows(bar_type)
    bar_type = bar_type or 'statusline'
    local windows = window_context.gather_window_info()

    for win, ctx in pairs(windows) do
        render_window(win, ctx, bar_type)
    end

    events.emit(bar_type .. '_updated', { window_count = vim.tbl_count(windows) })
end

function M.preview(config_override, bar_type)
    bar_type = bar_type or 'statusline'
    local old_config = config.get()
    if config_override then
        config.setup(tbl.deep_merge(vim.deepcopy(old_config), config_override))
    end

    local ctx = window_context.get_current_context()
    ctx.active = true

    local preview = M.build_for_context(ctx, bar_type)

    if config_override then
        config.setup(old_config)
    end

    return preview
end

for _, bar_type in ipairs({ 'statusline', 'winbar' }) do
    M[bar_type] = {
        build_for_context = function(ctx)
            return M.build_for_context(ctx, bar_type)
        end,
        build_section = function(side, status_type, ctx)
            return M.build_section(side, status_type, ctx, bar_type)
        end,
        update_all = function()
            return M.update_all_windows(bar_type)
        end,
        preview = function(config_override)
            return M.preview(config_override, bar_type)
        end,
    }
end

return M