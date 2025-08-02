local M = {}

local listeners = {}

function M.emit(event, data)
    local event_listeners = listeners[event]
    if event_listeners then
        for i = 1, #event_listeners do
            local ok, err = pcall(event_listeners[i], data)
            if not ok then
                vim.schedule(function()
                    vim.notify('Luxline event error (' .. event .. '): ' .. err, vim.log.levels.ERROR)
                end)
            end
        end
    end
end

function M.emit_async(event, data)
    vim.schedule(function()
        M.emit(event, data)
    end)
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