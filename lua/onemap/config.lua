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
    ---@param update_obj { lhs: string, buffer_local: boolean }
    on_register = function(update_obj) end,
    ---@param update_obj { lhs: string, buffer_local: boolean }
    on_unregister = function(update_obj) end,
    ---@param context { current_path: string, key: string, value: any, buffer_local: boolean }
    on_extra_info = function(context) end,
    ---@type 'off' | 'warn' | 'error'
    notify_on_possible_conflict = 'off',
}

return config
