local M = {}

local tbl = require("sqlite.tbl") --- for constructing sql tables


M.files = tbl("files", {
	id = true,
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
	local file_path = M.files:where({ path = relative_file_path })
	-- print("file_path: ", vim.inspect(file_path))
	if file_path == nil then
		-- print("file path is nil")
		return nil
	end
	return file_path.id
end

-- create file
M.create = function()
	local file_id = M.get()
	-- print("file_id from create: ", file_id)
	if file_id ~= nil then
		-- print("File already exists")
		return
	end

	local project_path = vim.fn.getcwd()

	local filepath = vim.fn.expand("%:p")
	local file = string.gsub(filepath, project_path, "")
	-- print("project_path: ", project_path)
	M.files:insert({ path = file, projects = project_path })
end

-- update file
M.update = function()
	print("stub")
end

-- delete file
M.delete = function()
	local project_path = vim.fn.getcwd()
	local filepath = vim.fn.expand("%:p")
	local relative_file_path = string.gsub(filepath, project_path, "")
	local file = M.files:where({ path = relative_file_path })
	M.files:remove({ where = { id = file.id } })
end

return M
