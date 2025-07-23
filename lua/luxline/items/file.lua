local items = require('luxline.items')

items.register('filename', function(variant, context)
    local filename = context and context.filename or vim.fn.expand('%:t')
    
    if variant == 'full' then
        return vim.fn.expand('%:p')
    elseif variant == 'relative' then
        return vim.fn.expand('%:~:.')
    elseif variant == 'tail' then
        return filename
    else
        return filename ~= '' and filename or '[No Name]'
    end
end, {
    description = "Current file name",
    category = "file",
    variants = { 'full', 'relative', 'tail' }
})

items.register('filetype', function(variant, context)
    local ft = context and context.filetype or vim.bo.filetype
    
    if variant == 'icon' then
        local devicons_ok, devicons = pcall(require, 'nvim-web-devicons')
        if devicons_ok then
            local icon = devicons.get_icon_by_filetype(ft)
            return icon and (icon .. ' ' .. ft) or ft
        end
        return ft
    else
        return ft ~= '' and ft or '[no ft]'
    end
end, {
    description = "File type",
    category = "file",
    variants = { 'icon' }
})

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

items.register('modified', function(variant, context)
    local modified = vim.bo.modified
    
    if variant == 'icon' then
        return modified and '●' or ''
    elseif variant == 'short' then
        return modified and '[+]' or ''
    else
        return modified and '[Modified]' or ''
    end
end, {
    description = "File modification indicator",
    category = "file",
    variants = { 'icon', 'short' }
})

items.register('readonly', function(variant, context)
    local readonly = vim.bo.readonly
    
    if variant == 'icon' then
        return readonly and '' or ''
    elseif variant == 'short' then
        return readonly and '[RO]' or ''
    else
        return readonly and '[Readonly]' or ''
    end
end, {
    description = "Read-only file indicator",
    category = "file",
    variants = { 'icon', 'short' }
})

items.register('cwd', function(variant, context)
    local cwd = context and context.cwd or vim.fn.getcwd()
    
    if variant == 'full' then
        return cwd
    elseif variant == 'short' then
        return vim.fn.pathshorten(cwd)
    else
        return vim.fn.fnamemodify(cwd, ':t')
    end
end, {
    description = "Current working directory",
    category = "file",
    variants = { 'full', 'short' },
    cache = true,
    cache_ttl = 5000
})