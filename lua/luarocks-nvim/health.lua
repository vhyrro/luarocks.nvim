local build = require("luarocks-nvim.build")

return {
	check = function()
		vim.health.start("luarocks.nvim")
		if build.is_prepared() then
			vim.health.ok("luarocks system is prepared and ready to install luarocks")
		else
			vim.health.info("luarocks system is not prepared")
			-- if build.is_python_available() then
			-- 	vim.health.ok("python3 is available on PATH, and rocks system is ready to be built")
			-- else
			-- 	vim.health.error("python3 is not available on PATH")
			-- end
		end
	end,
}
