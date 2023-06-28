local db = require("bookmark.datastore")
local util = require("bookmark.util")
local config = require("bookmark.config")

local bookmarks = db.bookmarks
local files = db.files
local projects = db.projects

local M = {}

function M.toggle()
	-- TODO: filemark should have it's own group
	-- check if filemark on line, delete and replace with bookmark
	local bookmark = bookmarks.get()
	if bookmark == nil then
		bookmarks.create()
	else
		bookmarks.delete()
	end
end

function M.next()
	local bufnr = vim.api.nvim_get_current_buf()
	local group = "Bookmarks"
	local signs = vim.fn.sign_getplaced(bufnr, { group = group })
	local lnums = {}
	for _, sign in ipairs(signs[1].signs) do
		table.insert(lnums, sign.lnum)
	end

	if #lnums == 0 then
		print("No bookmarks")
		return
	end

	if #lnums > 0 then
		table.sort(lnums)
		if #lnums > 0 then
			local next_line = util.next_largest(util.get_current_line(), lnums)
			if next_line == nil then
				next_line = lnums[1]
			end
			vim.api.nvim_win_set_cursor(0, { next_line, 0 })
			vim.api.nvim_command("normal! zz")
		else
			print("No bookmarks")
		end
	else
		print("No bookmarks")
	end
end

function M.previous()
	local bufnr = vim.api.nvim_get_current_buf()
	local group = "Bookmarks"
	local signs = vim.fn.sign_getplaced(bufnr, { group = group })
	local lnums = {}
	for _, sign in ipairs(signs[1].signs) do
		table.insert(lnums, sign.lnum)
	end

	if #lnums == 0 then
		print("No bookmarks")
		return
	end

	if #lnums > 0 then
		table.sort(lnums)
		if #lnums > 0 then
			local next_line = util.next_smallest(util.get_current_line(), lnums)
			if next_line == nil then
				next_line = lnums[#lnums]
			end
			vim.api.nvim_win_set_cursor(0, { next_line, 0 })
			vim.api.nvim_command("normal! zz")
		else
			print("No bookmarks")
		end
	else
		print("No bookmarks")
	end
end

function M.next_file()
	local file_list = files.get_all_marked()

	-- TODO: in future jump to file mark in current buffer if exists
	if #file_list == 0 or #file_list == 1 then
		print("No filemarks")
		return
	end

	table.sort(file_list, function(a, b)
		return a.sign_id < b.sign_id
	end)

	local project_path = vim.fn.getcwd()
	local filepath = vim.fn.expand("%:p")
	local relative_file_path = util.trim_prefix(filepath, project_path)

	local current_sign_id = nil
	local other_sign_ids = {}

	for i = #file_list, 1, -1 do
		local item = file_list[i]
		if item.path == relative_file_path then
			current_sign_id = item.sign_id
			table.remove(file_list, i)
		else
			table.insert(other_sign_ids, item.sign_id)
		end
	end

	local next_file_sign_id = nil

	if current_sign_id == nil then
		next_file_sign_id = file_list[1].sign_id
	else
		next_file_sign_id = util.next_largest(current_sign_id, other_sign_ids)
	end

	if next_file_sign_id == nil then
		next_file_sign_id = file_list[1].sign_id
	end

	local next_file = nil
	for i = #file_list, 1, -1 do
		local item = file_list[i]
		if item.sign_id == next_file_sign_id then
			next_file = item
		end
	end

	vim.api.nvim_command("edit " .. next_file.projects .. next_file.path)
	vim.api.nvim_command("normal! " .. next_file.lnum .. "G")
	vim.api.nvim_command("normal! zz")
end

function M.previous_file()
	local file_list = files.get_all_marked()

	-- TODO: in future jump to file mark in current buffer if exists
	if #file_list == 0 or #file_list == 1 then
		print("No filemarks")
		return
	end

	table.sort(file_list, function(a, b)
		return a.sign_id < b.sign_id
	end)

	local project_path = vim.fn.getcwd()
	local filepath = vim.fn.expand("%:p")
	local relative_file_path = util.trim_prefix(filepath, project_path)

	local current_sign_id = nil
	local other_sign_ids = {}

	for i = #file_list, 1, -1 do
		local item = file_list[i]
		if item.path == relative_file_path then
			current_sign_id = item.sign_id
			table.remove(file_list, i)
		else
			table.insert(other_sign_ids, item.sign_id)
		end
	end

	local next_file_sign_id = nil

	if current_sign_id == nil then
		next_file_sign_id = file_list[#file_list].sign_id
	else
		next_file_sign_id = util.next_smallest(current_sign_id, other_sign_ids)
	end

	if next_file_sign_id == nil then
		next_file_sign_id = file_list[#file_list].sign_id
	end

	local next_file = nil
	for i = #file_list, 1, -1 do
		local item = file_list[i]
		if item.sign_id == next_file_sign_id then
			next_file = item
		end
	end

	vim.api.nvim_command("edit " .. next_file.projects .. next_file.path)
	vim.api.nvim_command("normal! " .. next_file.lnum .. "G")
	vim.api.nvim_command("normal! zz")
end

function M.list_buffer_ll()
	-- do it for the loclist as well
	print("stub")
end

function M.list_buffer_qf()
	vim.fn.setqflist({}, "r")
	-- local bufnr = vim.api.nvim_get_current_buf()
	-- TODO: also handle project wide bookmarks
	local bookmark_list = bookmarks.get_all_file()
	local qf_list = {}
	local path = vim.fn.getcwd()

	for _, item in ipairs(bookmark_list) do
		-- Open the file in a buffer and get the line text
		local file = files.get_by_id(item.files)
		local bufnr = vim.fn.bufadd(path .. file.path)
		vim.fn.bufload(bufnr)
		local line_text = vim.api.nvim_buf_get_lines(bufnr, item.lnum - 1, item.lnum, false)[1]

		table.insert(qf_list, { filename = path .. file.path, lnum = item.lnum, text = item.sign .. " " .. line_text })
	end
	vim.api.nvim_command("copen")

	vim.fn.setqflist(qf_list)
end

function M.clear_buffer()
	local bufnr = vim.api.nvim_get_current_buf()
	vim.fn.sign_unplace("Bookmarks", { buffer = bufnr })
	files.delete()
end

function M.clear_project()
	vim.fn.sign_unplace("Bookmarks")
	projects.delete()
end

function M.annotate()
	print("stub")
end

function M.change_icon()
	print("stub")
end

function M.toggle_filemark()
	local bookmark = bookmarks.get()
	if bookmark ~= nil then
		bookmarks.delete()
	end
	local file = files.get()
	if file == nil then
		files.mark_file()
	elseif file.sign == nil or file.sign == "" then
		files.mark_file()
	else
		files.unmark_file()
	end
end

function M.list_file_marks_qf()
	vim.fn.setqflist({}, "r")
	local file_list = files.get_all()

	local qf_list = {}

	for _, item in ipairs(file_list) do
		-- Open the file in a buffer and get the line text
		if item.sign ~= nil and item.sign ~= "" then
			local bufnr = vim.fn.bufadd(item.projects .. item.path)
			vim.fn.bufload(bufnr)
			local line_text = vim.api.nvim_buf_get_lines(bufnr, item.lnum - 1, item.lnum, false)[1]

			table.insert(
				qf_list,
				{ filename = item.projects .. item.path, lnum = item.lnum, text = item.sign .. " " .. line_text }
			)
		end
	end
	vim.api.nvim_command("copen")

	vim.fn.setqflist(qf_list)
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
