local M = {}

local bar_builder = require('luxline.rendering.bar_builder')
local items = require('luxline.items')
local themes = require('luxline.themes')

function M.preview_config(config_override)
    return bar_builder.statusline.preview(config_override)
end

function M.debug()
    local lifecycle = require('luxline.core.lifecycle')
    local stats = lifecycle.get_stats()
    
    print('=== Luxline Debug Info ===')
    print('Initialized:', stats.initialized)
    print('Theme:', stats.theme or 'none')
    print('Items loaded:', stats.items_count)
    print('Highlight groups:', stats.highlight_groups)
    print('Git repositories:', stats.git_repos)
    print('Pending operations:', 'none')
    
    print('\n=== Available Items ===')
    local all_items = items.get_all_items()
    table.sort(all_items)
    for _, item_name in ipairs(all_items) do
        local item_info = items.get_item_info(item_name)
        local variants = #item_info.variants > 0 and (' (' .. table.concat(item_info.variants, ', ') .. ')') or ''
        print(string.format('  %s [%s]%s - %s', item_name, item_info.category, variants, item_info.description))
    end
    
    print('\n=== Available Themes ===')
    local theme_names = themes.get_theme_names()
    table.sort(theme_names)
    for _, theme_name in ipairs(theme_names) do
        print('  ' .. theme_name)
    end
end

return M