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

local function is_python_available()
	return vim.fn.executable("python3") == 1
end

local steps = {
	{
		description = "Checking python3 exists",
		task = function()
			assert(is_python_available(), "An external 'python3' command is required")
		end,
	},
	{
		description = "Creating python3 virtual environment",
		task = function()
			local output = vim.system({ "python3", "-m", "venv", paths.rocks }):wait()
			assert(output.code == 0, "Failed to create python3 venv\n" .. output.stderr)
		end,
	},
	{
		description = "Installing hererocks",
		task = function()
			local output = vim.system({ paths.pip, "install", "hererocks" }):wait()
			assert(output.code == 0, "Failed to install hererocks\n" .. output.stderr)
		end,
	},
	{
		description = "Installing LuaJIT",
		task = function()
			local opts = nil
			if is_darwin() then
				opts = {
					env = {
						MACOSX_DEPLOYMENT_TARGET = "10.6",
					},
				}
			end
			local output = vim.system({
				paths.hererocks,
				"--builds",
				paths.build_cache,
				string.format("-j%s", versions.LUA_JIT),
				string.format("-r%s", versions.LUA_ROCKS),
				paths.rocks,
			}, opts):wait()
			assert(output.code == 0, "Failed to install LuaJIT\n" .. output.stderr)
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
	is_python_available = is_python_available,
	-- This is a bit funky. In short setup runs before build
	-- So if setup received rocks to install, we need to process the install
	-- after the build
	ensure_rocks_after_build = function(ensure_rocks)
		rocks_after_build = ensure_rocks
	end,
}
