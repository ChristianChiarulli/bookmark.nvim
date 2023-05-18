vim.cmd([[
]])

vim.cmd([[
  " Datastore commands 
  command! ProjectCreate lua require'bookmark.datastore.project_tbl'.create()
  command! ProjectGet lua require'bookmark.datastore.project_tbl'.get()
  command! ProjectUpdate lua require'bookmark.datastore.project_tbl'.update()
  command! ProjectDelete lua require'bookmark.datastore.project_tbl'.delete()

  command! FileCreate lua require'bookmark.datastore.file_tbl'.create()
  command! FileGet lua require'bookmark.datastore.file_tbl'.get()
  command! FileUpdate lua require'bookmark.datastore.file_tbl'.update()
  command! FileDelete lua require'bookmark.datastore.file_tbl'.delete()

  command! BookmarkCreate lua require'bookmark.datastore.bookmark_tbl'.create()
  command! BookmarkGet lua require'bookmark.datastore.bookmark_tbl'.get()
  command! BookmarkUpdate lua require'bookmark.datastore.bookmark_tbl'.update()
  command! BookmarkDelete lua require'bookmark.datastore.bookmark_tbl'.delete()

  " Action commands
  command! BookmarkToggle lua require'bookmark.action'.toggle()
  command! BookmarkNext lua require'bookmark.action'.next()
  command! BookmarkPrev lua require'bookmark.action'.previous()
  command! BookmarkList lua require'bookmark.action'.list_buffer_qf()
]])
