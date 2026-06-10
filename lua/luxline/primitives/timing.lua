local M = {}

local function close_timer(timer)
    timer:stop()
    if not timer:is_closing() then
        timer:close()
    end
end

function M.throttle(fn, get_delay)
    local armed = false
    local latched_args = nil
    return function(...)
        latched_args = { n = select('#', ...), ... }
        if armed then
            return
        end
        armed = true
        local timer = vim.uv.new_timer()
        timer:start(get_delay(), 0, function()
            close_timer(timer)
            vim.schedule(function()
                armed = false
                local args = latched_args
                latched_args = nil
                fn(unpack(args, 1, args.n))
            end)
        end)
    end
end

function M.keyed_debounce(get_delay)
    local timers = {}
    return function(key, fn)
        local existing = timers[key]
        if existing then
            close_timer(existing)
        end
        local timer = vim.uv.new_timer()
        timers[key] = timer
        timer:start(get_delay(), 0, function()
            close_timer(timer)
            timers[key] = nil
            vim.schedule(fn)
        end)
    end
end

return M
