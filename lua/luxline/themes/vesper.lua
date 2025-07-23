local themes = require('luxline.themes')

themes.register('vesper', {
    foreground = '#e0e7ff',
    fallback = '#4a3674',
    
    -- Left side gradient from dark purple to brighter purple
    itemLeft1 = '#0f0f23',  -- darkest background
    itemLeft2 = '#1a1a2e',  -- slightly lighter
    itemLeft3 = '#2A305E',  -- border/accent
    itemLeft4 = '#4a3674',  -- 50% purple
    itemLeft5 = '#7c3aed',  -- grape
    itemLeft6 = '#8b5cf6',  -- indigo
    itemLeft7 = '#a855f7',  -- vibrant purple
    
    -- Right side similar gradient
    itemRight1 = '#0f0f23',
    itemRight2 = '#1a1a2e',
    itemRight3 = '#2A305E',
    itemRight4 = '#4a3674',
    itemRight5 = '#7c3aed',
    itemRight6 = '#8b5cf6',
    itemRight7 = '#a855f7',
    
    middle = '#1a1a2e'
})