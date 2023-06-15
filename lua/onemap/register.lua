local mapping        = require 'onemap.mapping'
local groups         = require 'onemap.groups'
local config         = require 'onemap.config'
local run_once       = false
local buffer_local   = groups.buffer_local

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

---Registers a single key with the system
---@param lhs LHS
---@param keymap Map
local function individual_register(lhs, keymap)
    validate_modes(keymap.modes)

    ---@type GroupMap
    local saved = mapping.maps[lhs]
    local group_key = groups.generate_group_key(current_groups)

    local new_is_groupless = current_groups[1] == nil

    if saved then
        local old_is_groupless = saved[1] == nil

        if new_is_groupless and old_is_groupless then
            error("mapping conflict - duplicate entry (mapping = " .. lhs .. ")")
        end

        if new_is_groupless or old_is_groupless then
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
        groups[value].attached_maps[#groups[value].attached_maps+1] = keymap
    end

    if new_is_groupless then
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
---@param new_mappings table
---@param buffer_only boolean
local function register_recur(active_lhs, new_mappings, buffer_only)
    for key, value in pairs(new_mappings) do
        if type(value) ~= "table" then error("register function has invalid value" .. debug_kv(key, value)) end

        local parsed_keymap = mapping.parse_keymap(value, buffer_only)

        if parsed_keymap then
            if type(key) == "string" then
                individual_register(active_lhs .. key, parsed_keymap)
            else
                individual_register(active_lhs, parsed_keymap)
            end
        elseif type(key) == "string" then
            if string.sub(key, 1, #config.group_prefix) == config.group_prefix then
                local group_name = string.sub(key, #config.group_prefix + 1)

                if not groups[group_name] then
                    error("group \"" .. group_name .. "\" does not exist, ")
                end

                for _, grp in ipairs(current_groups) do
                    if group_name == grp then
                        error("register function called with nested group, " .. debug_kv(group_name, value))
                    end
                end

                current_groups[#current_groups + 1] = group_name
                register_recur(active_lhs, value, buffer_only or key == buffer_local)
                current_groups[#current_groups] = nil
            else
                register_recur(active_lhs .. key, value, buffer_only)
            end
        else
            vim.notify(type(key))
            vim.notify(key.name)
            error("register function has invalid key" .. debug_kv(key, value))
        end
    end
end

---Register new keymappings.
---
---Errors on repeated keymap
---@param new_mappings any
function M.register(new_mappings)
    if run_once then error('You may only register once. define everything in one spot, that\'s the point') end
    register_recur('', new_mappings, false)
    run_once = true
end

return M
