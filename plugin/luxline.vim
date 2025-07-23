if exists('g:loaded_luxline')
    finish
endif
let g:loaded_luxline = 1

lua require('luxline').setup()