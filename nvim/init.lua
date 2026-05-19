vim.loader.enable()

-- runtime ftplugin/python.vim calls has('python3') which spawns a process to check for pynvim — skip it
vim.g.loaded_python3_provider = 0

-- Leader key (must be before any keymaps)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- ==========================================================================
-- Options
-- ==========================================================================
local opt = vim.opt

opt.relativenumber = true
opt.number = true
opt.wrap = true
opt.linebreak = true
opt.cursorline = true

opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

opt.ignorecase = true
opt.smartcase = true

opt.termguicolors = true
opt.background = 'dark'
opt.signcolumn = 'yes'

opt.backspace = 'indent,eol,start'
opt.clipboard:append('unnamedplus')

opt.splitright = true
opt.splitbelow = true

-- ==========================================================================
-- Keymaps
-- ==========================================================================
local map = vim.keymap.set

map('i', 'jk', '<ESC>', { desc = 'Exit insert mode' })

-- <C-j/k/h/l> for moving lines/blocks handled by mini.move

map('n', '<leader>nh', ':nohl<CR>', { desc = 'Clear search highlights', silent = true })

map('n', '<leader>+', '<C-a>', { desc = 'Increment number' })
map('n', '<leader>-', '<C-x>', { desc = 'Decrement number' })

map('n', '<leader>sv', '<C-w>v', { desc = 'Split vertically' })
map('n', '<leader>sh', '<C-w>s', { desc = 'Split horizontally' })
map('n', '<leader>se', '<C-w>=', { desc = 'Equal splits' })
map('n', '<leader>sx', '<cmd>close<CR>', { desc = 'Close split' })

map('n', '<leader>bn', '<cmd>bnext<CR>', { desc = 'Next buffer' })
map('n', '<leader>bp', '<cmd>bprevious<CR>', { desc = 'Previous buffer' })
map('n', '<leader>bx', '<cmd>bdelete<CR>', { desc = 'Close buffer' })


-- ==========================================================================
-- Diagnostics
-- ==========================================================================
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

-- ==========================================================================
-- LSP
-- ==========================================================================
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }

    opts.desc = 'Show LSP references'
    map('n', 'gR', '<cmd>Telescope lsp_references<CR>', opts)

    opts.desc = 'Go to declaration'
    map('n', 'gD', vim.lsp.buf.declaration, opts)

    opts.desc = 'Show LSP definitions'
    map('n', 'gd', '<cmd>Telescope lsp_definitions<CR>', opts)

    opts.desc = 'Show LSP implementations'
    map('n', 'gi', '<cmd>Telescope lsp_implementations<CR>', opts)

    opts.desc = 'Show LSP type definitions'
    map('n', 'gt', '<cmd>Telescope lsp_type_definitions<CR>', opts)

    opts.desc = 'Code actions'
    map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)

    opts.desc = 'Rename symbol'
    map('n', '<leader>rn', vim.lsp.buf.rename, opts)

    opts.desc = 'Buffer diagnostics'
    map('n', '<leader>D', '<cmd>Telescope diagnostics bufnr=0<CR>', opts)

    opts.desc = 'Line diagnostics'
    map('n', '<leader>d', vim.diagnostic.open_float, opts)

    opts.desc = 'Previous diagnostic'
    map('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, opts)

    opts.desc = 'Next diagnostic'
    map('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, opts)

    opts.desc = 'Hover documentation'
    map('n', 'K', vim.lsp.buf.hover, opts)

    opts.desc = 'Restart LSP'
    map('n', '<leader>rs', function()
      vim.lsp.stop_client(vim.lsp.get_clients({ bufnr = ev.buf }))
      vim.defer_fn(function() vim.cmd('edit') end, 500)
    end, opts)
  end,
})

vim.lsp.config('*', {
  capabilities = {
    textDocument = {
      hover = { contentFormat = { 'markdown', 'plaintext' } },
    },
  },
})

vim.api.nvim_create_autocmd('LspAttach', {
  once = true,
  callback = function()
    local orig_open = vim.lsp.util.open_floating_preview
    vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
      opts = opts or {}
      opts.border = opts.border or 'rounded'
      return orig_open(contents, syntax, opts, ...)
    end
  end,
})

vim.lsp.config('pyright', {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
  settings = {
    python = {
      analysis = {
        typeCheckingMode = 'basic',
      },
    },
  },
})

vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.stylua.toml', 'stylua.toml', '.git' },
  settings = {
    Lua = {
      diagnostics = { globals = { 'vim' } },
      completion = { callSnippet = 'Replace' },
      runtime = { version = 'LuaJIT' },
      workspace = {
        library = { vim.env.VIMRUNTIME },
      },
    },
  },
})

vim.lsp.config('gopls', {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_markers = { 'go.mod', 'go.work', '.git' },
  settings = {
    gopls = {
      analyses = { unusedparams = true },
      staticcheck = true,
    },
  },
})

vim.lsp.enable({ 'pyright', 'lua_ls', 'gopls' })

-- ==========================================================================
-- Post-install hooks (must be before vim.pack.add)
-- ==========================================================================
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if name == 'nvim-treesitter' and (kind == 'install' or kind == 'update') then
      if not ev.data.active then
        vim.cmd.packadd('nvim-treesitter')
      end
      vim.cmd('TSUpdate')
    elseif name == 'telescope-fzf-native.nvim' and (kind == 'install' or kind == 'update') then
      local dir = ev.data.spec.path
      vim.fn.system({ 'make', '-C', dir })
    end
  end,
})

-- ==========================================================================
-- Plugins (vim.pack)
-- ==========================================================================
vim.pack.add({
  'https://github.com/echasnovski/mini.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  { src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim', name = 'telescope-fzf-native.nvim' },
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/mfussenegger/nvim-lint',
  'https://github.com/folke/tokyonight.nvim',
  'https://github.com/obsidian-nvim/obsidian.nvim',
  'https://github.com/kdheepak/lazygit.nvim',
})

-- Colorscheme (load immediately after plugins)
local transparent = true
local bg = '#011628'
local bg_dark = '#011423'
local bg_highlight = '#143652'
local bg_search = '#0A64AC'
local bg_visual = '#275378'
local fg = '#CBE0F0'
local fg_dark = '#B4D0E9'
local fg_gutter = '#627E97'
local border = '#547998'

require('tokyonight').setup({
  style = 'night',
  transparent = transparent,
  styles = {
    sidebars = transparent and 'transparent' or 'dark',
    floats = transparent and 'transparent' or 'dark',
  },
  on_colors = function(colors)
    colors.bg = bg
    colors.bg_dark = transparent and colors.none or bg_dark
    colors.bg_float = transparent and colors.none or bg_dark
    colors.bg_highlight = bg_highlight
    colors.bg_popup = bg_dark
    colors.bg_search = bg_search
    colors.bg_sidebar = transparent and colors.none or bg_dark
    colors.bg_statusline = transparent and colors.none or bg_dark
    colors.bg_visual = bg_visual
    colors.border = border
    colors.fg = fg
    colors.fg_dark = fg_dark
    colors.fg_float = fg
    colors.fg_gutter = fg_gutter
    colors.fg_sidebar = fg_dark
  end,
})

vim.cmd('colorscheme tokyonight')
