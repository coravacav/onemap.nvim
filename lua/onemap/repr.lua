---@class Repr
local M = {}

function M.repr_call_func(func_name, func)
    return function(...)
        local success, result = pcall(func, ...)

        if not success then
            local params = ''

            for _, value in ipairs({ ... }) do
                params = params .. vim.inspect(value) .. ', '
            end

            params = string.gsub(params, ', $', '')

            error('call to `' .. func_name .. '(' .. params .. ')` resulted in an error, ' .. result)
        end

        return result
    end
end

M['vim.keymap.set'] = M.repr_call_func('vim.keymap.set', vim.keymap.set)
M['vim.keymap.del'] = M.repr_call_func('vim.keymap.del', vim.keymap.del)

return M
