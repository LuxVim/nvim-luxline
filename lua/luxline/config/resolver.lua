local M = {}

function M.lookup(config, defaults, candidates)
    for _, key in ipairs(candidates) do
        local value = config[key]
        if value == nil then
            value = defaults[key]
        end
        if value ~= nil then
            return value, key
        end
    end
    return nil
end

return M
