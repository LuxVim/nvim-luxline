-- LUX theme definitions
-- Extracted from themes/init.lua for better maintainability

return {
    ['lux-vesper'] = {
        foreground = '#e0e7ff',
        fallback = '#4a3674',
        gradient = {
            '#0f0f23', '#1a1a2e', '#2A305E', '#4a3674',
            '#7c3aed', '#8b5cf6', '#a855f7'
        },
        middle = '#1a1a2e',
        semantic = {
            LuxlineFilename = { fg = '#e0e7ff', bg = '#7c3aed' },
            LuxlineWinbarFilename = { fg = '#e0e7ff', bg = '#6d28d9' },
            LuxlineModified = { fg = '#fbbf24', bg = '#dc2626', bold = true },
            LuxlineWinbarModified = { fg = '#fbbf24', bg = '#b91c1c', bold = true },
            LuxlineGit = { fg = '#22c55e', bg = '#4a3674' },
            LuxlineWinbarGit = { fg = '#22c55e', bg = '#3c2e60' },
            LuxlinePosition = { fg = '#e0e7ff', bg = '#8b5cf6' },
            LuxlineWinbarPosition = { fg = '#e0e7ff', bg = '#7c3aed' },
            LuxlinePercent = { fg = '#e0e7ff', bg = '#a855f7' },
            LuxlineWinbarPercent = { fg = '#e0e7ff', bg = '#9333ea' },
            LuxlineWindownumber = { fg = '#fbbf24', bg = '#4a3674', bold = true },
            LuxlineWinbarWindownumber = { fg = '#fbbf24', bg = '#3c2e60', bold = true },
            LuxlineSpacer = { fg = '#1a1a2e', bg = '#1a1a2e' },
            LuxlineWinbarSpacer = { fg = '#1a1a2e', bg = '#1a1a2e' }
        }
    },
    ['lux-aurora'] = {
        foreground = '#1a1a1a',
        fallback = '#00bfa5',
        gradient = {
            '#f2f8f9', '#ecf4f6', '#e0ecef', '#b3e5fc',
            '#00bfa5', '#00e5ff', '#7c4dff'
        },
        middle = '#ecf4f6'
    },
    ['lux-chroma'] = {
        foreground = '#1a1a1a',
        fallback = '#20b2aa',
        gradient = {
            '#fdfbf3', '#faf7ed', '#f4f0e1', '#fffdd0',
            '#20b2aa', '#ff8c42', '#ff69b4'
        },
        middle = '#faf7ed'
    },
    ['lux-eos'] = {
        foreground = '#1a1a1a',
        fallback = '#ff8e53',
        gradient = {
            '#fef4f1', '#fdefeb', '#fbe4df', '#ffab91',
            '#ff8e53', '#26d0ce', '#ff6b6b'
        },
        middle = '#fdefeb'
    },
    ['lux-umbra'] = {
        foreground = '#f4edff',
        fallback = '#5b3094',
        gradient = {
            '#0a0310', '#180c24', '#2c1a42', '#5b3094',
            '#6b60e3', '#c471ed', '#d776dd'
        },
        middle = '#180c24'
    }
}