local themes = require('luxline.themes')

themes.register('lux-chroma', {
    foreground = '#1a1a1a',
    fallback = '#20b2aa',
    gradient = {
        '#fdfbf3',  -- lightest background
        '#faf7ed',  -- slightly darker
        '#f4f0e1',  -- selection shade
        '#fffdd0',  -- coconut white
        '#20b2aa',  -- tropical teal
        '#ff8c42',  -- mango orange
        '#ff69b4',  -- sunset pink
    },
    middle = '#faf7ed'
})