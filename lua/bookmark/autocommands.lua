local db = require("bookmark.datastore")

local bookmarks = db.bookmarks
local files = db.files

local save_bookmark = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local group = "Bookmarks"
  local signs = vim.fn.sign_getplaced(bufnr, { group = group })
  local lnums = {}
  local file = files.get()
  -- print("relative_file_path: ", relative_file_path)
  for _, sign in ipairs(signs[1].signs) do
    if sign.name == "BookmarkSign" then
      table.insert(lnums, sign.lnum)
      bookmarks.update(sign.text, sign.id, sign.lnum, file.id)
    end
  end
end

local save_filemark = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local group = "Bookmarks"
  local signs = vim.fn.sign_getplaced(bufnr, { group = group })
  local lnums = {}
  local file = files.get()
  -- print("relative_file_path: ", relative_file_path)
  for _, sign in ipairs(signs[1].signs) do
    if sign.name == "FilemarkSign" then
      table.insert(lnums, sign.lnum)
      local new_file = vim.deepcopy(file)
      new_file.lnum = sign.lnum
      files.update(file, new_file)
    end
  end
end

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  pattern = "*",
  callback = function()
    save_bookmark()
    save_filemark()
    -- TODO: save filemark
  end,
})

local restore_bookmarks = function()
  local bookmarks_buf = bookmarks.get_all_file()
  for _, bookmark in ipairs(bookmarks_buf) do
    vim.fn.sign_place(
      bookmark.sign_id,
      "Bookmarks",
      "BookmarkSign",
      vim.api.nvim_buf_get_name(0),
      { lnum = bookmark.lnum }
    )
  end
end

local restore_filemark = function()
  local file = files.get()
  if file == nil then
    return
  end

  if file.sign == nil or file.sign == "" then
    return
  end

  vim.fn.sign_place(file.sign_id, "Bookmarks", "FilemarkSign", vim.api.nvim_buf_get_name(0), { lnum = file.lnum })
end

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  pattern = "*",
  callback = function()
    restore_bookmarks()
    restore_filemark()
  end,
})


-- TODO: Delete bookmarks when file is deleted
