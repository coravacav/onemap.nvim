local onemap = require 'onemap.init'

onemap.setup {
    groups = { 'test' }
}

onemap.register {
    ['<leader>mm'] = { function() end },
    ['<leader>'] = { p = { p = { '<cmd>:lua vim.notify("hi")<cr>', 'notify for fun' } } },
    ['<leader>p'] = {
        z = { '<cmd>:lua vim.notify("gamer")<cr>', 'notify for fun' },
        __test = {
            b = {
                '<cmd>:lua vim.notify("exclusivity")<cr>', 'notasdhf'
            }
        }
    },
}

-- onemap.toggle('test', true)
