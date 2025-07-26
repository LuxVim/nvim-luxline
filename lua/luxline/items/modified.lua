local items = require('luxline.items')

items.register('modified', function(variant, context)
    local modified
    if context and context.bufnr then
        modified = vim.api.nvim_get_option_value('modified', { buf = context.bufnr })
    else
        modified = vim.bo.modified
    end
    
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