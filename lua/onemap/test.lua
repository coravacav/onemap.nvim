local onemap = require 'onemap.init'

vim.g.mapleader = " "

onemap.setup {
    groups = { 'test' },
    whichkey_integration = true,
}

onemap.create_group('tog')

onemap.register {
    ['<leader>_mm'] = { onemap.toggle_fn('test'), "this is a message" },
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
            extra_wk_name = 'tog',
            b = {
                '<cmd>:lua vim.notify("ov")<cr>', 'notasdhf'
            }
        }
    }
}, {
    whichkey_integration = true,
})

onemap.oneshot('<leader>tt', '<cmd>:lua ="mwa"<cr>')
onemap.oneshot_silent('<leader>ts', '<cmd>:lua ="ahaha"<cr>')

-- onemap.toggle('test', true)
