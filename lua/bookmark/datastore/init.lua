local M = {}

local sqlite = require("sqlite")
local uri = os.getenv("HOME") .. "/test_db"

M.projects = require("bookmark.datastore.project_tbl")
M.files = require("bookmark.datastore.file_tbl")
M.bookmarks = require("bookmark.datastore.bookmark_tbl")

sqlite({
	uri = uri,
	projects = M.projects.projects,
	files = M.files.files,
	bookmarks = M.bookmarks.bookmarks,
	opts = {},
})

return M
