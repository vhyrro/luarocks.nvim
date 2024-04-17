local build = require("luarocks-nvim.build")

return {
	check = function()
		vim.health.start("luarocks.nvim")
		if build.is_prepared() then
			vim.health.ok("luarocks is installed, system is prepared to install rocks!")
		else
			vim.health.info("luarocks system is not prepared")

			if vim.fn.executable("git") == 1 then
				vim.health.ok("git is installed")
			else
				vim.health.error("git is not installed! Please install it at https://git-scm.com/downloads.")
			end

			if vim.fn.executable("lua") == 1 then
				vim.health.ok("lua is installed")
			else
				vim.health.error(
					"lua is not installed! If you're on unix, please install it using your package manager. For windows use https://github.com/rjpcomputing/luaforwindows."
				)
			end

			if not require("luarocks-nvim.utils").is_win() then
				if vim.fn.executable("make") == 1 then
					vim.health.ok("make is installed")
				else
					vim.health.error("make is not installed!")
				end
			end
		end
	end,
}
