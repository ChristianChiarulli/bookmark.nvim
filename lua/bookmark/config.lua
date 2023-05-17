local M = {}
M.options = {}

local defaults = {
	sign = "",
	highlight = "Function",
}

function M.setup(options)
	M.options = vim.tbl_deep_extend("force", defaults, options or {})
	vim.fn.sign_define("BookmarkSign", { text = options.sign, texthl = options.highlight })
end

return M
