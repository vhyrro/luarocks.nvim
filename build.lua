package.path = "./lua/?.lua;" .. package.path

local build = require("luarocks-nvim.build")

vim.schedule(function()
	if not build.is_prepared() then
		build.build()
	end
end)
