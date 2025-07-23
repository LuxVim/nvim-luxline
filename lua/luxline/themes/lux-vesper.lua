local themes = require('luxline.themes')

themes.register('lux-vesper', {
    foreground = '#e0e7ff',
    fallback = '#4a3674',
    gradient = {
        '#0f0f23',  -- darkest background
        '#1a1a2e',  -- slightly lighter
        '#2A305E',  -- border/accent
        '#4a3674',  -- 50% purple
        '#7c3aed',  -- grape
        '#8b5cf6',  -- indigo
        '#a855f7',  -- vibrant purple
    },
    middle = '#1a1a2e'
})