local utils = require("luarocks-nvim.utils")

local plugin_path = utils.get_plugin_path()
local rocks_path = utils.combine_paths(plugin_path, ".rocks")
local lib_extension = utils.is_win() and "?.dll" or "?.so"

return {
	plugin = plugin_path,
	rocks = rocks_path,
	bin = utils.combine_paths(rocks_path, "bin"),
	luarocks = utils.is_win() and utils.combine_paths(rocks_path, "luarocks.bat")
		or utils.combine_paths(rocks_path, "bin", "luarocks"),
	build_cache = utils.combine_paths(rocks_path, "builds"),
	share = {
		utils.combine_paths(rocks_path, "share", "lua", "5.1", "?.lua"),
		utils.combine_paths(rocks_path, "share", "lua", "5.1", "?", "init.lua"),
		utils.combine_paths(rocks_path, "lua", "?.lua"),
		utils.combine_paths(rocks_path, "lua", "?", "init.lua"),
	},
	lib = utils.combine_paths(rocks_path, "lib", "lua", "5.1", lib_extension),
	rtp_lib = utils.combine_paths(rocks_path, "lib", "lua", "5.1"),
	rockspec = utils.combine_paths(rocks_path, "neovim-rocks-user-rockspec-0.0-0.rockspec"),
}
