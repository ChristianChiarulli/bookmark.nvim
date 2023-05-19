local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
    error("bookmark.nvim requires nvim-telescope/telescope.nvim")
end

return telescope.register_extension({
    exports = {
        filemarks = require("telescope._extensions.filemarks"),
    },
})
