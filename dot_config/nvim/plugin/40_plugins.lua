local add = vim.pack.add
local now_if_args, later = Config.now_if_args, Config.later

-- Tree-sitter ================================================================
now_if_args(function()
  local ts_update = function() vim.cmd('TSUpdate') end
  Config.on_packchanged('nvim-treesitter', { 'update' }, ts_update, ':TSUpdate')
  add({
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
  })

  local ensure_languages = {
    'bash', 'c', 'go', 'json', 'lua', 'markdown', 'markdown_inline',
    'python', 'rust', 'toml', 'yaml', 'vim', 'vimdoc', 'query', 'diff',
  }
  local isnt_installed = function(lang)
    return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0
  end
  local to_install = vim.tbl_filter(isnt_installed, ensure_languages)
  if #to_install > 0 then require('nvim-treesitter').install(to_install) end

  local filetypes = vim.iter(ensure_languages):map(vim.treesitter.language.get_filetypes):flatten():totable()
  Config.new_autocmd('FileType', filetypes, function(ev) vim.treesitter.start(ev.buf) end, 'Enable treesitter')

  -- Incremental selection
  require('nvim-treesitter.configs').setup({
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<C-space>',
        node_incremental = '<C-space>',
        scope_incremental = false,
        node_decremental = '<bs>',
      },
    },
  })
end)

-- Telescope ==================================================================
later(function()
  add({
    'https://github.com/nvim-telescope/telescope.nvim',
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
  })

  Config.on_packchanged('telescope-fzf-native.nvim', { 'install', 'update' }, function()
    require('telescope').load_extension('fzf')
  end, 'Build telescope-fzf-native')

  local telescope = require('telescope')
  local actions = require('telescope.actions')

  telescope.setup({
    defaults = {
      path_display = { 'smart' },
      mappings = {
        i = {
          ['<C-k>'] = actions.move_selection_previous,
          ['<C-j>'] = actions.move_selection_next,
          ['<C-e>'] = actions.preview_scrolling_down,
          ['<C-y>'] = actions.preview_scrolling_up,
        },
      },
    },
  })

  pcall(telescope.load_extension, 'fzf')
end)

-- Todo comments ==============================================================
later(function()
  add({
    'https://github.com/folke/todo-comments.nvim',
    'https://github.com/nvim-lua/plenary.nvim',
  })
  require('todo-comments').setup()
end)

-- Formatting =================================================================
later(function()
  add({ 'https://github.com/stevearc/conform.nvim' })
  require('conform').setup({
    default_format_opts = { lsp_format = 'fallback' },
    formatters_by_ft = {
      c = { 'clang-format' },
      go = { 'gofmt' },
      json = { 'prettier' },
      lua = { 'stylua' },
      markdown = { 'prettier' },
      python = { 'isort', 'black' },
      rust = { 'rustfmt' },
      yaml = { 'prettier' },
    },
  })
end)

-- Native LSP =================================================================
now_if_args(function()
  vim.lsp.enable({ 'lua_ls', 'pyright', 'gopls', 'rust_analyzer', 'clangd' })
end)
