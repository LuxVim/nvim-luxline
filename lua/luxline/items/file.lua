local base = require('luxline.items.base')
local items = require('luxline.items')

base.create_file_path_item('filename', {
    description = "Current file name",
    variants = {
        full = function() return vim.fn.expand('%:p') end,
        relative = function() return vim.fn.expand('%:~:.') end,
        tail = function(filename) return filename end
    }
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