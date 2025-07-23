local M = {}

local utils = require('luxline.core.utils')
local events = require('luxline.core.events')
local defaults_mod = require('luxline.config.defaults')
local validation = require('luxline.config.validation')

local defaults = defaults_mod.defaults
local config = {}

function M.setup(opts)
    opts = opts or {}
    
    validation.validate_config(opts)
    
    config = utils.deep_merge(vim.deepcopy(defaults), opts)
    
    events.emit('config_updated', { config = config })
end

function M.get()
    return config
end

function M.get_items(side, status, filetype, bar_type, buftype)
    local key = side .. '_' .. status .. '_items'
    
    if bar_type and bar_type ~= 'statusline' then
        key = key .. '_' .. bar_type
    end
    
    -- Check buftype first (higher priority for winbar)
    if buftype and buftype ~= '' then
        local buftype_key = key .. '_buftype_' .. buftype
        if config[buftype_key] then
            return vim.deepcopy(config[buftype_key])
        end
    end
    
    -- Then check filetype
    if filetype then
        local filetype_key = key .. '_' .. filetype
        if config[filetype_key] then
            return vim.deepcopy(config[filetype_key])
        end
    end
    
    return vim.deepcopy(config[key] or defaults[key])
end

function M.get_separator(side, bar_type)
    local key = side .. '_separator'
    
    -- Check for winbar-specific separator first
    if bar_type == 'winbar' then
        local winbar_key = 'winbar_' .. key
        local winbar_separator = config[winbar_key] or defaults[winbar_key]
        if winbar_separator ~= nil then
            return winbar_separator
        end
    end
    
    -- Fall back to statusline separator
    return config[key] or defaults[key]
end

function M.update_item_config(side, status, items_list, filetype)
    local key = side .. '_' .. status .. '_items'
    if filetype then
        key = key .. '_' .. filetype
    end
    
    config[key] = items_list
    events.emit('config_items_updated', { 
        key = key, 
        items = items_list 
    })
end

function M.reset_to_defaults()
    config = vim.deepcopy(defaults)
    events.emit('config_reset')
end

function M.get_defaults()
    return defaults_mod.get_defaults()
end

function M.export()
    return vim.deepcopy(config)
end

return M