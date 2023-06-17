local onemap = require 'onemap.init'

onemap.setup {
    groups = { 'test' }
}

onemap.create_group('tog')

onemap.register {
    ['<leader>_mm'] = { function() end },
    ['<leader>_'] = { p = { p = { '<cmd>:lua vim.notify("hi")<cr>', 'notify for fun' } } },
    ['<leader>_p'] = {
        z = { '<cmd>:lua vim.notify("gamer")<cr>', 'notify for fun' },
        __test = {
            b = {
                '<cmd>:lua vim.notify("exclusivity")<cr>', 'notasdhf'
            }
        }
    },
}

onemap.register({
    ['<leader>_p'] = {
        __tog = {
            b = {
                '<cmd>:lua vim.notify("ov")<cr>', 'notasdhf'
            }
        }
    }
}, {
    notify_on_possible_conflict = 'warn'
})

-- onemap.toggle('test', true)
