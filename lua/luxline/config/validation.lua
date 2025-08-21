local M = {}
local schema = require('luxline.config.schema')

function M.validate_config(user_config)
    local errors = schema.validate_all_config(user_config)
    
    if #errors > 0 then
        error('Luxline configuration errors:\n' .. table.concat(errors, '\n'))
    end
    
    return true
end

return M