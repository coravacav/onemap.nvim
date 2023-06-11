local mapping        = require 'onemap.mapping'
local groups         = require 'onemap.groups'
local config         = require 'onemap.config'

---@class Register
local M              = {}

local current_groups = {}

---Ensure that mode is welformed
---@param modes string | table
---@return table
local function validate_modes(modes)
    if type(modes) == "string" then
        return { modes }
    elseif type(modes) == "table" then
        return modes
    else
        error("modes must be either string or table, got " .. vim.inspect(modes))
    end
end

local function share_modes(old_modes, new_modes)
    for _, value in pairs(new_modes) do
        if old_modes[value] then
            return true
        end
    end

    return false
end

local function is_groupless(grps)
    return grps[1] == nil
end

---Registers a single key with the system
---@param lhs LHS
---@param keymap Map
local function individual_register(lhs, keymap)
    validate_modes(keymap.modes)

    ---@type GroupMap
    local saved = mapping.maps[lhs]
    local group_key = groups.generate_group_key(current_groups)

    if saved then
        if is_groupless(current_groups) or is_groupless(saved) then
            error("mapping confict - cannot have both groupless and group (mapping = " .. lhs .. ")")
        end

        if saved[group_key] then
            error("mapping conflict - two bindings have the same groups defined in different orders (mapping = " ..
                lhs .. ")")
        end
    else
        saved = {}
        mapping.maps[lhs] = saved
    end

    keymap.lhs = lhs

    keymap.groups = {}

    for _, value in ipairs(current_groups) do
        keymap.groups[# keymap.groups + 1] = value
    end

    if is_groupless(current_groups) then
        saved[1] = keymap
        keymap.register_key()
    else
        saved[group_key] = keymap
    end
end

local function debug_kv(key, value)
    return "(key = `" .. vim.inspect(key) .. "` value = `" .. vim.inspect(value) .. "`)"
end

---Recursively adds registers / groupings
---@param active_lhs string
---@param active_groups table
---@param new_mappings table
local function register_recur(active_lhs, active_groups, new_mappings)
    for key, value in pairs(new_mappings) do
        if type(value) ~= "table" then error("register function has invalid value" .. debug_kv(key, value)) end
        if type(key) == "string" then active_lhs = active_lhs .. key end

        local parsed_keymap = mapping.parse_keymap(value)

        if parsed_keymap then
            individual_register(active_lhs, parsed_keymap)
        elseif type(key) == "string" then
            register_recur(active_lhs, active_groups, value)
        elseif type(key) == "table" and groups[key] then
            for _, grp in ipairs(active_groups) do
                if key == grp then
                    error("register function called with nested group, " .. debug_kv(key.group_name, value))
                end
            end

            active_groups[#active_groups + 1] = key
            register_recur(active_lhs, active_groups, value)
            active_groups[#active_groups] = nil
        else
            error("register function has invalid key" .. debug_kv(key, value))
        end
    end
end

---Register new keymappings.
---
---Errors on repeated keymap
---@param new_mappings any
function M.register(new_mappings)
    register_recur('', current_groups, new_mappings)
end

return M
