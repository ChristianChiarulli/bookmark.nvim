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
BookmarkList
BookmarkClear
BookmarkClearProject
```

## TODO

- file mark to jump between different files
- quickfix list for all file marks
- quickfix list of all bookmarks in project
- telescope search through buffer bookmarks
- telescope search through all bookmarks
- telescope search for all filemarks
- annotate bookmarks
- associate marks with git hash

- allow user to specify where DB is saved
- allow jumping between files
- allow user to select from a list of predefined icons
- parameter on create for character
