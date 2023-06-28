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

-- get by current path
M.get = function()
	local project_path = vim.fn.getcwd()
	local filepath = vim.fn.expand("%:p")
	local relative_file_path = util.trim_prefix(filepath, project_path)
	local file = M.files:where({ path = relative_file_path, projects = project_path })
	return file
end

-- get by id
M.get_by_id = function(id)
	local file = M.files:where({ id = id })
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
	local relative_file_path = util.trim_prefix(filepath, project_path)
	M.files:insert({ path = relative_file_path, projects = project_path })
end

M.mark_file = function()
	local project_path = vim.fn.getcwd()

	local filepath = vim.fn.expand("%:p")

	local file = M.get()
	if file == nil then
		M.create()
	end

	local relative_file_path = util.trim_prefix(filepath, project_path)

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
	local relative_file_path = util.trim_prefix(filepath, project_path)
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

M.get_by_path = function(project_path, path)
	return M.files:where({ projects = project_path, path = path })
end

M.get_all_marked = function()
	local project_path = vim.fn.getcwd()
	local files = {}
	M.files:each({ where = { projects = project_path } }, function(row)
		if row.sign_id ~= "" and row.sign_id ~= nil then
			table.insert(files, row)
		end
	end)
	return files
end

-- update file
M.update = function(row_old, row_new)
	M.files:update({
		where = { id = row_old.id },
		set = {
			path = row_new.path,
			projects = row_new.projects,
			lnum = row_new.lnum,
			sign_id = row_new.sign_id,
			sign = row_new.sign,
		},
	})
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

M.delete_by_id = function(id)
	M.files:remove({ where = { id = id } })
end

return M
