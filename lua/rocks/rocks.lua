local paths = require("rocks.paths")
local notify = require("rocks.notify")
local build = require("rocks.build")

local function install(rocks)
	local file, error = io.open(paths.rockspec, "w+")
	assert(file, "[rocks] Failed to write rockspec file " .. (error or ""))

	file:write(string.format(
		[[
package = "neovim-rocks-user-rockspec"
version = "0.0-0"
source = { url = "some-fake-url" }
dependencies = %s
build = {
  type = "builtin"
}
]],
		vim.inspect(rocks)
	))

	file:close()

	local output = vim.system({ paths.luarocks, "install", "--deps-only", paths.rockspec }):wait()

	assert(output.code == 0, "[rocks] Failed to install from rockspec\n" .. output.stderr)
end

local function ensure(rocks)
	local luarocks = io.open(paths.luarocks, "r")

	if luarocks then
		luarocks:close()
	else
		build.build()
	end

	local installed_output = vim.system({ paths.luarocks, "list", "--porcelain" }):wait()
	local installed_lines = vim.tbl_filter(function(line)
		return line ~= ""
	end, vim.split(installed_output.stdout, "\n"))
	local installed_rocks = vim.tbl_map(function(line)
		return vim.split(line, "\t")[1]
	end, installed_lines)

	local missing_rocks = {}
	for _, rock in ipairs(rocks) do
		if not vim.tbl_contains(installed_rocks, rock) then
			table.insert(missing_rocks, rock)
		end
	end

	if #missing_rocks ~= 0 then
		notify.info("Installing missing rocks: " .. table.concat(missing_rocks, ", "))
		install(rocks)
		notify.info("Rocks installed: " .. table.concat(missing_rocks, ", "))
	end
end

return {
	ensure = ensure,
}
