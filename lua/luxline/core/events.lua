local M = {}

local listeners = {}

function M.emit(event, data)
    if listeners[event] then
        for _, callback in ipairs(listeners[event]) do
            local ok, err = pcall(callback, data)
            if not ok then
                vim.notify('Luxline event error (' .. event .. '): ' .. err, vim.log.levels.ERROR)
            end
        end
    end
end

function M.emit_async(event, data)
    if listeners[event] then
        for _, callback in ipairs(listeners[event]) do
            vim.schedule(function()
                local ok, err = pcall(callback, data)
                if not ok then
                    vim.notify('Luxline async event error (' .. event .. '): ' .. err, vim.log.levels.ERROR)
                end
            end)
        end
    end
end

function M.on(event, callback)
    if type(callback) ~= 'function' then
        error('Event callback must be a function')
    end
    
    if not listeners[event] then
        listeners[event] = {}
    end
    table.insert(listeners[event], callback)
    
    return function()
        M.off(event, callback)
    end
end

function M.off(event, callback)
    if listeners[event] then
        for i, cb in ipairs(listeners[event]) do
            if cb == callback then
                table.remove(listeners[event], i)
                break
            end
        end
    end
end

function M.clear(event)
    if event then
        listeners[event] = nil
    else
        listeners = {}
    end
end

function M.get_listeners(event)
    return listeners[event] and #listeners[event] or 0
end

return M