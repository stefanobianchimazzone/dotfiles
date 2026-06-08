local map = vim.keymap.set

-- #### General ####

map('i', 'jk', '<Esc>', { noremap = true, silent = true })
map('n', '<leader>nh', '<Cmd>nohl<CR>', { desc = 'Clear search highlights' })
map('n', '<leader>+', '<C-a>', { desc = 'Increment number' })
map('n', '<leader>-', '<C-x>', { desc = 'Decrement number' })

-- #### Window management ####

map('n', '<leader>sv', '<C-w>v', { desc = 'Split window vertically' })
map('n', '<leader>sh', '<C-w>s', { desc = 'Split window horizontally' })
map('n', '<leader>se', '<C-w>=', { desc = 'Make splits equal size' })
map('n', '<leader>sx', '<Cmd>close<CR>', { desc = 'Close current split' })

-- #### Tabs ####

map('n', '<leader>to', '<Cmd>tabnew<CR>', { desc = 'Open new tab' })
map('n', '<leader>tx', '<Cmd>tabclose<CR>', { desc = 'Close current tab' })
map('n', '<leader>tn', '<Cmd>tabn<CR>', { desc = 'Next tab' })
map('n', '<leader>tp', '<Cmd>tabp<CR>', { desc = 'Previous tab' })
map('n', '<leader>tf', '<Cmd>tabnew %<CR>', { desc = 'Open buffer in new tab' })

-- #### File explorer (MiniFiles) ####

map('n', '<leader>ed', function() MiniFiles.open(vim.uv.cwd()) end, { desc = 'Open file explorer (cwd)' })
map('n', '<leader>ef', function() MiniFiles.open(vim.api.nvim_buf_get_name(0)) end, { desc = 'Open file explorer (current file)' })

-- #### Fuzzy find (Telescope) ####

local builtin = function(name, opts)
  return function() require('telescope.builtin')[name](opts or {}) end
end

map('n', '<leader>ff', builtin('find_files'), { desc = 'Find files' })
map('n', '<leader>fr', builtin('oldfiles'), { desc = 'Find recent files' })
map('n', '<leader>fs', builtin('live_grep'), { desc = 'Find string (live grep)' })
map('n', '<leader>fc', builtin('grep_string'), { desc = 'Find string under cursor' })
map('n', '<leader>fb', builtin('buffers'), { desc = 'Find buffers' })
map('n', '<leader>fh', builtin('help_tags'), { desc = 'Find help' })
map('n', '<leader>fk', builtin('keymaps'), { desc = 'Find keymaps' })
map('n', '<leader>fm', builtin('commands'), { desc = 'Find commands' })
map('n', '<leader>fd', builtin('diagnostics', { bufnr = 0 }), { desc = 'Find diagnostics (buffer)' })
map('n', '<leader>fD', builtin('diagnostics'), { desc = 'Find diagnostics (all)' })
map('n', '<leader>ft', '<Cmd>TodoTelescope<CR>', { desc = 'Find TODOs' })

-- #### LSP (set via LspAttach) ####

Config.new_autocmd('LspAttach', '*', function(ev)
  local buf = ev.buf
  local lmap = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
  end

  local tb = require('telescope.builtin')
  lmap('n', 'gd', tb.lsp_definitions, 'Go to definition')
  lmap('n', 'gD', vim.lsp.buf.declaration, 'Go to declaration')
  lmap('n', 'gR', tb.lsp_references, 'LSP references')
  lmap('n', 'gi', tb.lsp_implementations, 'Go to implementation')
  lmap('n', 'gt', tb.lsp_type_definitions, 'Type definition')
  lmap('n', 'K', vim.lsp.buf.hover, 'Hover documentation')
  lmap({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, 'Code action')
  lmap('n', '<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
  lmap('n', '<leader>D', function() tb.diagnostics({ bufnr = 0 }) end, 'Buffer diagnostics')
  lmap('n', '<leader>d', vim.diagnostic.open_float, 'Line diagnostics')
end, 'LSP keybindings')

-- #### Git ####

map('n', '<leader>go', function() MiniDiff.toggle_overlay() end, { desc = 'Toggle diff overlay' })
map('n', '<leader>gs', function() MiniGit.show_at_cursor() end, { desc = 'Git show at cursor' })

-- #### Formatting ####

map({ 'n', 'v' }, '<leader>mp', function()
  require('conform').format({ lsp_fallback = true, async = false, timeout_ms = 1000 })
end, { desc = 'Format file or range' })

-- #### Lazygit ####

Config.open_lazygit = function()
  vim.cmd('tabedit')
  vim.cmd('setlocal nonumber signcolumn=no')
  vim.fn.termopen('lazygit', {
    on_exit = function()
      vim.cmd('silent! :checktime')
      vim.cmd('silent! :bw')
    end,
  })
  vim.cmd('startinsert')
  vim.b.minipairs_disable = true
end
map('n', '<leader>lg', Config.open_lazygit, { desc = 'Lazygit' })

-- #### Leader group clues (consumed by mini.clue) ####

Config.leader_group_clues = {
  { mode = 'n', keys = '<Leader>c', desc = '+Code' },
  { mode = 'n', keys = '<Leader>d', desc = '+Diagnostics' },
  { mode = 'n', keys = '<Leader>e', desc = '+Explore' },
  { mode = 'n', keys = '<Leader>f', desc = '+Find' },
  { mode = 'n', keys = '<Leader>g', desc = '+Git' },
  { mode = 'n', keys = '<Leader>l', desc = '+Lazygit' },
  { mode = 'n', keys = '<Leader>m', desc = '+Format' },
  { mode = 'n', keys = '<Leader>n', desc = '+Notifications' },
  { mode = 'n', keys = '<Leader>r', desc = '+Rename' },
  { mode = 'n', keys = '<Leader>s', desc = '+Split' },
  { mode = 'n', keys = '<Leader>t', desc = '+Tab' },
}
