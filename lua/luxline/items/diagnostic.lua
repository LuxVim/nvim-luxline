local items = require('luxline.items')

items.register('diagnostic', function(variant, context)
    local bufnr = context and context.bufnr or vim.api.nvim_get_current_buf()
    
    if not vim.diagnostic then
        return ''
    end
    
    local diagnostics = vim.diagnostic.get(bufnr)
    local counts = { error = 0, warn = 0, info = 0, hint = 0 }
    
    for _, diagnostic in ipairs(diagnostics) do
        if diagnostic.severity == vim.diagnostic.severity.ERROR then
            counts.error = counts.error + 1
        elseif diagnostic.severity == vim.diagnostic.severity.WARN then
            counts.warn = counts.warn + 1
        elseif diagnostic.severity == vim.diagnostic.severity.INFO then
            counts.info = counts.info + 1
        elseif diagnostic.severity == vim.diagnostic.severity.HINT then
            counts.hint = counts.hint + 1
        end
    end
    
    if variant == 'errors_only' then
        return counts.error > 0 and ('󰅚 ' .. counts.error) or ''
    elseif variant == 'warnings_only' then
        return counts.warn > 0 and ('󰀪 ' .. counts.warn) or ''
    elseif variant == 'count' then
        local total = counts.error + counts.warn + counts.info + counts.hint
        return total > 0 and tostring(total) or ''
    elseif variant == 'summary' then
        local parts = {}
        if counts.error > 0 then
            table.insert(parts, 'E:' .. counts.error)
        end
        if counts.warn > 0 then
            table.insert(parts, 'W:' .. counts.warn)
        end
        if counts.info > 0 then
            table.insert(parts, 'I:' .. counts.info)
        end
        if counts.hint > 0 then
            table.insert(parts, 'H:' .. counts.hint)
        end
        return #parts > 0 and table.concat(parts, ' ') or ''
    else
        local parts = {}
        if counts.error > 0 then
            table.insert(parts, '󰅚 ' .. counts.error)
        end
        if counts.warn > 0 then
            table.insert(parts, '󰀪 ' .. counts.warn)
        end
        if counts.info > 0 then
            table.insert(parts, '󰋽 ' .. counts.info)
        end
        if counts.hint > 0 then
            table.insert(parts, '󰌶 ' .. counts.hint)
        end
        return #parts > 0 and table.concat(parts, ' ') or ''
    end
end, {
    description = "LSP diagnostic information",
    category = "lsp",
    variants = { 'errors_only', 'warnings_only', 'count', 'summary' },
    cache = true,
    cache_ttl = 500
})