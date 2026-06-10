local M = {}

local function create_context_fields(winid, bufnr, current_win)
    return {
        active = winid == current_win,
        winid = winid,
        bufnr = bufnr,
        filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr }),
        buftype = vim.api.nvim_get_option_value('buftype', { buf = bufnr }),
        filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t'),
        cwd = vim.fn.getcwd(),
    }
end

function M.create_context(winid, bufnr)
    winid = winid or vim.api.nvim_get_current_win()
    bufnr = bufnr or vim.api.nvim_win_get_buf(winid)
    return create_context_fields(winid, bufnr, vim.api.nvim_get_current_win())
end

function M.get_current_context()
    return M.create_context()
end

function M.gather_window_info()
    local windows = {}
    local current_win = vim.api.nvim_get_current_win()
    for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
            windows[win] = create_context_fields(win, vim.api.nvim_win_get_buf(win), current_win)
        end
    end
    return windows
end

return M
