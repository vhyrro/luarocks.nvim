local function is_win()
	return vim.loop.os_uname().sysname == "Windows_NT"
end

local function get_path_separator()
	if is_win() then
		return "\\"
	end
	return "/"
end

local function get_plugin_path()
	local str = debug.getinfo(2, "S").source:sub(2)
	if is_win() then
		str = str:gsub("/", "\\")
	end
	return vim.fn.fnamemodify(str:match("(.*" .. get_path_separator() .. ")"), ":h:h:h")
end

local plugin_path = get_plugin_path()
local rocks_path = vim.fs.joinpath(plugin_path, ".rocks")

return {
	plugin = plugin_path,
	rocks = rocks_path,
	bin = vim.fs.joinpath(rocks_path, "bin"),
	luarocks = vim.fs.joinpath(rocks_path, "bin", "luarocks"),
	pip = vim.fs.joinpath(rocks_path, "bin", "pip3"),
	hererocks = vim.fs.joinpath(rocks_path, "bin", "hererocks"),
	build_cache = vim.fs.joinpath(rocks_path, "builds"),
	share = {
		vim.fs.joinpath(rocks_path, "share", "lua", "5.1", "?.lua"),
		vim.fs.joinpath(rocks_path, "share", "lua", "5.1", "?", "init.lua"),
	},
	lib = vim.fs.joinpath(rocks_path, "lib", "lua", "5.1", "?.so"),
	rockspec = vim.fs.joinpath(rocks_path, "neovim-rocks-user-rockspec-0.0-0.rockspec"),
}
