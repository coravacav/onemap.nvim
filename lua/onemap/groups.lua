---@class Group
---@field group_name string
---@field enabled boolean
---@field attached_maps table<number, Map>

local groups = {}

--- Creates a new group.
---@param group_name string
---@return Group
function groups.create_group(group_name)
    ---@type Group
    local new_group = { group_name = group_name, enabled = false, attached_maps = {} }

    if groups[group_name] then
        error("group \"" .. group_name .. "\" already exists")
    end

    groups[group_name] = new_group

    return new_group
end

function groups.find_group(group_name)
    return groups[group_name]
end

---Generates a table group key from a list of group names
---@param grps table<number, string>
function groups.generate_group_key(grps)
    local key = ''

    -- guarantees stable
    table.sort(grps)

    for _, value in pairs(grps) do
        key = key .. value
    end

    return key
end

groups.create_group("disabled")

return groups
