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