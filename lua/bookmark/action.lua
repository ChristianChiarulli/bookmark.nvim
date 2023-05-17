local db = require("bookmark.datastore")

local bookmarks = db.bookmarks

local M = {}

function M.toggle()
	local bookmark = bookmarks.get()
	-- print(vim.inspect(bookmark))

	if bookmark == nil then
		-- print("creating bookmark")
		bookmarks.create()
	else
		bookmarks.delete()
	end
end

function M.next_buf()
	print("stub")
end

function M.previous_buf()
	print("stub")
end

function M.next_prj()
	print("stub")
end

function M.previous_prj()
	print("stub")
end

function M.list()
	print("stub")
end

function M.clear_buffer()
	print("stub")
end

function M.clear_project()
	print("stub")
end

function M.annotate()
	print("stub")
end

function M.change_icon()
	print("stub")
end

function M.mark_file()
	print("stub")
end

function M.mark_search()
	-- usecase search for function mark lines, search is free can move between functions
	local search_term = vim.fn.getreg("/")
	local line_numbers = {}
	local line_number = vim.fn.search(search_term, "cn")

	while line_number ~= 0 do
		table.insert(line_numbers, line_number)
		line_number = vim.fn.search(search_term, "cn")
	end

	for _, line in ipairs(line_numbers) do
		print(line)
	end
end

function M.export_buf_annotations()
	print("stub")
end

function M.export_prj_annotations()
	print("stub")
end

return M
