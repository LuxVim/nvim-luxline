local M = {}

local store = {}

local Namespace = {}
Namespace.__index = Namespace

function Namespace:get(key)
    local entry = self.entries[key]
    if not entry then
        return nil
    end
    if entry.expires and vim.uv.now() > entry.expires then
        self.entries[key] = nil
        return nil
    end
    return entry.value
end

function Namespace:set(key, value, ttl)
    self.entries[key] = {
        value = value,
        expires = ttl and (vim.uv.now() + ttl) or nil,
    }
end

function Namespace:clear(key)
    if key then
        self.entries[key] = nil
    else
        self.entries = {}
    end
end

function M.namespace(name)
    if not store[name] then
        store[name] = setmetatable({ name = name, entries = {} }, Namespace)
    end
    return store[name]
end

function M.clear_all()
    for _, namespace in pairs(store) do
        namespace.entries = {}
    end
end

return M
