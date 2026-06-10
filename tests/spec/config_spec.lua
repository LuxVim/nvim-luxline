local assert = dofile(vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h') .. '/helpers/assert.lua')
local config = require('luxline.config')

local LUXVIM_OPTS = {
    right_active_items_winbar_NvimTree = {},
    right_inactive_items_winbar_NvimTree = {},
    left_active_items_winbar_terminal = { 'windownumber' },
    left_inactive_items_winbar_terminal = { 'windownumber' },
    right_active_items_winbar_terminal = {},
    right_inactive_items_winbar_terminal = {},
    left_active_items = { 'filename:tail', 'git:status' },
    left_inactive_items = {},
    right_active_items = { 'position', 'filetype:icon', 'encoding:short' },
    right_inactive_items = { 'filename:tail' },
    winbar_enabled = true,
    winbar_disabled_filetypes = { 'luxterm_main', 'luxterm_preview' },
    left_active_items_winbar = { 'windownumber' },
    left_inactive_items_winbar = { 'windownumber' },
    right_active_items_winbar = { 'modified', 'filename:tail' },
    right_inactive_items_winbar = { 'modified', 'filename:tail' },
    left_separator = '',
    right_separator = '',
    left_separator_winbar = '▶',
    right_separator_winbar = '◀',
    update_throttle = 20,
    git_cache_timeout = 5000,
    git_diff_debounce = 200,
    git_enabled = true,
    default_theme = 'default',
}

describe('config', function()
    it('replaces list values instead of index-merging (LuxVim regression)', function()
        config.setup(vim.deepcopy(LUXVIM_OPTS))
        local conf = config.get()
        assert.eq(conf.left_active_items, { 'filename:tail', 'git:status' })
        assert.eq(conf.left_inactive_items, {})
        assert.eq(conf.right_inactive_items, { 'filename:tail' })
    end)

    it('leaves the unaffected LuxVim keys exactly as supplied', function()
        config.setup(vim.deepcopy(LUXVIM_OPTS))
        local conf = config.get()
        assert.eq(conf.right_active_items, { 'position', 'filetype:icon', 'encoding:short' })
        assert.eq(conf.right_active_items_winbar, { 'modified', 'filename:tail' })
        assert.eq(conf.left_active_items_winbar_terminal, { 'windownumber' })
        assert.eq(conf.right_active_items_winbar_NvimTree, {})
        assert.eq(conf.right_inactive_items_winbar_NvimTree, {})
        assert.eq(conf.right_active_items_winbar_terminal, {})
        assert.eq(conf.right_inactive_items_winbar_terminal, {})
    end)

    it('resolves item specificity: buftype > filetype > base', function()
        config.setup({
            left_active_items = { 'filename' },
            left_active_items_lua = { 'position' },
            left_active_items_buftype_terminal = { 'windownumber' },
        })
        assert.eq(config.get_items('left', 'active', 'lua', 'statusline', 'terminal'), { 'windownumber' })
        assert.eq(config.get_items('left', 'active', 'lua', 'statusline', ''), { 'position' })
        assert.eq(config.get_items('left', 'active', 'python', 'statusline', ''), { 'filename' })
    end)

    it('applies the winbar suffix to items and separators with base fallback', function()
        config.setup({})
        assert.eq(config.get_items('left', 'active', nil, 'winbar', nil), { 'windownumber' })
        assert.eq(config.get_separator('left', 'winbar'), '█')
        config.setup({ left_separator_winbar = '>' })
        assert.eq(config.get_separator('left', 'winbar'), '>')
        assert.eq(config.get_separator('left', 'statusline'), '█')
    end)

    it('rejects invalid config values via the schema', function()
        assert.errors(function() config.setup({ update_throttle = 'fast' }) end)
        assert.errors(function() config.setup({ left_active_items = 'filename' }) end)
        assert.errors(function() config.setup({ left_separator = 5 }) end)
    end)

    it('detects disabled winbar filetypes', function()
        config.setup({ winbar_disabled_filetypes = { 'NvimTree' } })
        assert.truthy(config.is_winbar_disabled_for_filetype('NvimTree'))
        assert.falsy(config.is_winbar_disabled_for_filetype('lua'))
    end)
end)
