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
    ---@type string - this is an automatically prepended string to all recursive bindings
    prefix = '',
    ---@type table<number, string> - these are the groups that you can use in the register function
    groups = {},
    ---@type table<number, string> - these are the list of groups that add bindings to the current buffer when enabled
    buffer_local_groups = {},
    ---@type string - this is the prefix used for when you want to use a group
    group_prefix = '__',
    ---@type string - this is the prefix used for when you want to pass arbitrary info to on_extra_info
    extra_info_prefix = 'extra_',
    ---@param update_obj { lhs: string, buffer_local: boolean } - triggers when key is registered
    on_register = function(update_obj) end,
    ---@param update_obj { lhs: string, buffer_local: boolean } - triggers when key is unregistered
    on_unregister = function(update_obj) end,
    ---@param context { current_path: string, key: string, value: any, buffer_local: boolean } - triggers when extra_info_prefix is detected
    on_extra_info = function(context) end,
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
```

That's all you need for basic keymaps!

### Adding groups

Groups are where this plugin shines though. First, during your `onemap.setup`
(or `opts` w/ lazy), add some group definitions.

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

### Advanced features

There are some extra event handlers that you might want to configure.
`extra_info_prefix` works similarly to `group_prefix`, but instead of defining
a group, it calls `on_extra_info` with the key and object! This lets you
link arbitrary code like `which-key`

I like which-key, so here's what I use for the event handlers to handle
naming of the which-key groups.

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

### Inspiration

I really liked how [which-key](https://github.com/folke/which-key.nvim) did their register function,
but the lacking feature was being able to have _all_ my keymaps in one place (especially so I don't
accidentally collide them)
