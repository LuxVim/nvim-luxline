local base = require('luxline.items.base')

base.create_buffer_option_item('modified', 'modified', {
    description = "File modification indicator",
    category = "file",
    variants = {
        icon = function(modified) return modified and '●' or '' end,
        short = function(modified) return modified and '[+]' or '' end
    },
    default_format = function(modified) return modified and '[Modified]' or '' end
})