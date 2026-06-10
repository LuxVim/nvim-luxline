local definition = require('luxline.items.definition')
local git = require('luxline.integrations.git')

definition.define('git', {
    description = 'Git repository information',
    category = 'vcs',
    cache = true,
    cache_ttl = 2000,
    get = function(ctx)
        local cwd = ctx and ctx.cwd or vim.fn.getcwd()
        return git.get_repo_root_cached(cwd)
    end,
    variants = {
        branch = function(repo_root) return git.get_branch(repo_root) end,
        diff = function(repo_root) return git.get_diff_stats(repo_root) end,
        combined = function(repo_root) return git.get_combined(repo_root) end,
        status = function(repo_root)
            local branch = git.get_branch(repo_root)
            local diff = git.get_diff_stats(repo_root)

            if branch == '' and diff == '' then
                return ''
            elseif branch ~= '' and diff ~= '' then
                return '  ' .. branch .. ' [' .. diff .. ']'
            elseif branch ~= '' then
                return '  ' .. branch .. ' [clean]'
            end
            return '  [' .. diff .. ']'
        end,
    },
    format = function(repo_root)
        return git.get_combined(repo_root)
    end,
})