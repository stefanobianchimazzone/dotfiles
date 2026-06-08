local add = vim.pack.add
local now_if_args, later = Config.now_if_args, Config.later

vim.api.nvim_create_user_command('PackUpdate', function() vim.pack.update() end, {})

-- Tree-sitter ================================================================
now_if_args(function()
  local ts_update = function() vim.cmd('TSUpdate') end
  Config.on_packchanged('nvim-treesitter', { 'update' }, ts_update, ':TSUpdate')
  add({
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
  })

  local ensure_languages = {
    'bash', 'c', 'dockerfile', 'go', 'gitignore', 'json', 'lua', 'markdown', 'markdown_inline',
    'python', 'rust', 'toml', 'yaml', 'vim', 'vimdoc', 'query', 'diff',
  }
  local isnt_installed = function(lang)
    return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0
  end
  local to_install = vim.tbl_filter(isnt_installed, ensure_languages)
  if #to_install > 0 then require('nvim-treesitter').install(to_install) end

  vim.treesitter.language.register('bash', 'zsh')

  local filetypes = vim.iter(ensure_languages):map(vim.treesitter.language.get_filetypes):flatten():totable()
  Config.new_autocmd('FileType', filetypes, function(ev)
    vim.treesitter.start(ev.buf)

    vim.wo.foldmethod = 'expr'
    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo.foldlevel = 99

    local ft = vim.bo[ev.buf].filetype
    if not vim.tbl_contains({ 'python', 'yaml', 'markdown' }, ft) then
      vim.bo[ev.buf].indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
    end
  end, 'Enable treesitter with folding and indentation')

  -- Incremental selection via native treesitter node selection
  local function get_node_range(node)
    local sr, sc, er, ec = node:range()
    return sr, sc, er, ec
  end

  local selection_node = nil

  vim.keymap.set('n', '<C-space>', function()
    local node = vim.treesitter.get_node()
    if not node then return end
    selection_node = node
    local sr, sc, er, ec = get_node_range(node)
    vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
    vim.cmd('normal! v')
    vim.api.nvim_win_set_cursor(0, { er + 1, ec - 1 })
  end, { desc = 'Start node selection' })

  vim.keymap.set('x', '<C-space>', function()
    if not selection_node then return end
    local parent = selection_node:parent()
    if not parent then return end
    selection_node = parent
    local sr, sc, er, ec = get_node_range(parent)
    vim.cmd('normal! \027')
    vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
    vim.cmd('normal! v')
    vim.api.nvim_win_set_cursor(0, { er + 1, ec - 1 })
  end, { desc = 'Expand to parent node' })

  vim.keymap.set('x', '<BS>', function()
    if not selection_node then return end
    local child = selection_node:child(0)
    if not child then return end
    selection_node = child
    local sr, sc, er, ec = get_node_range(child)
    vim.cmd('normal! \027')
    vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
    vim.cmd('normal! v')
    vim.api.nvim_win_set_cursor(0, { er + 1, ec - 1 })
  end, { desc = 'Shrink to child node' })
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
      layout_strategy = 'vertical',
      layout_config = { vertical = { preview_height = 0.4 } },
      path_display = { 'smart' },
      mappings = {
        i = {
          ['<C-k>'] = actions.move_selection_previous,
          ['<C-j>'] = actions.move_selection_next,
          ['<C-e>'] = actions.preview_scrolling_down,
          ['<C-y>'] = actions.preview_scrolling_up,
          ['<C-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
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
  local vault_path = vim.fn.expand('~/.brain-vault')
  require('conform').setup({
    default_format_opts = { lsp_format = 'fallback' },
    formatters_by_ft = {
      c = { 'clang-format' },
      go = { 'goimports' },
      json = { 'prettier' },
      lua = { 'stylua' },
      markdown = { 'prettier' },
      python = { 'isort', 'black' },
      rust = { 'rustfmt' },
      yaml = { 'prettier' },
    },
    format_on_save = function(bufnr)
      local path = vim.api.nvim_buf_get_name(bufnr)
      if path:find(vault_path, 1, true) then
        return false
      end
      return { lsp_fallback = true, async = false, timeout_ms = 3000 }
    end,
  })
end)

-- Linting ====================================================================
later(function()
  add({ 'https://github.com/mfussenegger/nvim-lint' })
end)

-- Obsidian ===================================================================
later(function()
  add({
    'https://github.com/obsidian-nvim/obsidian.nvim',
    'https://github.com/nvim-lua/plenary.nvim',
  })
end)

-- Native LSP =================================================================
now_if_args(function()
  vim.lsp.enable({ 'lua_ls', 'pyright', 'gopls', 'rust_analyzer', 'clangd' })
end)
