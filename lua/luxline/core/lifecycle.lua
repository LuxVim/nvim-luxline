local M = {}

local config = require('luxline.config')
local themes = require('luxline.themes')
local git = require('luxline.integrations.git')
local items = require('luxline.items')
local events = require('luxline.core.events')
local debounce = require('luxline.core.debounce')
local state = require('luxline.core.state')

function M.setup(opts)
    if state.get('initialized') then
        vim.notify('Luxline already initialized', vim.log.levels.WARN)
        return
    end
    
    config.setup(opts)
    themes.setup()
    items.setup()
    git.setup()
    
    local autocommands = require('luxline.core.autocommands')
    local update_manager = require('luxline.core.update_manager')
    
    autocommands.setup()
    update_manager.setup_events()
    
    themes.set_theme()
    update_manager.update()
    
    state.set('initialized', true)
    events.emit('luxline_initialized')
end

function M.get_stats()
    local highlight = require('luxline.rendering.highlight')
    
    return {
        initialized = state.get('initialized'),
        theme = state.get('theme'),
        items_count = #items.get_all_items(),
        highlight_groups = #highlight.get_active_groups(),
        git_repos = vim.tbl_count(state.get('git_info') or {}),
        pending_operations = debounce.get_pending()
    }
end

function M.reset()
    debounce.cancel_all()
    events.clear()
    
    local highlight = require('luxline.rendering.highlight')
    highlight.clear_highlights()
    
    state.reset()
    config.reset_to_defaults()
    
    events.emit('luxline_reset')
end

function M.reload()
    M.reset()
    
    package.loaded['luxline'] = nil
    package.loaded['luxline.config'] = nil
    package.loaded['luxline.rendering.statusline'] = nil
    package.loaded['luxline.rendering.winbar'] = nil
    package.loaded['luxline.rendering.highlight'] = nil
    package.loaded['luxline.rendering.bar_builder'] = nil
    package.loaded['luxline.themes'] = nil
    package.loaded['luxline.items'] = nil
    package.loaded['luxline.integrations.git'] = nil
    package.loaded['luxline.core.lifecycle'] = nil
    package.loaded['luxline.core.autocommands'] = nil
    package.loaded['luxline.core.update_manager'] = nil
    package.loaded['luxline.debug'] = nil
    
    for module_name, _ in pairs(package.loaded) do
        if module_name:match('^luxline%.') then
            package.loaded[module_name] = nil
        end
    end
    
    local new_config = config.export()
    require('luxline').setup(new_config)
    
    vim.notify('Luxline reloaded', vim.log.levels.INFO)
end

return M