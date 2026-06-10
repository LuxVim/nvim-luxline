local assert = dofile(vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h') .. '/helpers/assert.lua')

describe('rendering.highlight', function()
    it('creates one separator group per color pair, without winid in the name', function()
        require('luxline').setup({ git_enabled = false })
        local highlight = require('luxline.rendering.highlight')
        vim.api.nvim_set_hl(0, 'LuxSepSpecA', { bg = '#111111' })
        vim.api.nvim_set_hl(0, 'LuxSepSpecB', { bg = '#222222' })

        local formatted = highlight.separator_direct('>', 'left', 'LuxSepSpecA', 'LuxSepSpecB', 'statusline')
        local group = formatted:match('%%#([^#]+)#')
        assert.eq(group, 'LuxlineSeparator_statusline_left_LuxSepSpecA_LuxSepSpecB')

        local hl = vim.api.nvim_get_hl(0, { name = group })
        assert.eq(string.format('#%06x', hl.fg), '#111111', 'left separator fg = current item bg')
        assert.eq(string.format('#%06x', hl.bg), '#222222', 'left separator bg = next item bg')
    end)

    it('right-side separators swap the blend direction', function()
        local highlight = require('luxline.rendering.highlight')
        vim.api.nvim_set_hl(0, 'LuxSepSpecC', { bg = '#333333' })
        vim.api.nvim_set_hl(0, 'LuxSepSpecD', { bg = '#444444' })
        local formatted = highlight.separator_direct('<', 'right', 'LuxSepSpecC', 'LuxSepSpecD', 'statusline')
        local group = formatted:match('%%#([^#]+)#')
        local hl = vim.api.nvim_get_hl(0, { name = group })
        assert.eq(string.format('#%06x', hl.fg), '#444444', 'right separator fg = next item bg')
        assert.eq(string.format('#%06x', hl.bg), '#333333', 'right separator bg = current item bg')
    end)

    it('falls back to the default separator bg for missing groups', function()
        local highlight = require('luxline.rendering.highlight')
        local formatted = highlight.separator_direct('>', 'left', nil, nil, 'statusline')
        local group = formatted:match('%%#([^#]+)#')
        local hl = vim.api.nvim_get_hl(0, { name = group })
        assert.eq(string.format('#%06x', hl.fg), '#1a1b26')
        assert.eq(string.format('#%06x', hl.bg), '#1a1b26')
    end)

    it('returns empty string for an empty separator', function()
        local highlight = require('luxline.rendering.highlight')
        assert.eq(highlight.separator_direct('', 'left', 'A', 'B', 'statusline'), '')
        assert.eq(highlight.separator_direct(nil, 'left', 'A', 'B', 'statusline'), '')
    end)

    it('removes the dead highlight surface', function()
        local highlight = require('luxline.rendering.highlight')
        assert.eq(highlight.get_highlight_value, nil)
        assert.eq(highlight.get_item_highlight_group, nil)
        assert.eq(highlight.get_item_highlight_group_name, nil)
        assert.eq(highlight.create_highlight, nil)
        assert.eq(highlight.refresh_all, nil)
        assert.eq(highlight.store_item_highlight_mapping, nil)
        assert.eq(highlight.adjust_color, nil)
    end)

    it('selects semantic strategy when the theme defines the group, positional otherwise', function()
        local strategies = require('luxline.rendering.highlight_strategies')
        local themes = require('luxline.themes')
        themes.register('hl-spec-theme', {
            gradient = {
                { bg = '#101010', fg = '#ffffff' }, { bg = '#202020', fg = '#ffffff' },
                { bg = '#303030', fg = '#ffffff' }, { bg = '#404040', fg = '#ffffff' },
                { bg = '#505050', fg = '#ffffff' }, { bg = '#606060', fg = '#ffffff' },
                { bg = '#707070', fg = '#ffffff' },
            },
            middle = '#202020',
            semantic = { LuxlineFilename = { bg = '#aabbcc', fg = '#000000' } },
        })
        themes.set_theme('hl-spec-theme')
        local strategy, group = strategies.get_highlight_strategy('filename', 'left', 1, 'statusline')
        assert.eq(strategy, 'semantic')
        assert.eq(group, 'LuxlineFilename')
        strategy, group = strategies.get_highlight_strategy('position', 'left', 2, 'statusline')
        assert.eq(strategy, 'positional')
        assert.eq(group, 'LuxlineItemLeft2')
    end)
end)
