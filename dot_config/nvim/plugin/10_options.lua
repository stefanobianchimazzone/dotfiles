vim.g.loaded_python3_provider = 0

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- UI
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.wrap = true
vim.o.linebreak = true
vim.o.signcolumn = 'yes'
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.termguicolors = true
vim.o.showmode = false
vim.o.pumheight = 10
vim.o.winborder = 'rounded'

-- Editing
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.undofile = true
vim.o.backspace = 'indent,eol,start'

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = true
vim.o.incsearch = true

-- Clipboard
vim.o.clipboard = 'unnamedplus'

-- Completion
vim.o.completeopt = 'menuone,noselect,fuzzy'

-- Diagnostics
Config.later(function()
  vim.diagnostic.config({
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = ' ',
        [vim.diagnostic.severity.WARN] = ' ',
        [vim.diagnostic.severity.HINT] = '󰠠 ',
        [vim.diagnostic.severity.INFO] = ' ',
      },
    },
    float = { border = 'rounded' },
  })
end)
