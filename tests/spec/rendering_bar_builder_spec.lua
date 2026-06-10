local assert = dofile(vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h') .. '/helpers/assert.lua')

local function fixture_theme()
    local themes = require('luxline.themes')
    themes.register('bar-spec-theme', {
        gradient = {
            { bg = '#101010', fg = '#ffffff' }, { bg = '#202020', fg = '#ffffff' },
            { bg = '#303030', fg = '#ffffff' }, { bg = '#404040', fg = '#ffffff' },
            { bg = '#505050', fg = '#ffffff' }, { bg = '#606060', fg = '#ffffff' },
            { bg = '#707070', fg = '#ffffff' },
        },
        middle = '#202020',
    })
    themes.set_theme('bar-spec-theme')
end

describe('rendering.bar_builder', function()
    it('builds the golden statusline string for two fixed items', function()
        require('luxline').setup({ git_enabled = false })
        local items = require('luxline.items')
        items.register('bar_spec_alpha', function() return 'A' end, {})
        items.register('bar_spec_beta', function() return 'B' end, {})
        require('luxline.config').setup({
            left_active_items = { 'bar_spec_alpha', 'bar_spec_beta' },
            right_active_items = {},
            left_separator = '>',
            right_separator = '<',
        })
        fixture_theme()
        local bar_builder = require('luxline.rendering.bar_builder')
        local ctx = require('luxline.core.context').get_current_context()
        ctx.active = true
        local rendered = bar_builder.build_for_context(ctx, 'statusline')
        local expected = '%#LuxlineItemLeft1# A '
            .. '%#LuxlineSeparator_statusline_left_LuxlineItemLeft1_LuxlineItemLeft2#>'
            .. '%#LuxlineItemLeft2# B '
            .. '%#LuxlineSeparator_statusline_left_LuxlineItemLeft2_default#>'
            .. '%='
        assert.eq(rendered, expected)
    end)

    it('skips winbar rendering for disabled filetypes', function()
        require('luxline').setup({ git_enabled = false, winbar_disabled_filetypes = { 'spectype' } })
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_set_current_buf(buf)
        vim.api.nvim_set_option_value('filetype', 'spectype', { buf = buf })
        vim.api.nvim_set_option_value('winbar', '', { win = 0 })
        require('luxline.rendering.bar_builder').winbar.update_all()
        assert.eq(vim.api.nvim_get_option_value('winbar', { win = 0 }), '')
    end)

    it('exposes generated statusline and winbar sub-APIs without update_window', function()
        local bar_builder = require('luxline.rendering.bar_builder')
        for _, bar_type in ipairs({ 'statusline', 'winbar' }) do
            assert.truthy(bar_builder[bar_type].build_for_context)
            assert.truthy(bar_builder[bar_type].build_section)
            assert.truthy(bar_builder[bar_type].update_all)
            assert.truthy(bar_builder[bar_type].preview)
            assert.eq(bar_builder[bar_type].update_window, nil, 'single-window public surface is removed')
        end
        assert.eq(bar_builder.update_window, nil)
    end)

    it('drops empty items and keeps rendered positions sequential', function()
        require('luxline').setup({ git_enabled = false })
        local items = require('luxline.items')
        items.register('bar_spec_empty', function() return '' end, {})
        items.register('bar_spec_solid', function() return 'S' end, {})
        require('luxline.config').setup({
            left_active_items = { 'bar_spec_empty', 'bar_spec_solid' },
            right_active_items = {},
            left_separator = '',
        })
        fixture_theme()
        local bar_builder = require('luxline.rendering.bar_builder')
        local ctx = require('luxline.core.context').get_current_context()
        ctx.active = true
        local rendered = bar_builder.build_for_context(ctx, 'statusline')
        assert.eq(rendered, '%#LuxlineItemLeft1# S %=', 'empty item dropped; solid item takes rendered position 1')
    end)
end)
