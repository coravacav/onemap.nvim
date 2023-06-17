---@class Onemap
local onemap = {}

local config = require 'onemap.config'
local groups = require 'onemap.groups'
local register = require 'onemap.register'
local mapping = require 'onemap.mapping'
local wki = require 'onemap.whichkey'

local has_setup = false

function onemap.setup(user_config)
    if has_setup then
        error('Onemap has already been setup')
    end

    user_config = user_config or {}

    for option, value in pairs(user_config) do
        config[option] = value
    end

    if config.group_prefix == config.extra_info_prefix then
        error('group_prefix and extra_info_prefix cannot be the same')
    end

    if config.whichkey_integration and user_config.on_extra_info then
        error('Cannot set whichkey_integration and on_extra_info at the same time, setup whichkey integration manually')
    end

    for _, group in pairs(config.groups) do
        groups.create_group(group, false)
    end

    for _, group in pairs(config.buffer_local_groups) do
        if not groups[group] then
            error('Trying to set group ' .. group .. ' as buffer local failed since the group does not exist')
        end

        groups[group].buffer_local = true
    end

    has_setup = true
end

function onemap.toggle_fn(group_name) function mapping.toggle(group_name) end end

onemap.register = register.register
onemap.toggle = mapping.toggle
onemap.create_group = groups.create_group
onemap.wki = {
    on_extra_info = wki.on_extra_info,
    on_unregister = wki.on_unregister,
}

return onemap
