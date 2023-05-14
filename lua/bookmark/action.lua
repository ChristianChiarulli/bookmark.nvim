local util = require("bookmark.util")
local config = require("bookmark.config")

local M = {}

local bookmarks = {}
local sign_lookup = {}

vim.fn.sign_define("BookmarkSign", { text = config.options.sign, texthl = config.options.highlight })

function M.toggle()
	local current_file = vim.api.nvim_buf_get_name(0)
	local current_line = util.get_current_line()

	if not bookmarks[current_file] then
		bookmarks[current_file] = {}
	end

	if not sign_lookup[current_file] then
		sign_lookup[current_file] = {}
	end

	for i, line in ipairs(bookmarks[current_file]) do
		if line == current_line then
			vim.fn.sign_unplace("Bookmarks", {
				buffer = vim.api.nvim_buf_get_name(0),
				id = sign_lookup[current_file][current_line],
				name = "BookmarkSign",
			})
			table.remove(bookmarks[current_file], i)
			return
		end
	end

	local sign_id = util.add_sign(current_line, "BookmarkSign")

	if not sign_lookup[current_file][current_line] then
		sign_lookup[current_file][current_line] = {}
	end

	sign_lookup[current_file][current_line] = sign_id
	table.insert(bookmarks[current_file], current_line)
	table.sort(bookmarks[current_file])
end

function M.next()
	local current_file = vim.api.nvim_buf_get_name(0)

	if bookmarks[current_file] == nil then
		print("No bookmarks")
		return
	end

	if current_file and #bookmarks[current_file] > 0 then
		local next_line = util.next_largest(util.get_current_line(), bookmarks[current_file])
		if next_line == nil then
			next_line = bookmarks[current_file][1]
		end
		vim.api.nvim_win_set_cursor(0, { next_line, 0 })
		vim.api.nvim_command("normal! zz")
	else
		print("No bookmarks")
	end
end

function M.previous()
	local current_file = vim.api.nvim_buf_get_name(0)

	if bookmarks[current_file] == nil then
		print("No bookmarks")
		return
	end

	if current_file and #bookmarks[current_file] > 0 then
		local next_line = util.next_smallest(util.get_current_line(), bookmarks[current_file])
		if next_line == nil then
			next_line = bookmarks[current_file][#bookmarks[current_file]]
		end
		vim.api.nvim_win_set_cursor(0, { next_line, 0 })
		vim.api.nvim_command("normal! zz")
	else
		print("No bookmarks")
	end
end

function M.list()
	local current_file = vim.api.nvim_buf_get_name(0)
	if bookmarks[current_file] == nil then
		print("No bookmarks")
		return
	end
	if current_file and #bookmarks[current_file] > 0 then
		for _, line in ipairs(bookmarks[current_file]) do
			print(line)
		end
	else
		print("No bookmarks")
	end
end

return M
