local M = {}

local bar_builder = require('luxline.rendering.bar_builder')

-- Delegate all functionality to bar_builder convenience methods
function M.build_for_context(context)
    return bar_builder.build_statusline_for_context(context)
end

function M.build_section(side, status_type, context)
    return bar_builder.build_statusline_section(side, status_type, context)
end

function M.find_next_valid_item(item_list, current_idx, context)
    return bar_builder.find_next_valid_item(item_list, current_idx, context)
end

function M.update_all()
    return bar_builder.update_all_statusline()
end

function M.update_window(winid)
    return bar_builder.update_statusline_window(winid)
end

function M.preview(config_override)
    return bar_builder.preview_statusline(config_override)
end

return M