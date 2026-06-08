local now, now_if_args, later = Config.now, Config.now_if_args, Config.later

-- #### Immediate (now) ####

now(function()
  require('mini.basics').setup({
    options = { basic = false },
    mappings = { windows = true, move_with_alt = false },
    autocommands = { relnum_in_visual_mode = true },
  })
end)

now(function()
  require('mini.icons').setup()
  later(MiniIcons.mock_nvim_web_devicons)
  later(MiniIcons.tweak_lsp_kind)
end)

now(function() require('mini.notify').setup() end)

now(function() require('mini.starter').setup() end)

now(function() require('mini.statusline').setup() end)

now(function() require('mini.tabline').setup() end)

-- #### Immediate if args (now_if_args) ####

now_if_args(function()
  require('mini.misc').setup({ make_global = { 'put', 'put_text' } })
  MiniMisc.setup_auto_root()
  MiniMisc.setup_restore_cursor()
  MiniMisc.setup_termbg_sync()
end)

now_if_args(function()
  local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }
  local process_items = function(items, base)
    return MiniCompletion.default_process_items(items, base, process_items_opts)
  end
  require('mini.completion').setup({
    lsp_completion = { source_func = 'omnifunc', auto_setup = false, process_items = process_items },
  })

  local on_attach = function(args) vim.bo[args.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp' end
  Config.new_autocmd('LspAttach', '*', on_attach, 'Set omnifunc for LSP completion')
  vim.lsp.config('*', { capabilities = MiniCompletion.get_lsp_capabilities() })
end)

now_if_args(function()
  require('mini.files').setup({ windows = { preview = true } })

  Config.new_autocmd('User', 'MiniFilesExplorerOpen', function()
    MiniFiles.set_bookmark('c', vim.fn.stdpath('config'), { desc = 'Config' })
    MiniFiles.set_bookmark('p', vim.fn.stdpath('data') .. '/site/pack/core/opt', { desc = 'Plugins' })
    MiniFiles.set_bookmark('w', vim.fn.getcwd, { desc = 'Working directory' })
  end, "MiniFiles bookmarks")
end)

-- #### Deferred (later) ####

later(function() require('mini.extra').setup() end)

later(function()
  local ai = require('mini.ai')
  ai.setup({
    custom_textobjects = {
      B = MiniExtra.gen_ai_spec.buffer(),
      F = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),
      o = ai.gen_spec.treesitter({ a = '@block.outer', i = '@block.inner' }),
    },
    search_method = 'cover',
  })
end)

later(function() require('mini.bracketed').setup() end)

later(function() require('mini.bufremove').setup() end)

later(function()
  local miniclue = require('mini.clue')
  miniclue.setup({
    clues = {
      Config.leader_group_clues,
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.square_brackets(),
      miniclue.gen_clues.windows({ submode_resize = true }),
      miniclue.gen_clues.z(),
    },
    triggers = {
      { mode = { 'n', 'x' }, keys = '<Leader>' },
      { mode = { 'n', 'x' }, keys = '[' },
      { mode = { 'n', 'x' }, keys = ']' },
      { mode = 'i', keys = '<C-x>' },
      { mode = { 'n', 'x' }, keys = 'g' },
      { mode = { 'n', 'x' }, keys = "'" },
      { mode = { 'n', 'x' }, keys = '`' },
      { mode = { 'n', 'x' }, keys = '"' },
      { mode = { 'i', 'c' }, keys = '<C-r>' },
      { mode = 'n', keys = '<C-w>' },
      { mode = { 'n', 'x' }, keys = 'z' },
    },
  })
end)

later(function() require('mini.comment').setup() end)

later(function() require('mini.cursorword').setup() end)

later(function() require('mini.diff').setup() end)

later(function() require('mini.git').setup() end)

later(function()
  local hipatterns = require('mini.hipatterns')
  local hi_words = MiniExtra.gen_highlighter.words
  hipatterns.setup({
    highlighters = {
      fixme = hi_words({ 'FIXME', 'Fixme', 'fixme' }, 'MiniHipatternsFixme'),
      hack = hi_words({ 'HACK', 'Hack', 'hack' }, 'MiniHipatternsHack'),
      todo = hi_words({ 'TODO', 'Todo', 'todo' }, 'MiniHipatternsTodo'),
      note = hi_words({ 'NOTE', 'Note', 'note' }, 'MiniHipatternsNote'),
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end)

later(function() require('mini.indentscope').setup() end)

later(function()
  require('mini.keymap').setup()
  MiniKeymap.map_multistep('i', '<Tab>', { 'pmenu_next' })
  MiniKeymap.map_multistep('i', '<S-Tab>', { 'pmenu_prev' })
  MiniKeymap.map_multistep('i', '<CR>', { 'pmenu_accept', 'minipairs_cr' })
  MiniKeymap.map_multistep('i', '<BS>', { 'minipairs_bs' })
end)

later(function()
  require('mini.move').setup({
    mappings = {
      left = '<C-h>', right = '<C-l>', down = '<C-j>', up = '<C-k>',
      line_left = '<C-h>', line_right = '<C-l>', line_down = '<C-j>', line_up = '<C-k>',
    },
    options = { reindent_linewise = false },
  })
end)

later(function() require('mini.operators').setup() end)

later(function() require('mini.pairs').setup({ modes = { insert = true, command = true, terminal = false } }) end)

later(function() require('mini.splitjoin').setup() end)

later(function() require('mini.surround').setup() end)

later(function() require('mini.trailspace').setup() end)

later(function() require('mini.visits').setup() end)
