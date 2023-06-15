---@class Group
---@field enabled boolean
---@field buffer_local boolean
---@field attached_maps table<number, Map>

local groups = {}

--- Creates a new group.
---@param group_name string
function groups.create_group(group_name)
    ---@type Group
    local new_group = { enabled = false, attached_maps = {} }

    if groups[group_name] then
        error("group \"" .. group_name .. "\" already exists")
    end

    groups[group_name] = new_group
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
