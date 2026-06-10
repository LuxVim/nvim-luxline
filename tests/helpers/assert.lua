local M = {}

local function format_value(value)
    if type(value) == 'table' then
        return vim.inspect(value)
    end
    return tostring(value)
end

function M.eq(actual, expected, message)
    if not vim.deep_equal(actual, expected) then
        error(string.format('%s\nexpected: %s\nactual:   %s',
            message or 'values differ', format_value(expected), format_value(actual)), 2)
    end
end

function M.truthy(value, message)
    if not value then
        error(message or ('expected truthy, got ' .. tostring(value)), 2)
    end
end

function M.falsy(value, message)
    if value then
        error(message or ('expected falsy, got ' .. format_value(value)), 2)
    end
end

function M.matches(pattern, text, message)
    if type(text) ~= 'string' or not text:match(pattern) then
        error(string.format('%s\npattern: %s\ntext:    %s',
            message or 'pattern not matched', pattern, format_value(text)), 2)
    end
end

function M.errors(fn, message)
    local ok = pcall(fn)
    if ok then
        error(message or 'expected function to error', 2)
    end
end

return M
