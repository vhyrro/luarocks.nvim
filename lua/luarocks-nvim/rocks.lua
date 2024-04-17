local paths = require("luarocks-nvim.paths")
local notify = require("luarocks-nvim.notify")

local function install(rocks)
	local file, error = io.open(paths.rockspec, "w+")
	assert(file, "[luarocks] Failed to write rockspec file " .. (error or ""))

	-- Write a fake rockspec file with a list of the user's requested luarocks
	file:write(string.format(
		[[
rockspec_format = "3.0"
package = "neovim-rocks-user-rockspec"
version = "0.0-0"
source = { url = "some-fake-url" }
dependencies = %s
build = { type = "builtin" }
]],
		vim.inspect(rocks)
	))

	file:close()

	local record = notify.info({ "⌛ Installing rocks:\n", table.concat(rocks, ",") })

	local output = vim.fn.system({
		paths.luarocks,
		"install",
		"--lua-version=5.1",
		"--server='https://nvim-neorocks.github.io/rocks-binaries/'",
		"--deps-only",
		paths.rockspec,
	})

	assert(vim.v.shell_error == 0, "[luarocks] Failed to install from rockspec\n" .. output)

	notify.info("✅ Installed rocks", record)
end

local function ensure(rocks)
	-- There are no rocks requests
	if not rocks or #rocks == 0 then
		return
	end

	-- Get a list of installed luarocks
	local installed_output = vim.fn.system({ paths.luarocks, "list", "--porcelain" })

	-- Get all non-blank lines split be "\n"
	local installed_lines = vim.tbl_filter(function(line)
		return line ~= ""
	end, vim.split(installed_output, "\n"))

	-- Get the first element of the list
	local installed_rocks = vim.tbl_map(function(line)
		return vim.split(line, "\t")[1]
	end, installed_lines)

	-- Build the missing rocks
	local missing_rocks = {}
	for _, rock in ipairs(rocks) do
		if not vim.tbl_contains(installed_rocks, rock) then
			table.insert(missing_rocks, rock)
		end
	end

	if #missing_rocks ~= 0 then
		install(rocks)
	end
end

return {
	ensure = ensure,
	install = install,
}
