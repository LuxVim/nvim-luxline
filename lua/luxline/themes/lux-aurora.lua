local themes = require('luxline.themes')

themes.register('lux-aurora', {
    foreground = '#1a1a1a',
    fallback = '#00bfa5',
    gradient = {
        '#f2f8f9',  -- lightest background
        '#ecf4f6',  -- slightly darker
        '#e0ecef',  -- selection shade
        '#b3e5fc',  -- ice crystal
        '#00bfa5',  -- aurora teal
        '#00e5ff',  -- aurora cyan
        '#7c4dff',  -- aurora purple
    },
    middle = '#ecf4f6'
})