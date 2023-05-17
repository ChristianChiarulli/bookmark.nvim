local db = require("bookmark.datastore")

local bookmarks = db.bookmarks

-- autocommand to update bookmarks on write
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	pattern = "*",
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()
		local group = "Bookmarks"
		local signs = vim.fn.sign_getplaced(bufnr, { group = group })
		local lnums = {}
		for _, sign in ipairs(signs[1].signs) do
			table.insert(lnums, sign.lnum)
			bookmarks.update(sign.id, sign.lnum)
		end
	end,
})

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
	pattern = "*",
	callback = function()
		local bookmarks_buf = bookmarks.get_all_file()
		-- print(vim.inspect(bookmarks_buf))
		for _, bookmark in ipairs(bookmarks_buf) do
			vim.fn.sign_place(
				bookmark.sign_id,
				"Bookmarks",
				"BookmarkSign",
				vim.api.nvim_buf_get_name(0),
				{ lnum = bookmark.lnum }
			)
		end
	end,
})
