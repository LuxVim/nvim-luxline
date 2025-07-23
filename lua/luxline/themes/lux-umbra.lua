local themes = require('luxline.themes')

themes.register('lux-umbra', {
    foreground = '#f4edff',
    fallback = '#5b3094',
    gradient = {
        '#0a0310',  -- darkest background
        '#180c24',  -- slightly lighter
        '#2c1a42',  -- selection shade
        '#5b3094',  -- 50% purple
        '#6b60e3',  -- imperial purple
        '#c471ed',  -- glam magenta
        '#d776dd',  -- orchid purple
    },
    middle = '#180c24'
})