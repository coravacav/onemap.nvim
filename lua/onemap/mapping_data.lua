---@class Map
---@field modes table
---@field rhs string | function
---@field lhs string
---@field groups table<number, string>
---@field enabled boolean
---@field opts table
---@field unregister_key function
---@field register_key function
---@field register_key_if_able function

---@alias LHS string lhs of a map
---@alias GroupStr string unique id for collection of groups
---@alias GroupMap table<GroupStr, Map> collection of maps based on group

---@type table<LHS, GroupMap>
local maps = {}

---@class CompleteMapping
local M = { maps = maps }

return M
