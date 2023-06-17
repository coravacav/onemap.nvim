---@alias OnRegister function(context: { lhs: string, buffer_local: boolean })
---@alias OnUnregister function(context: { lhs: string, buffer_local: boolean })
---@alias OnExtraInfoEvent string 'registered' | 'enabled' | 'disabled'
---@alias OnExtraInfo function(context: { current_path: string, key: string, value: any, buffer_local: boolean, event: OnExtraInfoEvent })


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
    ---@type OnRegister
    on_register = function(context) end,
    ---@type OnUnregister
    on_unregister = function(context) end,
    ---@type OnExtraInfo
    on_extra_info = function(context) end,
    ---@type 'off' | 'warn' | 'error'
    notify_on_possible_conflict = 'off',
    ---@type boolean
    whichkey_integration = false,
}

return config
