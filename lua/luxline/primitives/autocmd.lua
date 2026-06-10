local M = {}

function M.bind(group_name, specs)
    local group = vim.api.nvim_create_augroup(group_name, { clear = true })
    for _, spec in ipairs(specs) do
        vim.api.nvim_create_autocmd(spec.events, {
            group = group,
            pattern = spec.pattern,
            callback = spec.handler,
        })
    end
    return group
end

return M
