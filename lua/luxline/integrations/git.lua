local M = {}

local config = require('luxline.config')
local state = require('luxline.core.state')
local events = require('luxline.core.events')
local commands = require('luxline.integrations.git.commands')
local parser = require('luxline.integrations.git.parser')
local cache = require('luxline.integrations.git.cache')

function M.get_branch(repo_root)
    repo_root = repo_root or commands.get_repo_root()
    if not repo_root then
        return ''
    end
    
    local git_info = state.get_git_info(repo_root)
    return git_info.branch or ''
end

function M.get_diff_stats(repo_root)
    repo_root = repo_root or commands.get_repo_root()
    if not repo_root then
        return ''
    end
    
    local git_info = state.get_git_info(repo_root)
    return git_info.diff or ''
end

function M.get_combined(repo_root)
    local branch = M.get_branch(repo_root)
    local diff = M.get_diff_stats(repo_root)
    
    local parts = {}
    if branch ~= '' then
        table.insert(parts, '  ' .. branch)
    end
    if diff ~= '' then
        table.insert(parts, diff)
    end
    
    return table.concat(parts, ' ')
end


local function update_branch_info(repo_root, force)
    repo_root = repo_root or commands.get_repo_root()
    if not repo_root then
        return
    end
    
    commands.execute_git_command('rev-parse --abbrev-ref HEAD', repo_root, function(code, data)
        local git_info = state.get_git_info(repo_root)
        git_info.branch = (code == 0 and data[1] and data[1] ~= '') and data[1] or ''
        state.set_git_info(repo_root, git_info)
    end, 'branch_' .. repo_root, force)
end

local function update_diff_info(repo_root, force)
    repo_root = repo_root or commands.get_repo_root()
    if not repo_root then
        return
    end
    
    commands.execute_git_command('diff --shortstat', repo_root, function(code, data)
        local git_info = state.get_git_info(repo_root)
        git_info.diff = (code == 0 and data[1]) and parser.parse_diff_stats(data[1]) or ''
        state.set_git_info(repo_root, git_info)
    end, 'diff_' .. repo_root, force)
end

function M.update_git_info(repo_root, force)
    repo_root = repo_root or commands.get_repo_root()
    if not repo_root then
        return
    end
    
    update_branch_info(repo_root, force)
    update_diff_info(repo_root, force)
end

local git_timers = {}

function M.update_git_info_debounced(repo_root)
    repo_root = repo_root or commands.get_repo_root()
    if not repo_root then
        return
    end
    
    local timer_key = repo_root
    if git_timers[timer_key] then
        vim.fn.timer_stop(git_timers[timer_key])
    end
    
    local delay = config.get().git_diff_debounce or 200
    git_timers[timer_key] = vim.fn.timer_start(delay, function()
        git_timers[timer_key] = nil
        M.update_git_info(repo_root, false)
    end)
end

function M.clear_cache(repo_root)
    return cache.clear_cache(repo_root)
end

function M.is_git_repo(path)
    return commands.is_git_repo(path)
end

function M.get_repo_root_cached(path)
    return commands.get_repo_root_cached(path)
end

function M.setup()
    if not config.get().git_enabled then
        return
    end
    
    local group = vim.api.nvim_create_augroup('LuxlineGit', { clear = true })
    
    vim.api.nvim_create_autocmd('VimEnter', {
        group = group,
        callback = function()
            M.update_git_info(nil, true)
        end,
    })
    
    vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
        group = group,
        callback = function()
            M.update_git_info_debounced()
        end,
    })
    
    vim.api.nvim_create_autocmd('BufWritePost', {
        group = group,
        callback = function()
            M.update_git_info(nil, true)
        end,
    })
    
    vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
        group = group,
        callback = function()
            M.update_git_info_debounced()
        end,
    })
    
    vim.api.nvim_create_autocmd('DirChanged', {
        group = group,
        callback = function()
            M.clear_cache()
            M.update_git_info(nil, true)
        end,
    })
    
    local update_manager = require('luxline.core.update_manager')
    events.on('git_command_completed', function(data)
        update_manager.throttled_update()
    end)
end

return M