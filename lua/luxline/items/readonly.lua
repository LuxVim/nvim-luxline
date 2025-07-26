local items = require('luxline.items')

items.register('readonly', function(variant, context)
    local readonly
    if context and context.bufnr then
        readonly = vim.api.nvim_get_option_value('readonly', { buf = context.bufnr })
    else
        readonly = vim.bo.readonly
    end
    
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