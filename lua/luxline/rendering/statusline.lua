local M = {}

local bar_builder = require('luxline.rendering.bar_builder')

-- Delegate all functionality to bar_builder with 'statusline' type
function M.build_for_context(context)
    return bar_builder.build_for_context(context, 'statusline')
end

function M.build_section(side, status_type, context)
    return bar_builder.build_section(side, status_type, context, 'statusline')
end

function M.find_next_valid_item(item_list, current_idx, context)
    return bar_builder.find_next_valid_item(item_list, current_idx, context)
end

function M.update_all()
    return bar_builder.update_all_windows('statusline')
end

function M.update_window(winid)
    return bar_builder.update_window(winid, 'statusline')
end

function M.preview(config_override)
    return bar_builder.preview(config_override, 'statusline')
end

return M