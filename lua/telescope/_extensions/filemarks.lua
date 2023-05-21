local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local webdevicon = require("nvim-web-devicons")

-- local actions = require("telescope.actions")
-- local action_state = require("telescope.actions.state")

local files = require("bookmark.datastore.file_tbl")

local get_file_list = function()
	local marked_files = files.get_all_marked()
	local file_list = {}
	local current_file = {}
	local project_path = vim.fn.getcwd()
	local filepath = vim.fn.expand("%:p")
	local relative_file_path = string.gsub(filepath, project_path, "")
	for _, file in ipairs(marked_files) do
		if file.path == relative_file_path and file.projects == project_path then
			current_file = { file.path, file.lnum, file.sign_id, file.projects }
		else
			table.insert(file_list, { file.path, file.lnum, file.sign_id, file.projects })
		end
	end
	if current_file[1] ~= nil then
		table.insert(file_list, current_file)
	end
	return file_list
end

local get_file_ext = function(filename)
	local ext = filename:match("^.+(%..+)$")
	if ext == nil then
		return ""
	end
	return ext
end

local get_file_icon = function(filename)
	local ext = get_file_ext(filename)
	print(filename)
	print(ext)
	-- TODO: figure out highlighting
	ext = ext:sub(2)
	local icon, icon_highlight = webdevicon.get_icon(filename, ext, { default = true })
	return icon
end

-- { {
--     id = 4,
--     lnum = 8,
--     path = "/lua/bookmark/telescope/_extensions/bookmark-telescope.lua",
--     projects = "/Users/chris/.local/share/lunarvim/site/pack/lazy/opt/bookmark.nvim",
--     sign = "󱡅",
--     sign_id = 1
--   } }

return function(opts)
	opts = opts or {}
	pickers
		.new(opts, {
			sorter = conf.generic_sorter(opts),
			previewer = conf.grep_previewer(opts),
			prompt_title = "colors",
			finder = finders.new_table({
				results = get_file_list(),
				entry_maker = function(entry)
					return {
						value = entry,
						display = get_file_icon(entry[1]) .. " " .. entry[1]:sub(2) .. ":" .. entry[2],
						ordinal = tostring(entry[1]),
						path = entry[4] .. entry[1],
						lnum = entry[2],
					}
				end,
			}),
		})
		:find()
end

-- colors(require("telescope.themes").get_dropdown({}))
