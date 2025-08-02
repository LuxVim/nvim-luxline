local items = require('luxline.items')

items.register('mode', function(variant, context)
    local mode = vim.fn.mode()
    local mode_map = {
        ['n'] = 'NORMAL',
        ['no'] = 'N-OPERATOR',
        ['nov'] = 'N-OPERATOR',
        ['noV'] = 'N-OPERATOR',
        ['no\22'] = 'N-OPERATOR',
        ['niI'] = 'N-INSERT',
        ['niR'] = 'N-REPLACE', 
        ['niV'] = 'N-VIRTUAL',
        ['nt'] = 'TERMINAL',
        ['v'] = 'VISUAL',
        ['vs'] = 'V-SELECT',
        ['V'] = 'V-LINE',
        ['Vs'] = 'V-LINE-S',
        ['\22'] = 'V-BLOCK',
        ['\22s'] = 'V-BLOCK-S',
        ['s'] = 'SELECT',
        ['S'] = 'S-LINE',
        ['\19'] = 'S-BLOCK',
        ['i'] = 'INSERT',
        ['ic'] = 'INSERT',
        ['ix'] = 'INSERT',
        ['R'] = 'REPLACE',
        ['Rc'] = 'REPLACE',
        ['Rx'] = 'REPLACE',
        ['Rv'] = 'V-REPLACE',
        ['Rvc'] = 'V-REPLACE',
        ['Rvx'] = 'V-REPLACE',
        ['c'] = 'COMMAND',
        ['cv'] = 'VIM EX',
        ['ce'] = 'EX',
        ['r'] = 'PROMPT',
        ['rm'] = 'MORE',
        ['r?'] = 'CONFIRM',
        ['!'] = 'SHELL',
        ['t'] = 'TERMINAL'
    }
    
    local mode_name = mode_map[mode] or mode:upper()
    
    if variant == 'short' then
        local short_map = {
            ['NORMAL'] = 'N',
            ['INSERT'] = 'I',
            ['VISUAL'] = 'V',
            ['V-LINE'] = 'VL',
            ['V-BLOCK'] = 'VB',
            ['REPLACE'] = 'R',
            ['V-REPLACE'] = 'VR',
            ['COMMAND'] = 'C',
            ['TERMINAL'] = 'T'
        }
        return short_map[mode_name] or mode_name:sub(1, 1)
    elseif variant == 'icon' then
        local icon_map = {
            ['NORMAL'] = '󰀘',
            ['INSERT'] = '󰏪',
            ['VISUAL'] = '󰒉',
            ['V-LINE'] = '󰒉',
            ['V-BLOCK'] = '󰒉',
            ['REPLACE'] = '󰛔',
            ['V-REPLACE'] = '󰛔',
            ['COMMAND'] = '󰘳',
            ['TERMINAL'] = '󰆍'
        }
        local icon = icon_map[mode_name] or '󰀘'
        return icon .. ' ' .. mode_name
    else
        return mode_name
    end
end, {
    description = "Current Neovim mode",
    category = "editor",
    variants = { 'short', 'icon' }
})