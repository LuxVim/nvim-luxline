local themes = require('luxline.themes')

themes.register('lux-chroma', {
    foreground = '#1a1a1a',
    fallback = '#20b2aa',
    
    -- Light tropical theme gradient
    itemLeft1 = '#fdfbf3',  -- lightest background
    itemLeft2 = '#faf7ed',  -- slightly darker
    itemLeft3 = '#f4f0e1',  -- selection shade
    itemLeft4 = '#fffdd0',  -- coconut white
    itemLeft5 = '#20b2aa',  -- tropical teal
    itemLeft6 = '#ff8c42',  -- mango orange
    itemLeft7 = '#ff69b4',  -- sunset pink
    
    -- Right side similar gradient
    itemRight1 = '#fdfbf3',
    itemRight2 = '#faf7ed',
    itemRight3 = '#f4f0e1',
    itemRight4 = '#fffdd0',
    itemRight5 = '#20b2aa',
    itemRight6 = '#ff8c42',
    itemRight7 = '#ff69b4',
    
    middle = '#faf7ed'
})