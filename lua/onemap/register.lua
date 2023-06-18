local mapping        = require 'onemap.mapping'
local groups         = require 'onemap.groups'
local config         = require 'onemap.config'
local wki            = require 'onemap.whichkey'
local has            = require 'onemap.has'

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
        local old_is_groupless = saved[1] ~= nil

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

        if config.notify_on_possible_conflict == "warn" then
            vim.notify(
                "warning - map overwrite possible when enabling group `" ..
                current_groups[#current_groups] .. "` (mapping = " .. lhs .. ")", vim.log.levels.WARN)
        elseif config.notify_on_possible_conflict == "error" then
            error("map overwrite possible when enabling group `" ..
                current_groups[#current_groups] .. "` (mapping = " .. lhs .. ")")
        end
    else
        saved = {}
        mapping.maps[lhs] = saved
    end

    keymap.lhs = lhs

    keymap.groups = {}

    for _, value in ipairs(current_groups) do
        keymap.groups[#keymap.groups + 1] = value
        groups[value].attached_maps[#groups[value].attached_maps + 1] = keymap
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

local function starts_with(str, start)
    return str:sub(1, #start) == start
end

---Recursively adds registers / groupings
---@param current_lhs string
---@param new_mappings table
---@param buffer_local boolean
local function register_recur(current_lhs, new_mappings, buffer_local)
    for key, value in pairs(new_mappings) do
        local parsed_keymap = mapping.parse_keymap(value, buffer_local)

        if parsed_keymap then
            if type(key) == "string" then
                individual_register(current_lhs .. key, parsed_keymap)
            else
                individual_register(current_lhs, parsed_keymap)
            end
        elseif type(key) == "string" then
            if starts_with(key, config.extra_info_prefix) then
                local extra_info = {
                    current_path = current_lhs,
                    key = string.sub(key, #config.extra_info_prefix + 1),
                    value = value,
                    buffer_local = buffer_local,
                    event = 'registered',
                }

                local success, err = pcall(config.on_extra_info, extra_info)
                extra_info.event = nil

                local on_extra_info_ref = config.on_extra_info

                function extra_info.on_extra_info(event)
                    extra_info.event = event
                    success, err = pcall(on_extra_info_ref, extra_info)
                    extra_info.event = nil

                    if not success then
                        error("on_extra_info function failed with error: " .. err)
                    end
                end

                for _, grp_name in ipairs(current_groups) do
                    local grp = groups[grp_name]
                    grp.attached_extra_infos[#grp.attached_extra_infos + 1] = extra_info
                end

                if not success then
                    error("on_extra_info function failed with error: " .. err)
                end
            else
                if type(value) ~= "table" then error("register function has invalid value" .. debug_kv(key, value)) end

                if starts_with(key, config.group_prefix) then
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
                    local success, err = pcall(register_recur, current_lhs, value,
                        buffer_local or groups[group_name].buffer_local)
                    current_groups[#current_groups] = nil

                    if not success then
                        error(err)
                    end
                else
                    register_recur(current_lhs .. key, value, buffer_local)
                end
            end
        else
            error("register function has invalid key" .. debug_kv(key, value))
        end
    end
end

---Register new keymappings, object style
---
---Errors on repeated keymap
---@param new_mappings table
---@param opts? Config
function M.register(new_mappings, opts)
    if not has.setup then
        error("onemap.setup has not been done")
    end

    local cleanup = config.temporarily_extend(opts)
    local success, err = pcall(register_recur, config.prefix, new_mappings, false)
    cleanup()

    if not success then
        error(err)
    end
end

---Register new keymap, oneshot style
---
---@param lhs string
---@param rhs string | function
---@param desc? string
---@param group? string
---@param mapping_opts? table
---@param config_opts? table
function M.oneshot(lhs, rhs, desc, group, mapping_opts, config_opts)
    if not has.setup then
        error("onemap.setup has not been done")
    end

    local cleanup = config.temporarily_extend(config_opts)

    local register_arg = { [lhs] = { rhs, desc, opts = mapping_opts } }
    if group then
        register_arg = { [config.group_prefix .. group] = register_arg }
    end

    local success, err = pcall(register_recur, config.prefix, register_arg, false)

    cleanup()

    if not success then
        error(err)
    end
end

function M.create_oneshot(default_mapping_opts)
    return function(lhs, rhs, desc, group, mapping_opts, config_opts)
        local overriden_opts = {}

        for key, value in pairs(mapping_opts or {}) do
            overriden_opts[key] = default_mapping_opts[key]
            default_mapping_opts[key] = value
        end

        local success, err = pcall(M.oneshot, lhs, rhs, desc, group, default_mapping_opts, config_opts)

        for key, value in pairs(overriden_opts) do
            default_mapping_opts[key] = value
        end

        if not success then
            error(err)
        end
    end
end

return M
