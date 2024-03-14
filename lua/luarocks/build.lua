local paths = require("luarocks.paths")
local notify = require("luarocks.notify")
local rocks = require("luarocks.rocks")

local versions = {
	LUA_JIT = "2.1",
	LUA_ROCKS = "latest",
}

local function is_darwin()
	return vim.loop.os_uname().sysname == "Darwin"
end

local function is_prepared()
	return vim.fn.executable(paths.luarocks) == 1
end

--- Checks if a system tool is available.
---@param exe string #The executable to check
---@return boolean
local function is_available(exe)
	return vim.fn.executable(exe) == 1
end

local steps = {
	{
		description = "Checking git exists",
		task = function()
			assert(is_available("git"), "An external 'git' command is required to set up luarocks!")
		end,
	},
    {
        description = "Check running operating system",
        task = function()
            assert(vim.uv.os_uname().sysname:lower():find("windows"))
        end
    },
	{
		description = "Cloning luarocks repository with lowest depth",
		task = function()
			local output = vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/luarocks/luarocks.git", paths.rocks })
			assert(vim.v.shell_error == 0, "Failed to download luarocks repository (is your internet connection unstable?):\n" .. output)
		end,
	},
	{
		description = "Performing a local installation",
		task = function()
            local output = vim.fn.system({
                vim.o.sh,
                -- TODO(vhyrro): Use combine_paths instead
                paths.rocks .. "/configure",
                "--prefix=" .. paths.rocks,
                "--lua-version=5.1",
                "--force-config",
            })
			assert(vim.v.shell_error == 0, "Failed to install luarocks:\n" .. output)
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
