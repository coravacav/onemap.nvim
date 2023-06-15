---@alias Update {lhs: string, buffer_only: boolean, changed_group: string}

---@class Config
local config = {
    ---@type table<number, string>
    groups = {},
    ---@type table<number, string>
    buffer_local_groups = {},
    ---@type string
    group_prefix = '__',
    ---@param update Update
    on_register = function(update) end,
    ---@param update Update
    on_deregister = function(update) end,
}

return config
