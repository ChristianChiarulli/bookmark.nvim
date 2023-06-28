local M = {}

function M.add_sign(id, line, sign_name)
	return vim.fn.sign_place(id, "Bookmarks", sign_name, vim.api.nvim_buf_get_name(0), { lnum = line })
end

function M.get_current_line()
	return vim.api.nvim_win_get_cursor(0)[1]
end

function M.next_largest(num, list)
	local next_largest_num = nil

	for _, v in ipairs(list) do
		if v > num then
			if next_largest_num == nil or v < next_largest_num then
				next_largest_num = v
			end
		end
	end

	return next_largest_num
end

function M.next_smallest(num, list)
	local next_smallest_num = nil
	for _, v in ipairs(list) do
		if v < num then
			if next_smallest_num == nil or v > next_smallest_num then
				next_smallest_num = v
			end
		end
	end
	return next_smallest_num
end

function M.trim_prefix(s, prefix)
	if string.sub(s, 1, #prefix) == prefix then
		return string.sub(s, #prefix + 1)
	end
	return s
end

return M
