local items = require('luxline.items')
local git = require('luxline.integrations.git')

items.register('git', function(variant, context)
    local cwd = context and context.cwd or vim.fn.getcwd()
    local repo_root = git.get_repo_root_cached(cwd)
    
    if not repo_root then
        return ''
    end
    
    if variant == 'branch' or variant == 'branch_only' then
        return git.get_branch(repo_root)
    elseif variant == 'diff' or variant == 'diff_only' then
        return git.get_diff_stats(repo_root)
    elseif variant == 'combined' or not variant then
        return git.get_combined(repo_root)
    elseif variant == 'status' then
        local branch = git.get_branch(repo_root)
        local diff = git.get_diff_stats(repo_root)
        
        if branch == '' and diff == '' then
            return ''
        elseif branch ~= '' and diff ~= '' then
            return '  ' .. branch .. ' [' .. diff .. ']'
        elseif branch ~= '' then
            return '  ' .. branch .. ' [clean]'
        else
            return '  [' .. diff .. ']'
        end
    else
        return git.get_combined(repo_root)
    end
end, {
    description = "Git repository information",
    category = "vcs",
    variants = { 'branch', 'diff', 'combined', 'status' },
    cache = true,
    cache_ttl = 2000
})