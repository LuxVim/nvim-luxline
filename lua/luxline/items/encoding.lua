local items = require('luxline.items')

items.register('encoding', function(variant, context)
    local enc = vim.bo.fileencoding
    if enc == '' then
        enc = vim.o.encoding
    end
    
    if variant == 'short' then
        local short_names = {
            ['utf-8'] = 'UTF8',
            ['utf-16'] = 'UTF16',
            ['latin1'] = 'LAT1'
        }
        return short_names[enc] or enc
    else
        return enc
    end
end, {
    description = "File encoding",
    category = "file",
    variants = { 'short' }
})