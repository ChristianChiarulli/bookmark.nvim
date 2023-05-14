vim.cmd([[
  command! BookmarkToggle lua require'bookmark.action'.toggle()
  command! BookmarkNext lua require'bookmark.action'.next()
  command! BookmarkPrev lua require'bookmark.action'.previous()
]])
