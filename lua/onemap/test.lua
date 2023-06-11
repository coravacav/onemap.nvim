local onemap = require 'onemap.init'

onemap.setup {}

-- local t = onemap.create_group('test')

onemap.register {
    ['<leader>pp'] = { '<cmd>:lua vim.notify("hi")<cr>', 'notify for fun' }
}
