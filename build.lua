package.path = "./lua/?.lua;" .. package.path

vim.schedule(function()
	local build = require("luarocks-nvim.build")

	if not build.is_prepared() then
		build.build()
	end
end)
