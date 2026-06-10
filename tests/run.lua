local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
local spec_files = vim.fn.glob(root .. '/tests/spec/*_spec.lua', false, true)
table.sort(spec_files)

local results = { passed = 0, failed = 0, failures = {} }

local function clear_luxline_modules()
    for name in pairs(package.loaded) do
        if name == 'luxline' or name:match('^luxline%.') then
            package.loaded[name] = nil
        end
    end
end

_G.describe = function(name, body)
    _G.__current_group = name
    body()
end

_G.it = function(name, body)
    local label = (_G.__current_group or '?') .. ' :: ' .. name
    local ok, err = pcall(body)
    if ok then
        results.passed = results.passed + 1
        print('PASS  ' .. label)
    else
        results.failed = results.failed + 1
        table.insert(results.failures, { label = label, err = err })
        print('FAIL  ' .. label)
    end
end

for _, file in ipairs(spec_files) do
    _G.__current_group = nil
    clear_luxline_modules()
    local ok, err = pcall(dofile, file)
    if not ok then
        results.failed = results.failed + 1
        table.insert(results.failures, { label = file, err = err })
        print('ERROR ' .. file)
    end
end

print(string.format('\n%d passed, %d failed', results.passed, results.failed))
for _, failure in ipairs(results.failures) do
    print(string.format('\n--- %s\n%s', failure.label, tostring(failure.err)))
end

if results.failed > 0 then
    os.exit(1)
end
