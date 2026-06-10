local base = require('luxline.items.base')
local definition = require('luxline.items.definition')

base.create_file_path_item('filename', {
    description = 'Current file name',
})

definition.define('filetype', {
    description = 'File type',
    category = 'file',
    get = function(ctx)
        return ctx and ctx.filetype or vim.bo.filetype
    end,
    variants = {
        icon = function(ft)
            local devicons_ok, devicons = pcall(require, 'nvim-web-devicons')
            if devicons_ok then
                local icon = devicons.get_icon_by_filetype(ft)
                return icon and (icon .. ' ' .. ft) or ft
            end
            return ft
        end,
    },
    format = function(ft)
        return ft ~= '' and ft or '[no ft]'
    end,
})

definition.define('cwd', {
    description = 'Current working directory',
    category = 'file',
    cache = true,
    cache_ttl = 5000,
    get = function(ctx)
        return ctx and ctx.cwd or vim.fn.getcwd()
    end,
    variants = {
        full = function(cwd) return cwd end,
        short = function(cwd) return vim.fn.pathshorten(cwd) end,
    },
    format = function(cwd)
        return vim.fn.fnamemodify(cwd, ':t')
    end,
})