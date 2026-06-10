local definition = require('luxline.items.definition')

definition.define('position', {
    description = 'Cursor position (line:column)',
    category = 'cursor',
    get = function()
        return { line = vim.fn.line('.'), column = vim.fn.col('.') }
    end,
    variants = {
        line = function(pos) return tostring(pos.line) end,
        column = function(pos) return tostring(pos.column) end,
    },
    format = function(pos)
        return pos.line .. ':' .. pos.column
    end,
})