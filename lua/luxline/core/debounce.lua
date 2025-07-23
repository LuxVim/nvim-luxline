local M = {}

local timers = {}

function M.debounce(key, delay, fn)
    if timers[key] then
        vim.fn.timer_stop(timers[key])
        timers[key] = nil
    end
    
    timers[key] = vim.fn.timer_start(delay, function()
        timers[key] = nil
        local ok, err = pcall(fn)
        if not ok then
            vim.notify('Luxline debounced function error (' .. key .. '): ' .. err, vim.log.levels.ERROR)
        end
    end)
end

function M.throttle(key, delay, fn)
    if timers[key] then
        return false
    end
    
    timers[key] = vim.fn.timer_start(delay, function()
        timers[key] = nil
    end)
    
    local ok, err = pcall(fn)
    if not ok then
        vim.notify('Luxline throttled function error (' .. key .. '): ' .. err, vim.log.levels.ERROR)
        return false
    end
    
    return true
end

function M.delay(key, delay, fn)
    if timers[key] then
        vim.fn.timer_stop(timers[key])
    end
    
    timers[key] = vim.fn.timer_start(delay, function()
        timers[key] = nil
        local ok, err = pcall(fn)
        if not ok then
            vim.notify('Luxline delayed function error (' .. key .. '): ' .. err, vim.log.levels.ERROR)
        end
    end)
end

function M.cancel(key)
    if timers[key] then
        vim.fn.timer_stop(timers[key])
        timers[key] = nil
        return true
    end
    return false
end

function M.cancel_all()
    for key, timer_id in pairs(timers) do
        vim.fn.timer_stop(timer_id)
    end
    timers = {}
end

function M.is_pending(key)
    return timers[key] ~= nil
end

function M.get_pending()
    local pending = {}
    for key, _ in pairs(timers) do
        table.insert(pending, key)
    end
    return pending
end

return M