local items = require('luxline.items')

items.register('windownumber', function(variant, context)
    -- If we have a winid in context (for winbar), use that to get the window number
    if context.winid then
        local ok, win_number = pcall(vim.api.nvim_win_get_number, context.winid)
        if ok then
            return tostring(win_number)
        end
    end
    return tostring(vim.fn.winnr())
end, {
    description = "Current window number",
    category = "window"
})