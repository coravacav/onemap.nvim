---@class Group
---@field is_enabled function
---@field set_enabled function
---@field buffer_local boolean
---@field attached_maps table<number, Map>

local groups = {}

--- Creates a new group.
---@param group_name string
---@param buffer_local? boolean
function groups.create_group(group_name, buffer_local)
    ---@type Group
    local group = { attached_maps = {}, buffer_local = buffer_local or false }

    if groups[group_name] then
        error("group \"" .. group_name .. "\" already exists")
    end

    local buf_key = "onekey_group_enabled_" .. group_name

    local function get_right_buffer()
        if group.buffer_local then
            return vim.b
        else
            return vim.g
        end
    end

    function group.is_enabled()
        return get_right_buffer()[buf_key] or false
    end

    function group.set_enabled(state)
        get_right_buffer()[buf_key] = state
    end

    groups[group_name] = group
end

---Generates a table group key from a list of group names
---@param grps table<number, Group>
function groups.generate_group_key(grps)
    local key = ''

    -- guarantees stable
    table.sort(grps)

    for _, value in pairs(grps) do
        key = key .. value
    end

    return key
end

return groups
