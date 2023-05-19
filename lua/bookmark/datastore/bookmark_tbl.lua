local M = {}
local util = require("bookmark.util")

local tbl = require("sqlite.tbl") --- for constructing sql tables
local config = require("bookmark.config")

local projects = require("bookmark.datastore.project_tbl")
local files = require("bookmark.datastore.file_tbl")

M.bookmarks = tbl("bookmarks", {
	id = true,
	lnum = { "number", required = true, unique = false },
	sign_id = { "number", unique = false, required = true },
	sign = { "text", required = true },
	files = {
		type = "integer",
		reference = "files.id",
		on_delete = "cascade", --- when referenced file is deleted, delete self
		on_update = "cascade", --- when referenced file is deleted, delete self
		required = true,
	},
})

-- get bookmark id
M.get = function(bufnr, lnum)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	lnum = lnum or util.get_current_line()
	local signs = vim.fn.sign_getplaced(bufnr, { group = "Bookmarks", lnum = lnum })
	local bookmark = nil
	for _, sign in ipairs(signs[1].signs) do
		if sign.lnum == lnum then
			bookmark = M.bookmarks:where({ sign_id = sign.id })
		end
	end

	if bookmark == nil then
		return nil
	end

	return bookmark.sign_id
end

M.get_all_file = function()
	-- local project_path = vim.fn.getcwd()
	-- local filepath = vim.fn.expand("%:p")
	-- local relative_file_path = string.gsub(filepath, project_path, "")
  local file = files.get()
	local bookmarks = {}
  if file == nil then
    return bookmarks
  end
	M.bookmarks:each({ where = { files = file.id } }, function(row)
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

	local file = files.get()

	local current_line = util.get_current_line()
	-- local id = generateSignId(file, current_line)
	local sign_id = util.add_sign(0, current_line, "BookmarkSign")
	-- print("sign_id: ", sign_id)
	M.bookmarks:insert({ lnum = current_line, sign_id = sign_id, sign = config.options.sign, files = file.id })
	-- print("bookmark.sign_id: ", sign_id)
end

-- update bookmark
M.update = function(sign_text, sign_id, lnum, file_id)
	M.bookmarks:update({
		where = { sign_id = sign_id, files = file_id },
		set = { lnum = lnum, sign = sign_text, files = file_id },
	})
end

-- delete bookmark
M.delete = function(bufnr, lnum)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	lnum = lnum or util.get_current_line()
	local signs = vim.fn.sign_getplaced(bufnr, { group = "Bookmarks", lnum = lnum })
	local file = files.get()
	for _, sign in ipairs(signs[1].signs) do
		if sign.lnum == lnum then
			M.bookmarks:remove({ where = { sign_id = sign.id, files = file.id } })
			vim.fn.sign_unplace("Bookmarks", {
				buffer = vim.api.nvim_buf_get_name(0),
				id = sign.id,
				name = "BookmarkSign",
			})
		end
	end
end

return M
