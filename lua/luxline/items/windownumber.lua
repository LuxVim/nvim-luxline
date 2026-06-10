local definition = require('luxline.items.definition')

definition.define('windownumber', {
    description = 'Current window number',
    category = 'window',
    get = function(ctx)
        if ctx and ctx.winid then
            local ok, win_number = pcall(vim.api.nvim_win_get_number, ctx.winid)
            if ok then
                return win_number
            end
        end
        return vim.fn.winnr()
    end,
})