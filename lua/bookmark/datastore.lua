local M = {}

local sqlite = require("sqlite")
local tbl = require("sqlite.tbl") --- for constructing sql tables
local uri = os.getenv("HOME") .. "/test_db"

local projects = tbl("projects", {
	id = true,
	path = { "text", required = true },
})

local bookmarks = tbl("bookmarks", {
	id = true,
	project_id = { "integer", references = "projects.id" },
	file_name = { "text", required = true },
	line_numbers = { "text", required = true },
	-- sign_map = { "table", required = true },
})

local db = sqlite({
	uri = uri,
	projects = projects,
	bookmarks = bookmarks,
	opts = {},
})

local function get_project_id(path)
	local project = projects:where({ path = path })
	if project then
		return project.id
	else
		return projects:insert({ path = path })
	end
end

M.get_bookmarks = function()
	local project_id = get_project_id(vim.fn.getcwd())
	local file_name = vim.api.nvim_buf_get_name(0)
	local all = bookmarks:where({ project_id = project_id, file_name = file_name })
	print(vim.inspect(all))
	return all
end

M.does_bookmark_exist = function(line_number)
	local project_id = get_project_id(vim.fn.getcwd())
	local file_name = vim.api.nvim_buf_get_name(0)
	local current_bookmarks = bookmarks:where({ project_id = project_id, file_name = file_name })
	-- print(vim.inspect(current_bookmarks))
	return current_bookmarks
end

M.update_bookmarks = function(id, row)
	print("updating bookmarks")
	bookmarks:update({
		where = { id = id },
		set = row,
	})
end

M.add_bookmark = function(line_number)
	print("adding bookmark")
	local current_bookmarks = M.get_bookmarks()
	print(vim.inspect(current_bookmarks))
	local project_id = get_project_id(vim.fn.getcwd())
	local file_name = vim.api.nvim_buf_get_name(0)

	if current_bookmarks == nil then
		bookmarks:insert({ project_id = project_id, file_name = file_name, line_numbers = line_number .. "" })
	elseif current_bookmarks.line_numbers == "" then
		bookmarks:insert({ project_id = project_id, file_name = file_name, line_numbers = line_number .. "" })
	else
		local bookmarks_id = current_bookmarks.id
		local line_numbers = current_bookmarks.line_numbers .. "," .. line_number
		-- convert line_numbers to table and sort separate by ","
		line_numbers = vim.split(line_numbers, ",")
		-- convert to line_numbers to table of numbers
		line_numbers = vim.tbl_map(function(x)
			return tonumber(x)
		end, line_numbers)
		table.sort(line_numbers)
		-- convert line_numbers back to string
		line_numbers = vim.tbl_map(function(x)
			return tostring(x)
		end, line_numbers)
		line_numbers = table.concat(line_numbers, ",")
		local row = { project_id = project_id, file_name = file_name, line_numbers = line_numbers }
		M.update_bookmarks(bookmarks_id, row)
	end
end

M.delete_bookmark = function(line_number)
	print("deleting bookmark")
	local current_bookmarks = M.get_bookmarks()
	local project_id = get_project_id(vim.fn.getcwd())
	local file_name = vim.api.nvim_buf_get_name(0)
	local bookmarks_id = current_bookmarks.id
	local line_numbers = current_bookmarks.line_numbers
	line_numbers = vim.split(line_numbers, ",")
	line_numbers = vim.tbl_map(function(x)
		return tonumber(x)
	end, line_numbers)

	line_numbers = vim.tbl_filter(function(x)
		return not x == line_number
	end, line_numbers)

	line_numbers = vim.tbl_map(function(x)
		return tostring(x)
	end, line_numbers)
	line_numbers = table.concat(line_numbers, ",")
	local row = { project_id = project_id, file_name = file_name, line_numbers = line_numbers }
	M.update_bookmarks(bookmarks_id, row)
end

M.toggle_bookmark = function(line_number)
	-- check if bookmark exists on current line
	-- if it does, delete it
	-- if it doesn't, add it
	local current_bookmarks = M.get_bookmarks()
	print(vim.inspect(current_bookmarks))

	local bookmark_exists = false

	if current_bookmarks ~= nil then
		local line_numbers = current_bookmarks.line_numbers
		line_numbers = vim.split(line_numbers, ",")
		line_numbers = vim.tbl_map(function(x)
			return tonumber(x)
		end, line_numbers)
		print(vim.inspect(line_numbers))
		for _, v in ipairs(line_numbers) do
			if v == line_number then
				print("bookmark exists")
				bookmark_exists = true
			end
		end
	end

	if bookmark_exists then
		M.delete_bookmark(line_number)
	else
		M.add_bookmark(line_number)
	end
end

vim.api.nvim_command("autocmd VimLeave * lua db:close()")

return M

-- function update_bookmark(id, url, title)
--   db:update("bookmarks", { where = { id = id }, set = { url = url, title = title } })
-- end

-- update_bookmark(1, "https://www.newurl.com", "New Title")

-- function delete_bookmark(id)
--   db:delete("bookmarks", { id = id })
-- end

-- delete_bookmark(1)
