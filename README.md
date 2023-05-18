# 📚 bookmark.nvim
Bookmark and jump between lines in the current file

## Install

```
"ChristianChiarulli/bookmark.nvim"
"kkharji/sqlite.lua"
```

## Setup

```
require("bookmark").setup {
  sign = "",
  highlight = "Function",
}
```

## Commands

```
BookmarkToggle
BookmarkNext
BookmarkPrev
BookmarkPrev
BookmarkList
```

## TODO

- clear all bookmarks
- clear all bookmarks current buffer
- save line data as well
- show in quickfix
- telescope search through buffer bookmarks
- telescope search through all bookmarks
- annotate bookmark
- allow jumping between files
