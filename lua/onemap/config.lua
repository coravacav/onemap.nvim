---@alias Update {lhs: string, buffer_local: boolean}

---@class Config
local config = {
    ---@type string
    prefix = '',
    ---@type table<number, string>
    groups = {},
    ---@type table<number, string>
    buffer_local_groups = {},
    ---@type string
    group_prefix = '__',
    ---@type string
    extra_info_prefix = 'extra_',
    ---@param update_obj Update
    on_register = function(update_obj) end,
    ---@param update_obj Update
    on_unregister = function(update_obj) end,
    ---@param context {current_path: string, key: string, value: any}
    on_extra_info = function(context) end,
}

return config
