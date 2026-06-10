local M = {}

local events = require('luxline.core.events')
local defaults_mod = require('luxline.config.defaults')
local validation = require('luxline.config.validation')
local resolver = require('luxline.config.resolver')
local schema = require('luxline.config.schema')

local defaults = defaults_mod.defaults
local config = {}

function M.setup(opts)
    opts = opts or {}

    validation.validate_config(opts)

    config = vim.deepcopy(defaults)
    for key, value in pairs(opts) do
        config[key] = vim.deepcopy(value)
    end

    events.emit('config_updated', { config = config })
end

function M.get()
    return config
end

function M.get_items(side, status, filetype, bar_type, buftype)
    local base_key = schema.build_config_key({ side, status, 'items' })

    if bar_type and bar_type ~= 'statusline' then
        base_key = base_key .. '_' .. bar_type
    end

    local candidates = {}
    if buftype and buftype ~= '' then
        table.insert(candidates, base_key .. '_buftype_' .. buftype)
    end
    if filetype then
        table.insert(candidates, base_key .. '_' .. filetype)
    end
    table.insert(candidates, base_key)

    return vim.deepcopy((resolver.lookup(config, defaults, candidates)))
end

function M.get_separator(side, bar_type)
    local base_key = schema.build_config_key({ side, 'separator' })

    local candidates = {}
    if bar_type then
        table.insert(candidates, base_key .. '_' .. bar_type)
    end
    table.insert(candidates, base_key)

    return (resolver.lookup(config, defaults, candidates))
end

function M.reset_to_defaults()
    config = vim.deepcopy(defaults)
    events.emit('config_reset')
end

function M.export()
    return vim.deepcopy(config)
end

function M.is_winbar_disabled_for_filetype(filetype)
    return vim.tbl_contains(config.winbar_disabled_filetypes or {}, filetype)
end

return M
