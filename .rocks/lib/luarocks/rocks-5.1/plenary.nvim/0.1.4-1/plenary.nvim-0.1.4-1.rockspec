local git_tag = 'v0.1.4'
local modrev = '0.1.4'
local specrev = '-1'

local repo_url = 'https://github.com/nvim-lua/plenary.nvim'

rockspec_format = '3.0'
package = 'plenary.nvim'
version = modrev .. specrev

description = {
  summary = 'lua functions you don\'t want to write',
  detailed = [[
    plenary: full; complete; entire; absolute; unqualified.
    All the lua functions I don't want to write twice.  
]],
  labels = { 'hacktoberfest', 'lua', 'neovim' } ,
  homepage = 'https://github.com/nvim-lua/plenary.nvim',
  license = 'MIT'
}

dependencies = {
   'lua >= 5.1, < 5.4',
   'luassert'
}

source = {
  url = repo_url .. '/archive/' .. git_tag .. '.zip',
  dir = 'plenary.nvim-' .. modrev,
}

build = {
   type = 'builtin',
   copy_directories = {
     'data',
     'plugin'
   }
}

test = {
  type = 'command',
  command = 'make test'
}
