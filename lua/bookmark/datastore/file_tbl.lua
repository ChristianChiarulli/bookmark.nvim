local M = {}

local tbl = require("sqlite.tbl") --- for constructing sql tables
local util = require("bookmark.util")
local config = require("bookmark.config")

local projects = require("bookmark.datastore.project_tbl")

M.files = tbl("files", {
	id = true,
	lnum = { "number", required = false },
	sign_id = { "number", unique = false, required = false },
	sign = { "text", required = false },
	path = {
		"text",
		unique = true,
		required = true,
	},

	projects = {
		type = "text",
		reference = "projects.path",
		on_delete = "cascade", --- when referenced file is deleted, delete self
		-- on_update = "cascade", --- when referenced file is deleted, delete self
		required = true,
	},
})

-- get file id
M.get = function()
	local project_path = vim.fn.getcwd()
	local filepath = vim.fn.expand("%:p")
	-- print("project_path: ", project_path)
	local relative_file_path = string.gsub(filepath, project_path, "")
	local file = M.files:where({ path = relative_file_path })
	-- print("file_path: ", vim.inspect(file_path))
	if file == nil then
		-- print("file path is nil")
		return nil
	end
	return file
end

-- create file
M.create = function()
	if projects.get() == nil then
		projects.create()
	end

	local file = M.get()

	if file ~= nil then
		return
	end

	local project_path = vim.fn.getcwd()

	local filepath = vim.fn.expand("%:p")
	local relative_file_path = string.gsub(filepath, project_path, "")
	M.files:insert({ path = relative_file_path, projects = project_path })
end

M.mark_file = function()
	local project_path = vim.fn.getcwd()

	local filepath = vim.fn.expand("%:p")

	local file = M.get()
	if file == nil then
		M.create()
	end

	local relative_file_path = string.gsub(filepath, project_path, "")

	local current_line = util.get_current_line()
	local sign_id = util.add_sign(0, current_line, "FilemarkSign")

	M.files:update({
		where = { path = relative_file_path },
		set = {
			path = relative_file_path,
			projects = project_path,
			lnum = current_line,
			sign_id = sign_id,
			sign = config.options.file_sign,
		},
	})
end

M.unmark_file = function()
	local project_path = vim.fn.getcwd()
	local filepath = vim.fn.expand("%:p")
	local file = M.get()
	if file == nil then
		return
	end
	local relative_file_path = string.gsub(filepath, project_path, "")
	M.files:update({
		where = { path = relative_file_path },
		set = {
			path = relative_file_path,
			projects = project_path,
			lnum = "",
			sign_id = "",
			sign = "",
		},
	})

	vim.fn.sign_unplace("Bookmarks", {
		buffer = vim.api.nvim_buf_get_name(0),
		id = file.sign_id,
		name = "FilemarkSign",
	})
end

M.get_all = function()
	local project_path = vim.fn.getcwd()
	local files = {}
	M.files:each({ where = { projects = project_path } }, function(row)
		table.insert(files, row)
	end)
	return files
end

-- update file
M.update = function()
	print("stub")
end

-- delete file
M.delete = function()
	local file = M.get()
	if file == nil then
		print("No Bookmarks in buffer")
		return
	end
	M.files:remove({ where = { id = file.id } })
end

return M
