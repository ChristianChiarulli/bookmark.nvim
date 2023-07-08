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
	vim.fn.sign_define("BookmarkSign", { text = M.options.sign, texthl = M.options.highlight })
	vim.fn.sign_define("FilemarkSign", { text = M.options.file_sign, texthl = M.options.file_highlight })
end

return M
