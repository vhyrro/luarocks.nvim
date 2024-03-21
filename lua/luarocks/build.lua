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

local function is_win()
	return vim.loop.os_uname().sysname == "Windows_NT"
end

local function remove_shell_color(s)
    return tostring(s):gsub("\x1B%[[0-9;]+m", "")
end

local python = is_win() and "python" or "python3"

local function is_prepared()
	return vim.fn.executable(paths.luarocks) == 1
end

local function is_python_available()
	return vim.fn.executable(python) == 1
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
			local output = vim.fn.system({ python, "-m", "venv", paths.rocks })
			assert(vim.v.shell_error == 0, "Failed to create python3 venv\n" .. output)
		end,
	},
	{
		description = "Installing hererocks",
		task = function()
			local output = vim.fn.system({ paths.pip, "install", "hererocks" })
			assert(vim.v.shell_error == 0, "Failed to install hererocks\n" .. output)
		end,
	},
	{
		description = "Installing LuaJIT",
		task = function()
            local error_output

            local opts = {
                stdout_buffered = true,
                on_stdout = function(_, data)
                    local concatenated = table.concat(data, "\n")

                    if vim.trim(concatenated):len() == 0 then
                        return
                    end

                    error_output = remove_shell_color(concatenated)
                end,
            }

			if is_darwin() then
                opts.env = {
                    MACOSX_DEPLOYMENT_TARGET = "10.6",
                }
			end

			local job = vim.fn.jobstart({
				paths.hererocks,
				"--builds",
				paths.build_cache,
				string.format("-j%s", versions.LUA_JIT),
				string.format("-r%s", versions.LUA_ROCKS),
				paths.rocks,
			}, opts)

            local result = vim.fn.jobwait({ job })[1]

			assert(result == 0, "Failed to install LuaJIT\n" .. error_output)
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
