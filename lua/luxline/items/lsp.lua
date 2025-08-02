local items = require('luxline.items')

items.register('lsp', function(variant, context)
    local bufnr = context and context.bufnr or vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
    
    if #clients == 0 then
        return variant == 'status' and 'No LSP' or ''
    end
    
    if variant == 'count' then
        return tostring(#clients)
    elseif variant == 'names' then
        local names = {}
        for _, client in ipairs(clients) do
            table.insert(names, client.name)
        end
        return table.concat(names, ', ')
    elseif variant == 'first' then
        return clients[1].name
    elseif variant == 'status' then
        if #clients == 1 then
            return '󰒋 ' .. clients[1].name
        else
            return '󰒋 ' .. #clients .. ' servers'
        end
    else
        if #clients == 1 then
            return clients[1].name
        else
            local names = {}
            for _, client in ipairs(clients) do
                table.insert(names, client.name)
            end
            return table.concat(names, ', ')
        end
    end
end, {
    description = "LSP server status",
    category = "lsp",
    variants = { 'count', 'names', 'first', 'status' },
    cache = true,
    cache_ttl = 2000
})