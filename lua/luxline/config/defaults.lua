local M = {}

M.defaults = {
    left_active_items = { 'windownumber', 'filename', 'modified' },
    left_inactive_items = { 'windownumber', 'filename', 'modified' },
    right_active_items = { 'position', 'filetype', 'encoding' },
    right_inactive_items = { 'position', 'filetype', 'encoding' },
    
    -- Winbar configuration
    winbar_enabled = true,
    winbar_disabled_filetypes = {},
    left_active_items_winbar = { 'windownumber' },
    left_inactive_items_winbar = { 'windownumber' },
    right_active_items_winbar = { 'filename:tail' },
    right_inactive_items_winbar = { 'filename:tail' },
    
    left_separator = '█',
    right_separator = '█',
    left_separator_winbar = '█',
    right_separator_winbar = '█',
    
    buffer_exclude = {},
    update_throttle = 20,
    default_theme = 'default',
    git_cache_timeout = 5000,
    git_diff_debounce = 200,
    git_enabled = true,
}

function M.get_defaults()
    return vim.deepcopy(M.defaults)
end

return M
