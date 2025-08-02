local M = {}

local state = {
    initialized = false,
    theme = nil,
    config = {},
    git_info = {},
}

function M.get(key)
    return state[key]
end

function M.set(key, value)
    if state[key] == value then
        return
    end
    state[key] = value
end

function M.update(updates)
    for key, value in pairs(updates) do
        if state[key] ~= value then
            state[key] = value
        end
    end
end

function M.get_git_info(repo_path)
    repo_path = repo_path or vim.fn.getcwd()
    return state.git_info[repo_path] or {}
end

function M.set_git_info(repo_path, info)
    repo_path = repo_path or vim.fn.getcwd()
    state.git_info[repo_path] = info
end

function M.reset()
    state = {
        initialized = false,
        theme = nil,
        config = {},
        git_info = {},
    }
end

return M