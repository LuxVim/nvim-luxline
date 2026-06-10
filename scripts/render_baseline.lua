local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.runtimepath:prepend(root)

local mode = (_G.arg and _G.arg[1]) or 'capture'

require('luxline').setup({ git_enabled = false })
vim.cmd('edit ' .. root .. '/README.md')
require('luxline').update()

local bar_builder = require('luxline.rendering.bar_builder')
local lines = {
    'statusline:' .. bar_builder.statusline.preview(),
    'winbar:' .. bar_builder.winbar.preview(),
}

local baseline_path = root .. '/tests/baseline/rendered.txt'
if mode == 'capture' then
    vim.fn.mkdir(root .. '/tests/baseline', 'p')
    vim.fn.writefile(lines, baseline_path)
    print('baseline captured to ' .. baseline_path)
else
    local expected = vim.fn.readfile(baseline_path)
    if not vim.deep_equal(expected, lines) then
        print('BASELINE MISMATCH')
        print('expected:')
        print(table.concat(expected, '\n'))
        print('actual:')
        print(table.concat(lines, '\n'))
        os.exit(1)
    end
    print('baseline match')
end
