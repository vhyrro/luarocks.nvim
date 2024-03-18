local function is_win()
	return vim.loop.os_uname().sysname:lower():find("windows")
end

local function get_path_separator()
	if is_win() then
		return "\\"
	end
	return "/"
end

local function combine_paths(...)
	return table.concat({ ... }, get_path_separator())
end

local function get_plugin_path()
	local str = debug.getinfo(2, "S").source:sub(2)
	if is_win() then
		str = str:gsub("/", "\\")
	end
	return vim.fn.fnamemodify(str:match("(.*" .. get_path_separator() .. ")"), ":h:h:h")
end

local plugin_path = get_plugin_path()
local rocks_path = combine_paths(plugin_path, ".rocks")

return {
	plugin = plugin_path,
	rocks = rocks_path,
	bin = combine_paths(rocks_path, "bin"),
	luarocks = combine_paths(rocks_path, "bin", "luarocks") .. (is_win() and ".bat" or ""),
	build_cache = combine_paths(rocks_path, "builds"),
	share = {
		combine_paths(rocks_path, "share", "lua", "5.1", "?.lua"),
		combine_paths(rocks_path, "share", "lua", "5.1", "?", "init.lua"),
	},
	lib = combine_paths(rocks_path, "lib", "lua", "5.1", "?.so"),
	rockspec = combine_paths(rocks_path, "neovim-rocks-user-rockspec-0.0-0.rockspec"),
}
