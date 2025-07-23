local items = require('luxline.items')

items.register('position', function(variant, context)
    if variant == 'line' then
        return tostring(vim.fn.line('.'))
    elseif variant == 'column' then
        return tostring(vim.fn.col('.'))
    else
        return vim.fn.line('.') .. ':' .. vim.fn.col('.')
    end
end, {
    description = "Cursor position (line:column)",
    category = "cursor",
    variants = { 'line', 'column' }
})