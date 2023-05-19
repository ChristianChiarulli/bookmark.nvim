local api = require("nvim-tree.api")
local Event = api.events.Event

local db = require("bookmark.datastore")
local files = db.files

api.events.subscribe(Event.NodeRenamed, function(data)
	local project_path = vim.fn.getcwd()
	local old_relative_file_path = string.gsub(data.old_name, project_path, "")
	local new_relative_file_path = string.gsub(data.new_name, project_path, "")
	local file = files.get_by_path(project_path, old_relative_file_path)
	if file == nil then
		return
	end
	local new_file = vim.deepcopy(file)
	new_file.path = new_relative_file_path
	files.update(file, new_file)
end)

api.events.subscribe(Event.FileRemoved, function(data)
	local project_path = vim.fn.getcwd()
	local old_relative_file_path = string.gsub(data.fname, project_path, "")
	local file = files.get_by_path(project_path, old_relative_file_path)
	files.delete_by_id(file.id)
end)

-- TODO: maybe
-- Event.FolderRemoved
