local config = require("bookmark.config")
require("bookmark.autocommands")
require("bookmark.commands")

pcall(require, "bookmark.nvimtree")

local M = {}

M.setup = config.setup

return M
