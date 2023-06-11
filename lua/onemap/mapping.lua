local repr = require('onemap.repr')

---@class Map
---@field modes table
---@field rhs string | function
---@field lhs string
---@field groups table<number, Group>
---@field enabled boolean
---@field desc string
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


---Creates a template keymap
---@return Map
function M.create_keymap()
    ---@type Map
    local _key = {
        enabled = false,
        modes = {},
        groups = {},
    }

    function _key.register_key()
        if not _key.enabled then
            repr['vim.keymap.set'](_key.modes, _key.lhs, _key.rhs, { desc = _key.desc })
            _key.enabled = true
        end
    end

    function _key.register_key_if_able()
        local to_enable = false

        for _, grp in pairs(_key.groups) do
            to_enable = grp.enabled
            if not to_enable then break end
        end

        if to_enable then _key.register_key() end
    end

    function _key.unregister_key()
        if _key.enabled then
            repr['vim.keymap.del'](_key.modes, _key.lhs)
            _key.enabled = false
        end
    end

    return _key
end

---Toggles a group
---@param group Group
---@param state boolean
function M.toggle_group(group, state)
    group.enabled = state or not group.enabled

    for _, map in pairs(group.attached_maps) do
        if group.enabled then
            map.register_key_if_able()
        else
            map.unregister_key()
        end
    end
end

local legal_keys = { rhs = true, desc = true, modes = true, [1] = true, [2] = true }

---Checks if a table matches format
---@param tabl any
---@return Map | nil
function M.parse_keymap(tabl)
    for key, _ in pairs(tabl) do
        if not legal_keys[key] then return nil end
    end

    local rhs = tabl.rhs or tabl[1]
    local desc = tabl.desc or tabl[2]
    if not rhs then return nil end
    if not desc then return nil end

    local keymap = M.create_keymap()

    keymap.rhs = rhs
    keymap.desc = desc
    keymap.modes = tabl.modes or { 'n' }

    return keymap
end

return M
