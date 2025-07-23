local M = {}

local events = require('luxline.core.events')

local state = {
    initialized = false,
    theme = nil,
    config = {},
    git_info = {},
    window_states = {},
    item_cache = {},
    update_timer = nil,
}

function M.get(key)
    return state[key]
end

function M.set(key, value)
    local old_value = state[key]
    if old_value == value then
        return
    end
    
    state[key] = value
    
    events.emit_async('state_changed', {
        key = key,
        old_value = old_value,
        new_value = value
    })
end

function M.update(updates)
    local changes = {}
    
    for key, value in pairs(updates) do
        local old_value = state[key]
        if old_value ~= value then
            state[key] = value
            table.insert(changes, {
                key = key,
                old_value = old_value,
                new_value = value
            })
        end
    end
    
    if #changes > 0 then
        events.emit_async('state_batch_changed', changes)
    end
end

function M.get_git_info(repo_path)
    repo_path = repo_path or vim.fn.getcwd()
    return state.git_info[repo_path] or {}
end

function M.set_git_info(repo_path, info)
    repo_path = repo_path or vim.fn.getcwd()
    state.git_info[repo_path] = info
    
    events.emit_async('git_info_updated', {
        repo_path = repo_path,
        info = info
    })
end

function M.get_window_state(winid)
    return state.window_states[winid] or {}
end

function M.set_window_state(winid, window_state)
    state.window_states[winid] = window_state
end

function M.clear_cache(namespace)
    if namespace then
        state.item_cache[namespace] = nil
    else
        state.item_cache = {}
    end
    
    events.emit('cache_cleared', { namespace = namespace })
end

function M.reset()
    state = {
        initialized = false,
        theme = nil,
        config = {},
        git_info = {},
        window_states = {},
        item_cache = {},
        update_timer = nil,
    }
    events.emit('state_reset')
end

return M