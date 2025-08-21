local base = require('luxline.items.base')

base.create_buffer_option_item('readonly', 'readonly', {
    description = "Read-only file indicator",
    category = "file",
    variants = {
        icon = function(readonly) return readonly and '' or '' end,
        short = function(readonly) return readonly and '[RO]' or '' end
    },
    default_format = function(readonly) return readonly and '[Readonly]' or '' end
})