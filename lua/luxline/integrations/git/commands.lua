local M = {}

local cache = require('luxline.primitives.cache')
local keys = require('luxline.integrations.git.cache').keys
local events = require('luxline.core.events')
local config = require('luxline.config')

local git_cache = cache.namespace('git')
local running_jobs = {}

local function get_repo_root(path)
    path = path or vim.fn.expand('%:p:h')
    local git_dir = vim.fn.finddir('.git', path .. ';')
    return git_dir ~= '' and vim.fn.fnamemodify(git_dir, ':h') or nil
end

local function build_git_cmd(cmd, repo_root)
    if not repo_root then
        return nil
    end
    return { 'git', '-C', repo_root, unpack(vim.split(cmd, ' ')) }
end

function M.execute_git_command(cmd, repo_root, callback, cache_key, force)
    cache_key = cache_key or cmd
    force = force or false

    if not force then
        local cached = git_cache:get(cache_key)
        if cached then
            callback(0, { cached })
            return
        end
    end

    local git_cmd = build_git_cmd(cmd, repo_root)
    if not git_cmd then
        callback(1, { '' })
        return
    end

    if running_jobs[cache_key] then
        return
    end

    running_jobs[cache_key] = true

    vim.system(git_cmd, { text = true }, function(result)
        running_jobs[cache_key] = nil

        local output = result.stdout and vim.trim(result.stdout) or ''
        if output ~= '' and result.code == 0 then
            local timeout = config.get().git_cache_timeout or 5000
            git_cache:set(cache_key, output, timeout)
        end

        callback(result.code, { output })

        events.emit_async('git_command_completed', {
            cmd = cmd,
            code = result.code,
            output = output,
            cache_key = cache_key
        })
    end)
end

function M.get_repo_root(path)
    return get_repo_root(path)
end

function M.get_repo_root_cached(path)
    path = path or vim.fn.expand('%:p:h')
    local cache_key = keys.repo_root(path)

    local cached = git_cache:get(cache_key)
    if cached then
        return cached
    end

    local repo_root = get_repo_root(path)
    if repo_root then
        git_cache:set(cache_key, repo_root, 30000)
    end

    return repo_root
end

return M