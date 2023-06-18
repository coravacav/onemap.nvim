# 🪢 Onemap

**Onemap** is a lua plugin for recentish Neovim (I didn't bother checking exact version) that helps you
manage keybindings, with the power to even create custom menus.

## ✨ Features

- Sets keymaps
- Toggles keymaps

That's it. It's pretty powerful though.

## ⚡️ Requirements

A recentish version of Neovim! I didn't bother checking the compat for older versions than 0.9

## 📦 Installation

Install the plugin with your preferred package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "coravacav/onemap.nvim",
  event = "VeryLazy",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  }
}
```

## ⚙️ Configuration / Defaults

Onemap comes with the following defaults:

```lua
{
    ---@type string
    --- this is an automatically prepended string to all recursive bindings
    prefix = '',
    ---@type table<number, string>
    --- these are the groups that you can use in the register function
    groups = {},
    ---@type table<number, string>
    --- these are the list of groups that add bindings to the current buffer when enabled
    buffer_local_groups = {},
    ---@type string
    --- this is the prefix used for when you want to use a group
    group_prefix = '__',
    ---@type string
    --- this is the prefix used for when you want to pass arbitrary info to on_extra_info
    extra_info_prefix = 'extra_',
    ---@param context { lhs: string, buffer_local: boolean }
    --- triggers when key is registered
    on_register = function(context) end,
    ---@param context { lhs: string, buffer_local: boolean }
    --- triggers when key is unregistered
    on_unregister = function(context) end,
    ---@param context { current_path: string, key: string, value: any, buffer_local: boolean, event: 'registered' | 'enabled' | 'disabled' }
    --- triggers when extra_info_prefix is detected
    on_extra_info = function(context) end,
    ---@type 'off' | 'warn' | 'error'
    notify_on_possible_conflict = 'off',
    ---@type boolean
    whichkey_integration = false,
    ---@type table<number, string>
    default_modes = { 'n' },
}
```

When you run `onemap.register`, you can override any of these options with the second argument.

### Basic Usage

To add keymaps, just call `onemap.register`.

```lua
local onemap = require("onemap")
-- As an example, we will create the following mappings:
--  * <leader>se find files

-- This is only to cut down on example space
local mapping = { ":Telescope find_files", "Find Files" }

-- All of the following do the same thing
onemap.register({ se = mapping }, { prefix = "<leader>" })
onemap.register { ['<prefix>se'] = mapping }
onemap.register({ ['prefix'] = { s = { e = mapping } } }, {})
```

The "end keymap shape" can be any of the following

```
{function | string, string, ...}
{function | string, desc = string, ...}
{rhs = function | string, desc = string, ...}
```

with `...` being any of the following

```
modes = table -- default is { 'n' }
opts = table -- passed directly to `vim.keymap.set`
```

That's all you need for basic keymaps!

#### Another option

You can also register keymaps with `onemap.oneshot`. Everything is the same as above,
but you don't need to do all sorts of object syntax.

```lua
---@param lhs string
---@param rhs string | function
---@param desc? string
---@param group? string
---@param mapping_opts? table
---@param config_opts? table
onemap.oneshot(lhs, rhs, desc, group, mapping_opts, config_opts)

onemap.oneshot(
    'ss',
    '<cmd>Telescope find_files<cr>',
    'Telescope find files',
    'test',
    { silent = true },
    { prefix = '<leader>' }
)
-- is equivalent to
onemap.register(
    { ss = { '<cmd>Telescope find_files<cr>', 'Telescope find files', opts = { silent = true } } },
    { prefix = '<leader>' }
)
```

There are also a couple of presets, for various usecases

```lua
onemap.oneshot_silent = oneshot(..., ..., ..., ..., { silent = true }, ...)
```

### Adding groups

Groups are where this plugin shines though.
Groups are a label that allows the organization of related keybinds.
First, during your `onemap.setup` (or `opts` w/ lazy), add some group definitions.

```lua
local onemap = require 'onemap'

onemap.setup {
    -- list of strings, name of the groups
    groups = { "group", "brou" },
    -- must be a group in groups
    -- makes any toggle for included groups only affect current buffer.
    --   this is useful for lsp
    buffer_local_groups = { "brou" }
}
```

Then, use the group by adding a key to the register object (at any depth)
prefixed by `config.group_prefix`.

```lua
local onemap = require 'onemap'

onemap.register({
    -- "__" is the default group_prefix
    __group = {
        s = { "<cmd>lua ='test message'", "A test message" }
    }
    e = {
        x = { "<cmd>lua ='test message'", "A test message" }
        -- you can do it at any level
        __brou = {
            r = { "<cmd>lua ='test message'", "A test message" }
        }
        -- you can use a group more than once
        __group = {
            z = { "<cmd>lua ='test message'", "A test message" }
        }
    }
}, { prefix = '<leader>' })
```

After you've registered these keybinds, enable them with `onemap.toggle`

```lua
local onemap = require 'onemap'

onemap.toggle('group')
onemap.toggle('brou', false) -- optional boolean prop
```

### Common patterns

Groups are good generally for two things:

#### LSP

You can add your lsp bindings together with your normal bindings, to prevent conflicts

```lua
onemap.setup {
    groups = { 'lsp' },
    buffer_local_groups = { 'lsp' }
}

onemap.register {
    ss = { ":Telescope find_files", "Find Files" },
    __lsp = {
        fa = {
            function()
                vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
            end,
            "Format buffer"
        }
    }
}

-- in your lsp's on_attach

onemap.toggle('lsp')
```

#### Menus

You can make pseudo menus, by toggling groups!
This is especially useful if you want to repeatedly press buttons,
but a long binding is unwieldy.

```lua
onemap.setup {
    groups = { 'window' }
}

onemap.register {
    ['<leader>w'] = { function() onemap.toggle("window") end, "Start window menu" },
    -- The same as above, but shorter
    ['<leader>w'] = { onemap.toggle_fn("window"), "Start window menu" },
    __window = {
        h = { "<C-w>h", "Move to left window" },
        j = { "<C-w>j", "Move to lower window" },
        k = { "<C-w>k", "Move to upper window" },
        l = { "<C-w>l", "Move to right window" },
        ["<cr>"] = { function() onemap.toggle("window") end, "Stop window menu" },
    }
}
```

### Advanced features

#### Extending functionality

There are some extra event handlers that you might want to configure.
`extra_info_prefix` works similarly to `group_prefix`, but instead of defining
a group, it calls `on_extra_info` with the key and object! This lets you
link arbitrary code like `which-key`

##### Which-key has first-class support through the config, this is an "arbitrary" example

```lua
onemap.register({
    s = {
        -- "extra_" is the default `extra_info_prefix`
        extra_name = "Telescope", -- this gets passed to `on_extra_info`
        e = { ":Telescope find_files", "Find Files" }
    }
}, {
    on_extra_info = function(context)
        -- equal to "s" here
        local current_path = context.current_path
        -- equal to "name" here
        local key = context.key
        -- equal to "Telescope" here
        local value = context.value

        if key == 'name' then
            wk.register({ [current_path] = { name = value } })
        end
    end
})
```

You can also add groups dynamically with `onemap.create_group`.
You'd need to do this before registering any keymaps with that group.
Useful for if you want to isolate plugin configuration.

```lua
---@param group string - name of the new group
---@param buffer_local? - whether the group is buffer_local
onemap.create_group(group, buffer_local)
```

#### Which-key integration

To enable which-key integration, simply turn on `config.whichkey_integration`.

Then, just use `extra_wk_name` where applicable.

```lua
onemap.register {
    a = {
        -- This will get passed in to whichkey.register and label the group properly
        extra_wk_name = "Menu label"
        b = { "<cmd>lua ='Hi'", "Description" } -- Descriptions are also automatically registered
    }
}
```

The integration uses the builtin `on_extra_info` and `on_unregister` features, so, if you're
extending that manually, be sure to pass in the builtin `which-key` one as well with `onemap.wki`

```lua
onemap.register( { ... } , {
    on_extra_info = function (context)
        onemap.wki.on_extra_info(context)

        -- your code here.
    end,
    on_unregister = function (context)
        onemap.wki.on_unregister(context)

        -- your code here.
    end
})
```

### Inspiration

I really liked how [which-key](https://github.com/folke/which-key.nvim) did their register function,
but the lacking feature was being able to have _all_ my keymaps in one place (especially so I don't
accidentally collide them)
