local M = {}

local cache = require('luxline.primitives.cache')
local state = require('luxline.core.state')
local events = require('luxline.core.events')

local git_cache = cache.namespace('git')

function M.clear_cache(repo_root)
    if repo_root then
        git_cache:clear('branch_' .. repo_root)
        git_cache:clear('diff_' .. repo_root)
        
        local git_info = state.get_git_info(repo_root)
        git_info.branch = ''
        git_info.diff = ''
        state.set_git_info(repo_root, git_info)
    else
        git_cache:clear()
        state.set('git_info', {})
    end
    
    events.emit('git_cache_cleared', { repo_root = repo_root })
end

return M