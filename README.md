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

## ⚙️ Configuration

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
    ---@param context { current_path: string, key: string, value: any } - triggers when extra_info_prefix is detected
    on_extra_info = function(context) end,
}
```

When you run `onemap.register`, you can override any of these options with the second argument.

## 🪄 Setup

With the default settings, **WhichKey** will work out of the box for most builtin keybindings,
but the real power comes from documenting and organizing your own keybindings.

To document and/or setup your own mappings, you need to call the `register` method

```lua
local wk = require("which-key")
wk.register(mappings, opts)
```

Default options for `opts`

```lua
{
  mode = "n", -- NORMAL mode
  -- prefix: use "<leader>f" for example for mapping everything related to finding files
  -- the prefix is prepended to every mapping part of `mappings`
  prefix = "",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = false, -- use `nowait` when creating keymaps
  expr = false, -- use `expr` when creating keymaps
}
```

> ❕ When you specify a command in your mapping that starts with `<Plug>`, then we automatically set `noremap=false`, since you always want recursive keybindings in this case

### ⌨️ Mappings

> ⌨ for **Neovim 0.7** and higher, which key will use the `desc` attribute of existing mappings as the default label

Group names use the special `name` key in the tables. There's multiple ways to define the mappings. `wk.register` can be called multiple times from anywhere in your config files.

```lua
local wk = require("which-key")
-- As an example, we will create the following mappings:
--  * <leader>ff find files
--  * <leader>fr show recent files
--  * <leader>fb Foobar
-- we'll document:
--  * <leader>fn new file
--  * <leader>fe edit file
-- and hide <leader>1

wk.register({
  f = {
    name = "file", -- optional group name
    f = { "<cmd>Telescope find_files<cr>", "Find File" }, -- create a binding with label
    r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File", noremap=false, buffer = 123 }, -- additional options for creating the keymap
    n = { "New File" }, -- just a label. don't create any mapping
    e = "Edit File", -- same as above
    ["1"] = "which_key_ignore",  -- special label to hide it in the popup
    b = { function() print("bar") end, "Foobar" } -- you can also pass functions!
  },
}, { prefix = "<leader>" })
```

<details>
<summary>Click to see more examples</summary>

```lua
-- all of the mappings below are equivalent

-- method 2
wk.register({
  ["<leader>"] = {
    f = {
      name = "+file",
      f = { "<cmd>Telescope find_files<cr>", "Find File" },
      r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
      n = { "<cmd>enew<cr>", "New File" },
    },
  },
})

-- method 3
wk.register({
  ["<leader>f"] = {
    name = "+file",
    f = { "<cmd>Telescope find_files<cr>", "Find File" },
    r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
    n = { "<cmd>enew<cr>", "New File" },
  },
})

-- method 4
wk.register({
  ["<leader>f"] = { name = "+file" },
  ["<leader>ff"] = { "<cmd>Telescope find_files<cr>", "Find File" },
  ["<leader>fr"] = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
  ["<leader>fn"] = { "<cmd>enew<cr>", "New File" },
})
```

</details>

**Tips:** The default label is `keymap.desc` or `keymap.rhs` or `""`,
`:h nvim_set_keymap()` to get more details about `desc` and `rhs`.

### 🚙 Operators, Motions and Text Objects

**WhichKey** provides help to work with operators, motions and text objects.

> `[count]operator[count][text-object]`

- operators can be configured with the `operators` option
  - set `plugins.presets.operators` to `true` to automatically configure vim built-in operators
  - set this to `false`, to only include the list you configured in the `operators` option.
  - see [here](https://github.com/folke/which-key.nvim/blob/main/lua/which-key/plugins/presets/init.lua#L5) for the full list part of the preset
- text objects are automatically retrieved from **operator pending** key maps (`omap`)
  - set `plugins.presets.text_objects` to `true` to configure built-in text objects
  - see [here](https://github.com/folke/which-key.nvim/blob/main/lua/which-key/plugins/presets/init.lua#L43)
- motions are part of the preset `plugins.presets.motions` setting
  - see [here](https://github.com/folke/which-key.nvim/blob/main/lua/which-key/plugins/presets/init.lua#L20)

<details>
<summary>How to disable some operators? (like v)</summary>

```lua
-- make sure to run this code before calling setup()
-- refer to the full lists at https://github.com/folke/which-key.nvim/blob/main/lua/which-key/plugins/presets/init.lua
local presets = require("which-key.plugins.presets")
presets.operators["v"] = nil
```

</details>

## 🚀 Usage

When the **WhichKey** popup is open, you can use the following key bindings (they are also displayed at the bottom of the screen):

- hit one of the keys to open a group or execute a key binding
- `<esc>` to cancel and close the popup
- `<bs>` go up one level
- `<c-d>` scroll down
- `<c-u>` scroll up

Apart from the automatic opening, you can also manually open **WhichKey** for a certain `prefix`:

> ❗️ don't create any keymappings yourself to trigger WhichKey. Unlike with _vim-which-key_, we do this fully automatically.
> Please remove any left-over triggers you might have from using _vim-which-key_.

```vim
:WhichKey " show all mappings
:WhichKey <leader> " show all <leader> mappings
:WhichKey <leader> v " show all <leader> mappings for VISUAL mode
:WhichKey '' v " show ALL mappings for VISUAL mode
```
