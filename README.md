<div align="center">

# luarocks.nvim

</div>

`luarocks.nvim` is a Neovim plugin designed to streamline the installation of luarocks packages directly within Neovim. It simplifies the process of managing Lua dependencies, ensuring a hassle-free experience for Neovim users.

## Requirements

- Neovim `0.9` or greater.
- The `git` CLI tool.
- Lua 5.1 installed on your system and available in your system's `PATH`.

  **On unix systems**, this is as simple as using your system package manager (`brew`, `pacman`, `apt` etc.).
  Just make sure that you're installing the 5.1 version of lua! Usually the package name will be something
  along the lines of `lua51` or `lua-5.1`.

  **On Windows systems**, it's recommended to use an all-in-one installer like https://github.com/rjpcomputing/luaforwindows.
  Be sure to restart your terminal after installing Lua for the `PATH` to be updated!

## Usage

### Lazy.nvim Integration

For users employing the Lazy.nvim plugin manager, `luarocks.nvim` can be added to your configuration with the following code:

```lua
{
  "vhyrro/luarocks.nvim",
  priority = 1000, -- Very high priority is required, luarocks.nvim should run as the first plugin in your config.
  config = true,
}
```

Upon installing, an automatic build step will be invoked by `lazy.nvim` in an attempt to compile a local luarocks installation on your machine.
If you're having issues with this, be sure to manually run `:Lazy build luarocks.nvim`!

Generally, other plugins which rely on `luarocks.nvim` as their dependency manager perform automatic
dependency installation in their `build.lua`s, so you don't even have to touch any options yourself!
Just set up this plugin and the rest should be automatic.

### Installing a Rock List

To install a set of rocks (with the ability to add version constraints) use the following configuration instead:

```lua
{
  "vhyrro/luarocks.nvim",
  priority = 1000, -- Very high priority is required, luarocks.nvim should run as the first plugin in your config.
  opts = {
    rocks = { "fzy", "pathlib.nvim ~> 1.0" }, -- specifies a list of rocks to install
    -- luarocks_build_args = { "--with-lua=/my/path" }, -- extra options to pass to luarocks's configuration script
  },
}
```

The latest version of a rock will be pulled if the version constraint is not provided.

### Other Plugin Managers

For users utilizing other plugin managers, manual setup is required. Use the following code to initialize `luarocks.nvim`:

```lua
require("luarocks-nvim").setup()
```

Not only this, you will also need to set up a manual build trigger. This is supported by most
plugin managers like `packer`/`pckr` and `vim-plug`. See [manual build trigger](#manual-build-trigger)
for more info.

## Build Process

The `luarocks.nvim` plugin includes a build process to ensure proper functionality. The build process involves the following steps:

1. Checking for the existence of `lua` and its respective version as well as `git`.
2. Cloning the `luarocks/luarocks` repository at the lowest possible depth.
3. Compiling `luarocks` into a `.rocks` directory directly in this plugin's root.
   On Windows the install process may prompt for administrative permissions.

### Manual Build Trigger

You can manually trigger the build process using the following command inside the plugin root:

```bash
nvim -l build.lua
```

Executing this command initiates the complete build process, ensuring that all dependencies are properly installed. This manual trigger can be useful in scenarios where you want to ensure a fresh installation or troubleshoot any issues related to the build process.

Please note that the build process is automatically invoked during the setup phase, so manual triggering may be unnecessary in most cases.
