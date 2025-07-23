local M = {}

function M.parse_diff_stats(data)
    if not data or data == '' then
        return ''
    end
    
    local parts = {}
    
    local files = data:match('(%d+) files? changed')
    if files then
        table.insert(parts, '~' .. files)
    end
    
    local insertions = data:match('(%d+) insertions?')
    if insertions then
        table.insert(parts, '+' .. insertions)
    end
    
    local deletions = data:match('(%d+) deletions?')
    if deletions then
        table.insert(parts, '-' .. deletions)
    end
    
    return table.concat(parts, ' ')
end

return M