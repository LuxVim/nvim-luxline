local items = require('luxline.items')

items.register('search', function(variant, context)
    if vim.v.hlsearch == 0 or vim.fn.getreg('/') == '' then
        return ''
    end
    
    local search_pattern = vim.fn.getreg('/')
    local search_count = vim.fn.searchcount({ maxcount = 999, timeout = 100 })
    
    if search_count.total == 0 then
        return ''
    end
    
    if variant == 'count' then
        return tostring(search_count.total)
    elseif variant == 'current_total' then
        return search_count.current .. '/' .. search_count.total
    elseif variant == 'pattern' then
        return search_pattern
    elseif variant == 'short' then
        return '[' .. search_count.current .. '/' .. search_count.total .. ']'
    else
        return '󰍉 ' .. search_count.current .. '/' .. search_count.total
    end
end, {
    description = "Search results information",
    category = "editor",
    variants = { 'count', 'current_total', 'pattern', 'short' },
    cache = true,
    cache_ttl = 100
})