local themes = require('luxline.themes')

themes.register('aurora', {
    foreground = '#1a1a1a',
    fallback = '#00bfa5',
    
    -- Light theme gradient from light blues to vibrant aurora colors
    itemLeft1 = '#f2f8f9',  -- lightest background
    itemLeft2 = '#ecf4f6',  -- slightly darker
    itemLeft3 = '#e0ecef',  -- selection shade
    itemLeft4 = '#b3e5fc',  -- ice crystal
    itemLeft5 = '#00bfa5',  -- aurora teal
    itemLeft6 = '#00e5ff',  -- aurora cyan
    itemLeft7 = '#7c4dff',  -- aurora purple
    
    -- Right side similar gradient
    itemRight1 = '#f2f8f9',
    itemRight2 = '#ecf4f6',
    itemRight3 = '#e0ecef',
    itemRight4 = '#b3e5fc',
    itemRight5 = '#00bfa5',
    itemRight6 = '#00e5ff',
    itemRight7 = '#7c4dff',
    
    middle = '#ecf4f6'
})