local paths = require("luarocks.paths")
local notify = require("luarocks.notify")
local rocks = require("luarocks.rocks")
local utils = require("luarocks.utils")

local is_windows = vim.loop.os_uname().sysname:lower():find("windows")

local function is_prepared()
	return vim.fn.executable(paths.luarocks) == 1
end

--- Checks if a system tool is available.
---@param exe string #The executable to check
---@return boolean
local function is_available(exe)
	return vim.fn.executable(exe) == 1
end

---@diagnostic disable-next-line: param-type-mismatch
math.randomseed(os.time())

local tempdir =
	utils.combine_paths(vim.fn.stdpath("run") --[[@as string]], ("luarocks-%X"):format(math.random(256 ^ 7)))

local steps = {
	{
		description = "Checking git exists",
		task = function()
			assert(is_available("git"), "The 'git' command is required to set up luarocks!")
		end,
	},
	{
		description = "Checking Lua exists",
		task = function()
			assert(
				is_available("lua"),
				"Lua not found on your system! Please install it using your system package manager or from https://github.com/rjpcomputing/luaforwindows."
			)
		end,
	},
	{
		description = "Cloning luarocks repository with lowest depth",
		task = function()
			local output = vim.fn.system({
				"git",
				"clone",
				"--filter=blob:none",
				"https://github.com/luarocks/luarocks.git",
				tempdir,
			})
			assert(
				vim.v.shell_error == 0,
				"Failed to download luarocks repository (is your internet connection unstable?):\n" .. output
			)
		end,
	},
	{
		description = "Performing a local installation",
		task = function()
			if is_windows then
				local job = vim.fn.jobstart({
					"cmd.exe",
					"/c",
					"install.bat",
					"/P",
					paths.rocks,
					"/LV",
					"5.1",
					"/FORCECONFIG",
					"/NOADMIN",
					"/Q",
				}, {
					cwd = tempdir,
					on_stderr = function(_, data)
						local concatenated = table.concat(data, "\n")

                        if vim.trim(concatenated):len() == 0 then
                            return
                        end

						print("Failed to install luarocks:", concatenated)
					end,
				})

				local error_code = vim.fn.jobwait({job})[1]
				assert(error_code == 0, "Failed to install luarocks!")
			else
				local job = vim.fn.jobstart({
					"sh",
					"configure",
					"--prefix=" .. paths.rocks,
					"--lua-version=5.1",
					"--force-config",
				}, {
					cwd = tempdir,
					on_stderr = function(_, data)
						local concatenated = table.concat(data, "\n")

                        if vim.trim(concatenated):len() == 0 then
                            return
                        end

						print("Failed to install luarocks:", concatenated)
					end,
				})

				local error_code = vim.fn.jobwait({ job })[1]

				assert(error_code == 0, "Failed to install luarocks!")

				job = vim.fn.jobstart({
					"make",
					"install",
				}, {
					cwd = tempdir,
					on_stderr = function(_, data)
						local concatenated = table.concat(data, "\n")

                        if vim.trim(concatenated):len() == 0 then
                            return
                        end

						print("Failed to install luarocks:", concatenated)
					end,
				})

				error_code = vim.fn.jobwait({ job })[1]

				assert(error_code == 0, "Failed to install luarocks!")
			end
		end,
	},
}

local rocks_after_build = nil

local function build()
	notify.info("Build started")
	for _, step in ipairs(steps) do
		local record = notify.info("⌛ " .. step.description)
		local ok, error = pcall(step.task)
		if ok then
			notify.info("✅ " .. step.description, record)
		else
			notify.error({ "❌ " .. step.description, error }, record)
			return
		end
	end
	notify.info("Build completed")
	if rocks_after_build then
		rocks.ensure(rocks_after_build)
	end
end

return {
	build = build,
	is_prepared = is_prepared,
	-- This is a bit funky. In short setup runs before build
	-- So if setup received rocks to install, we need to process the install
	-- after the build
	ensure_rocks_after_build = function(ensure_rocks)
		rocks_after_build = ensure_rocks
	end,
}
