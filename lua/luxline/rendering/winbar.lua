local M = {}

local bar_builder = require('luxline.rendering.bar_builder')

function M.build_for_context(context)
    return bar_builder.build_winbar_for_context(context)
end

function M.update_all()
    bar_builder.update_all_winbar()
end

function M.update_window(winid)
    bar_builder.update_winbar_window(winid)
end

function M.preview(config_override)
    return bar_builder.preview_winbar(config_override)
end

return M