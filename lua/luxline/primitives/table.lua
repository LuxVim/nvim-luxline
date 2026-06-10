local M = {}

function M.deep_merge(target, source)
    target = target or {}
    if type(source) ~= 'table' then
        return source
    end
    for key, value in pairs(source) do
        if type(value) == 'table' and type(target[key]) == 'table' then
            target[key] = M.deep_merge(target[key], value)
        else
            target[key] = value
        end
    end
    return target
end

function M.reverse(list)
    local reversed = {}
    for i = #list, 1, -1 do
        table.insert(reversed, list[i])
    end
    return reversed
end

return M
