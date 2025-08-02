local items = require('luxline.items')

items.register('filesize', function(variant, context)
    local filename = context and context.filename or vim.fn.expand('%')
    
    if filename == '' or filename == '[No Name]' then
        return ''
    end
    
    local stat = vim.loop.fs_stat(filename)
    if not stat then
        return ''
    end
    
    local size = stat.size
    
    if variant == 'bytes' then
        return tostring(size) .. 'B'
    elseif variant == 'short' then
        if size < 1024 then
            return tostring(size) .. 'B'
        elseif size < 1024 * 1024 then
            return string.format('%.1fK', size / 1024)
        else
            return string.format('%.1fM', size / (1024 * 1024))
        end
    else
        if size < 1024 then
            return tostring(size) .. ' bytes'
        elseif size < 1024 * 1024 then
            return string.format('%.1f KB', size / 1024)
        elseif size < 1024 * 1024 * 1024 then
            return string.format('%.1f MB', size / (1024 * 1024))
        else
            return string.format('%.1f GB', size / (1024 * 1024 * 1024))
        end
    end
end, {
    description = "Current file size",
    category = "file", 
    variants = { 'bytes', 'short' },
    cache = true,
    cache_ttl = 5000
})