local M = {}

local bar_builder = require('luxline.rendering.bar_builder')
local utils = require('luxline.core.utils')
local events = require('luxline.core.events')

function M.build_for_context(context)
    return bar_builder.build_for_context(context, 'winbar')
end


function M.update_all()
    bar_builder.update_all_windows('winbar')
end

function M.update_window(winid)
    bar_builder.update_window(winid, 'winbar')
end

function M.preview(config_override)
    return bar_builder.preview(config_override, 'winbar')
end

return M