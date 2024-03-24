# A Collection of Lua Utilities for Neovim

This repository contains a small set of nicities for performing repetitive tasks within Neovim.
This set may shrink further as the features are included in other, larger "utility kits".

The code you see in this repository is primarily used within [Neorg](https://github.com/nvim-neorg/neorg).
All functions are annotated using [LuaCATS](https://luals.github.io/wiki/annotations).

The highlight of the repository is the `match` function, allowing for complex testing of conditions
in a similar fashion to e.g. Rust. Below is an example:
```lua
local match = require("lua-utils").match

local my_string = "possible-value"

--- @type integer|string|table
local transformed_value = match(my_string) {
    ["possible-value"] = 10, -- Simple return type.
    [{ "value1", "value2" }] = "special-case", -- Handling of many cases.
    _ = function() -- Functions will be automatically invoked and their return values propagated.
        print("Error: invalid value provided!")
        return {}
    end,
}

print(transformed_value)
```
