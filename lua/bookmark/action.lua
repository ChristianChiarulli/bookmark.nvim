local db = require("bookmark.datastore")
local util = require("bookmark.util")
local config = require("bookmark.config")

local bookmarks = db.bookmarks
local files = db.files
local projects = db.projects

local M = {}

function M.toggle()
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

function M.next_prj()
	print("stub")
end

function M.previous_prj()
	print("stub")
end

function M.list_buffer_ll()
	-- do it for the loclist as well
	print("stub")
end

function M.list_buffer_qf()
	-- local bufnr = vim.api.nvim_get_current_buf()
	-- TODO: also handle project wide bookmarks
	local bookmark_list = bookmarks.get_all_file()
	local qf_list = {}
	local path = vim.fn.getcwd()

	for _, item in ipairs(bookmark_list) do
		-- Open the file in a buffer and get the line text
		local bufnr = vim.fn.bufadd(path .. item.files)
		vim.fn.bufload(bufnr)
		local line_text = vim.api.nvim_buf_get_lines(bufnr, item.lnum - 1, item.lnum, false)[1]

		table.insert(qf_list, { filename = path .. item.files, lnum = item.lnum, text = item.sign .. " " .. line_text })
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
	local file = files.get()
	if file == nil then
		files.mark_file()
	elseif file.sign == nil or file.sign == "" then
		files.mark_file()
	else
		files.unmark_file()
	end
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
