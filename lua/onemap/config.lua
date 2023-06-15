---@alias Update {lhs: string, buffer_local: boolean}

---@class Config
local config = {
    ---@type table<number, string>
    groups = {},
    ---@type table<number, string>
    buffer_local_groups = {},
    ---@type string
    group_prefix = '__',
    ---@param update_obj Update
    on_register = function(update_obj) end,
    ---@param update_obj Update
    on_unregister = function(update_obj) end,
}

return config
