local definition = require('luxline.items.definition')

definition.define('spacer', {
    description = 'Flexible space separator',
    category = 'layout',
    get = function() return '%=' end,
})