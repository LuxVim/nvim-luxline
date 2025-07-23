local themes = require('luxline.themes')

themes.register('lux-eos', {
    foreground = '#1a1a1a',
    fallback = '#ff8e53',
    gradient = {
        '#fef4f1',  -- lightest background
        '#fdefeb',  -- slightly darker
        '#fbe4df',  -- selection shade
        '#ffab91',  -- coral peach
        '#ff8e53',  -- coral orange
        '#26d0ce',  -- reef turquoise
        '#ff6b6b',  -- coral red
    },
    middle = '#fdefeb'
})