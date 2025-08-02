local items = require('luxline.items')

items.register('macro', function(variant, context)
    local recording = vim.fn.reg_recording()
    
    if recording == '' then
        return ''
    end
    
    if variant == 'short' then
        return '@' .. recording
    elseif variant == 'icon' then
        return '󰑋 ' .. recording
    else
        return 'recording @' .. recording
    end
end, {
    description = "Macro recording indicator",
    category = "editor",
    variants = { 'short', 'icon' }
})