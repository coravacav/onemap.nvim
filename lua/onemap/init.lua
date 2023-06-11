---@class Onemap
local onemap = {}

local config = require 'onemap.config'
local groups = require 'onemap.groups'
local register = require 'onemap.register'
local mapping = require 'onemap.mapping'

function onemap.setup(user_config)
    user_config = user_config or {}

    for option, value in pairs(user_config) do
        config[option] = value
    end
end

onemap.create_group = groups.create_group
onemap.find_group = groups.find_group
onemap.register = register.register
onemap.toggle_group = mapping.toggle_group

return onemap
