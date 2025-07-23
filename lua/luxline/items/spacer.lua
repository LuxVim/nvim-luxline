local items = require('luxline.items')

items.register('spacer', function(variant, context)
    return '%='
end, {
    description = "Flexible space separator",
    category = "layout"
})