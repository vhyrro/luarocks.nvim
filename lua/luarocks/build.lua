local paths = require("luarocks.paths")
local notify = require("luarocks.notify")
local rocks = require("luarocks.rocks")
local utils = require("luarocks.utils")

local is_windows = vim.loop.os_uname().sysname:lower():find("windows")

local function is_prepared()
	return vim.fn.executable(paths.luarocks) == 1
end

local function remove_shell_color(s)
	return vim.trim(tostring(s):gsub("\x1B%[[0-9;]+m", ""))
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

---Run job and return its exit_code, stdout, stderr
---@param args string[]
---@return integer exit_code
---@return string stdout
---@return string stderr
local function run_job(args)
	local stdout = {}
	local stderr = {}
	local job = vim.fn.jobstart(args, {
		cwd = tempdir,
		stdout_buffered = true,
		stderr_buffered = true,
		on_stdout = function(_, data)
			vim.list_extend(stdout, data or {})
		end,
		on_stderr = function(_, data)
			vim.list_extend(stderr, data or {})
		end,
	})

	return vim.fn.jobwait({ job })[1],
		table.concat(vim.tbl_map(remove_shell_color, stdout), "\n"),
		table.concat(vim.tbl_map(remove_shell_color, stderr), "\n")
end

local rocks_after_build = nil
local luarocks_args = nil
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
		description = "Performing luarocks install.bat if Windows systems",
		task = function()
			if not is_windows then
				return
			end
			local cmd = {
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
			}
			vim.list_extend(cmd, luarocks_args or {})
			local error_code, stdout, stderr = run_job(cmd)
			assert(error_code == 0, string.format("Failed to install luarocks: %s\n%s", stdout, stderr))
		end,
	},
	{
		description = "Performing luarocks `./configure` if Unix systems",
		task = function()
			if is_windows then
				return
			end
			local cmd = {
				"sh",
				"configure",
				"--prefix=" .. paths.rocks,
				"--lua-version=5.1",
				"--force-config",
			}
			vim.list_extend(cmd, luarocks_args or {})
			local error_code, stdout, stderr = run_job(cmd)
			assert(error_code == 0, string.format("Failed to install luarocks: %s\n%s", stdout, stderr))
		end,
	},
	{
		description = "Performing luarocks `make` if Unix systems",
		task = function()
			if is_windows then
				return
			end
			local error_code, stdout, stderr = run_job({ "make" })
			assert(error_code == 0, string.format("Failed to install luarocks: %s\n%s", stdout, stderr))
		end,
	},
	{
		description = "Performing luarocks `make install` if Unix systems",
		task = function()
			if is_windows then
				return
			end
			local error_code, stdout, stderr = run_job({ "make", "install" })
			assert(error_code == 0, string.format("Failed to install luarocks: %s\n%s", stdout, stderr))
		end,
	},
}

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
	ensure_rocks_after_build = function(ensure_rocks, args)
		rocks_after_build = ensure_rocks
		luarocks_args = args
	end,
}
