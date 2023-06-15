---@class Onemap
local onemap = {}

local config = require 'onemap.config'
local groups = require 'onemap.groups'
local register = require 'onemap.register'
local mapping = require 'onemap.mapping'

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

    for _, group in pairs(config.groups) do
        groups.create_group(group)
    end

    for _, group in pairs(config.buffer_local_groups) do
        if not groups[group] then
            error('Trying to set group ' .. group .. ' as buffer local failed since the group does not exist')
        end

        groups[group].buffer_local = true
    end

    has_setup = true
end

onemap.register = register.register
onemap.toggle = mapping.toggle
onemap.create_group = groups.create_group

return onemap
