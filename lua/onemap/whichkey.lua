local success, wk = pcall(require, 'which-key')

if not success then
    return {
        on_extra_info = function() end,
        on_unregister = function() end,
    }
end

local maps = require 'onemap.mapping_data'.maps
local M    = {}

function M.register(lhs, desc)
    wk.register({ [lhs] = { name = desc } })
end

function M.unregister(lhs)
    pcall(wk.register, { [lhs] = "which_key_ignore" })
end

---@type OnExtraInfo
function M.on_extra_info(context)
    local current_path = context.current_path
    local key = context.key
    local value = context.value
    local event = context.event

    if key ~= 'wk_name' then return end

    if event == 'enabled' then
        M.register(current_path, value)
    elseif event == 'disabled' then
        for k, v in pairs(maps) do
            if k:sub(1, #current_path) == current_path then
                for _, gk in pairs(v) do
                    if gk.enabled then
                        return
                    end
                end
            end
        end

        M.unregister(current_path)
    end
end

function M.on_unregister(context)
    M.unregister(context.lhs)
end

return M
