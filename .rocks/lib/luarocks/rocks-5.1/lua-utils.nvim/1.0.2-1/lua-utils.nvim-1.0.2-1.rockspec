local git_ref = 'v1.0.2'
local modrev = '1.0.2'
local specrev = '1'

local repo_url = 'https://github.com/nvim-neorg/lua-utils.nvim'

rockspec_format = '3.0'
package = 'lua-utils.nvim'
version = modrev ..'-'.. specrev

description = {
  summary = 'A set of utility functions for Neovim plugins.',
  detailed = [[
This repository contains a small set of nicities for performing repetitive tasks within Neovim.
This set may shrink further as the features are included in other, larger "utility kits".
The code you see in this repository is primarily used within Neorg.
All functions are annotated using LuaCATS.]],
  labels = { },
  homepage = 'https://github.com/nvim-neorg/lua-utils.nvim',
  license = 'MIT'
}

dependencies = { 'lua >= 5.1' } 

source = {
  url = repo_url .. '/archive/' .. git_ref .. '.zip',
  dir = 'lua-utils.nvim-' .. '1.0.2',
}

build = {
  type = 'builtin',
  copy_directories = { },
}
