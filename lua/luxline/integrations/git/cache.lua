local M = {}

local utils = require('luxline.core.utils')
local state = require('luxline.core.state')
local events = require('luxline.core.events')

function M.clear_cache(repo_root)
    if repo_root then
        utils.cache_clear('git', 'branch_' .. repo_root)
        utils.cache_clear('git', 'diff_' .. repo_root)
        
        local git_info = state.get_git_info(repo_root)
        git_info.branch = ''
        git_info.diff = ''
        state.set_git_info(repo_root, git_info)
    else
        utils.cache_clear('git')
        state.set('git_info', {})
    end
    
    events.emit('git_cache_cleared', { repo_root = repo_root })
end

return M