vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

-- Lines 
opt.relativenumber = true
opt.number = true
opt.wrap = false
opt.cursorline = true

-- Tabs & indentation
opt.tabstop = 2  -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2  -- 2 spaces for indent width
opt.expandtab = true  -- expand tab to spaces
opt.autoindent = true  -- copy indent from current line when starting new one

-- Search settings
opt.ignorecase = true  -- ignore case when searching
opt.smartcase = true  -- assume case-sensitive when mixed case in search term

-- Colors
opt.termguicolors = true
opt.background = "dark"  -- force dark in colorscheme
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- Backspace
opt.backspace = "indent,eol,start"  -- allows backspace on indent, end of line or insert mode start position

-- Clipboard 
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- Split windows 
opt.splitright = true  -- split vertical window to the right
opt.splitbelow = true  -- split horizontal window to the bottom
