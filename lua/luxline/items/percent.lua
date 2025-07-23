local items = require('luxline.items')

items.register('percent', function(variant, context)
    local current_line = vim.fn.line('.')
    local total_lines = vim.fn.line('$')
    if total_lines == 0 then
        return '0%'
    end
    
    if variant == 'decimal' then
        local percent = (current_line * 100) / total_lines
        return string.format('%.1f%%', percent)
    else
        local percent = math.floor((current_line * 100) / total_lines)
        return percent .. '%'
    end
end, {
    description = "File position percentage",
    category = "cursor",
    variants = { 'decimal' }
})