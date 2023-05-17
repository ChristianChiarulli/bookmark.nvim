local db = require("bookmark.datastore")
local util = require("bookmark.util")

local bookmarks = db.bookmarks

-- autocommand to update bookmarks on write
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	pattern = "*",
	callback = function()
		-- list all signs

		-- get line number of each sign

		-- update bookmark with new line number
		print("bookmarks saved")
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
