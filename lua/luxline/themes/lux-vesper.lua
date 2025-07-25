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
    middle = '#1a1a2e',
    
    -- Semantic highlight groups for items
    semantic = {
        -- File-related items
        LuxlineFilename = { fg = '#e0e7ff', bg = '#7c3aed' },
        LuxlineWinbarFilename = { fg = '#e0e7ff', bg = '#6d28d9' },
        LuxlineModified = { fg = '#fbbf24', bg = '#dc2626', bold = true },
        LuxlineWinbarModified = { fg = '#fbbf24', bg = '#b91c1c', bold = true },
        
        -- Git-related items
        LuxlineGit = { fg = '#22c55e', bg = '#4a3674' },
        LuxlineWinbarGit = { fg = '#22c55e', bg = '#3c2e60' },
        
        -- Position-related items
        LuxlinePosition = { fg = '#e0e7ff', bg = '#8b5cf6' },
        LuxlineWinbarPosition = { fg = '#e0e7ff', bg = '#7c3aed' },
        LuxlinePercent = { fg = '#e0e7ff', bg = '#a855f7' },
        LuxlineWinbarPercent = { fg = '#e0e7ff', bg = '#9333ea' },
        
        -- Window number
        LuxlineWindownumber = { fg = '#fbbf24', bg = '#4a3674', bold = true },
        LuxlineWinbarWindownumber = { fg = '#fbbf24', bg = '#3c2e60', bold = true },
        
        -- Spacer (usually invisible)
        LuxlineSpacer = { fg = '#1a1a2e', bg = '#1a1a2e' },
        LuxlineWinbarSpacer = { fg = '#1a1a2e', bg = '#1a1a2e' },
    }
})