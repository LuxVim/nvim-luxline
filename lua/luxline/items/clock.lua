local items = require('luxline.items')

items.register('clock', function(variant, context)
    if variant == '12h' then
        return os.date('%I:%M %p')
    elseif variant == 'seconds' then
        return os.date('%H:%M:%S')
    elseif variant == 'short' then
        return os.date('%H:%M')
    elseif variant == 'full' then
        return os.date('%H:%M:%S %Z')
    else
        return os.date('%H:%M')
    end
end, {
    description = "Current time",
    category = "system",
    variants = { '12h', 'seconds', 'short', 'full' },
    cache = true,
    cache_ttl = 1000
})