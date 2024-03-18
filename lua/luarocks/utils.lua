local utils = {}

function utils.is_win()
	return vim.loop.os_uname().sysname:lower():find("windows")
end

function utils.get_path_separator()
	if utils.is_win() then
		return "\\"
	end
	return "/"
end

function utils.combine_paths(...)
	return table.concat({ ... }, utils.get_path_separator())
end

function utils.get_plugin_path()
	local str = debug.getinfo(2, "S").source:sub(2)
	if utils.is_win() then
		str = str:gsub("/", "\\")
	end
	return vim.fn.fnamemodify(str:match("(.*" .. utils.get_path_separator() .. ")"), ":h:h:h")
end

return utils
