local M = {}

local function resolve(raw, variant, spec, ctx)
    if raw == nil then
        return ''
    end
    if variant and spec.variants and spec.variants[variant] then
        return spec.variants[variant](raw, ctx)
    end
    if spec.format then
        return spec.format(raw)
    end
    return tostring(raw)
end

function M.define(name, spec)
    local items = require('luxline.items')

    local variant_names = vim.tbl_keys(spec.variants or {})
    table.sort(variant_names)

    items.register(name, function(variant, ctx)
        return resolve(spec.get(ctx), variant, spec, ctx)
    end, {
        description = spec.description,
        category = spec.category,
        variants = variant_names,
        cache = spec.cache,
        cache_ttl = spec.cache_ttl,
    })
end

return M
