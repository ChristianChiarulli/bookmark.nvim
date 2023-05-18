local M = {}

local tbl = require("sqlite.tbl") --- for constructing sql tables

M.projects = tbl("projects", {
	id = true,
	path = { "text", unique = true, required = true },
})

-- get project id
M.get = function()
	local path = vim.fn.getcwd()
	local project = M.projects:where({ path = path })
	-- print("project: ", vim.inspect(project))
	if project == nil then
		-- print("project is nil")
		return nil
	end
	return project.id
end

-- TODO: remove OS specific path info replace with ~
-- create project
M.create = function()
	local project_id = M.get()
	-- print("project_id from create: ", project_id)
	if project_id ~= nil then
		-- print("Project already exists")
		return
	end

	local path = vim.fn.getcwd()
	M.projects:insert({ path = path })
end

-- update_project
M.update = function()
	local path = vim.fn.getcwd()
	local project = M.projects:where({ path = path })
	M.projects:update({
		where = { id = project.id },
		set = { path = path },
	})
end

-- delete project
M.delete = function()
	local path = vim.fn.getcwd()
	local project = M.projects:where({ path = path })

	local project_id = M.get()

	if project_id == nil then
		print("No Bookmarks in project")
		return
	end

	M.projects:remove({ where = { id = project.id } })
end

return M
