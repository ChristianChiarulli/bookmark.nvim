local config = require("bookmark.config")
require("bookmark.autocommands")
require("bookmark.commands")

local M = {}

M.setup = config.setup

return M
