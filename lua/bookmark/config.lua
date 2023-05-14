local M = {}
M.options = {}

local defaults = {
	sign = "",
	highlight = "Function",
}

function M.setup(options)
	print(vim.inspect(options))
	M.options = vim.tbl_deep_extend("force", defaults, options or {})
end

return M
