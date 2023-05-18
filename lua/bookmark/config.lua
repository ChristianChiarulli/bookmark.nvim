local M = {}
M.options = {}

local defaults = {
	sign = "",
	highlight = "Function",
	file_sign = "󱡅",
	file_highlight = "Function",
}


vim.fn.sign_define("FilemarkSign", { text = "󱡅", texthl = "Debug" })
function M.setup(options)
	M.options = vim.tbl_deep_extend("force", defaults, options or {})
	vim.fn.sign_define("BookmarkSign", { text = options.sign, texthl = options.highlight })
	vim.fn.sign_define("FilemarkSign", { text = options.file_sign, texthl = options.file_highlight })
end

return M
