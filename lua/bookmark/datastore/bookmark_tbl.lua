local M = {}
local util = require("bookmark.util")

local tbl = require("sqlite.tbl") --- for constructing sql tables

local projects = require("bookmark.datastore.project_tbl")
local files = require("bookmark.datastore.file_tbl")

M.bookmarks = tbl("bookmarks", {
	id = true,
	lnum = { "number", required = true },
	sign_id = { "number", unique = true, required = true },
	sign = { "text", required = true },
	files = {
		type = "text",
		reference = "files.path",
		on_delete = "cascade", --- when referenced file is deleted, delete self
		-- on_update = "cascade", --- when referenced file is deleted, delete self
		required = true,
	},
})

-- get bookmark id
M.get = function(bufnr, lnum)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	lnum = lnum or util.get_current_line()
	local signs = vim.fn.sign_getplaced(bufnr, { group = "Bookmarks", lnum = lnum })
	-- print(vim.inspect(signs))
	local bookmark = nil
	for _, sign in ipairs(signs[1].signs) do
		if sign.lnum == lnum then
			bookmark = M.bookmarks:where({ sign_id = sign.id })
		end
	end

	-- -- TODO: get sign_id from sign
	-- print("bookmark: ", vim.inspect(bookmark))
	if bookmark == nil then
		-- print("bookmark is nil")
		return nil
	end
	return bookmark.sign_id
end

M.get_all_file = function()
	local project_path = vim.fn.getcwd()
	local filepath = vim.fn.expand("%:p")
	local relative_file_path = string.gsub(filepath, project_path, "")
	local bookmarks = {}
	M.bookmarks:each({ where = { files = relative_file_path } }, function(row)
		table.insert(bookmarks, row)
	end)
	return bookmarks
end

-- create bookmark
M.create = function()
	-- create project if it doesn't exist
	if projects.get() == nil then
		projects.create()
	end

	-- create file if it doesn't exist
	if files.get() == nil then
		files.create()
	end

	local project_path = vim.fn.getcwd()
	local filepath = vim.fn.expand("%:p")
	local file = string.gsub(filepath, project_path, "")
	local current_line = util.get_current_line()
	local sign_id = util.add_sign(current_line, "BookmarkSign")
	-- print("sign_id: ", sign_id)
	M.bookmarks:insert({ lnum = current_line, sign_id = sign_id, sign = "", files = file })
end

-- update bookmark
M.update = function()
	print("stub")
end

-- delete bookmark
M.delete = function(bufnr, lnum)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	lnum = lnum or util.get_current_line()
	local signs = vim.fn.sign_getplaced(bufnr, { group = "Bookmarks", lnum = lnum })
	for _, sign in ipairs(signs[1].signs) do
		if sign.lnum == lnum then
			-- print("Deleting sign " .. sign.name .. " on line " .. lnum)
			M.bookmarks:remove({ where = { sign_id = sign.id } })
			vim.fn.sign_unplace("Bookmarks", {
				buffer = vim.api.nvim_buf_get_name(0),
				id = sign.id,
				name = "BookmarkSign",
			})
		end
	end
end

return M
