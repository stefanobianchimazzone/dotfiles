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

now(function()
  local starter = require('mini.starter')
  starter.setup({
    items = {
      starter.sections.recent_files(5, false),
      starter.sections.recent_files(5, true),
      starter.sections.builtin_actions(),
    },
  })
end)

now(function()
  local statusline = require('mini.statusline')

  vim.opt.ruler = false

  local SLANT_RIGHT = '\u{1fb66}'
  local SLANT_LEFT = '\u{1fb5b}'

  local edge_groups = {
    'MiniStatuslineModeNormal',
    'MiniStatuslineModeInsert',
    'MiniStatuslineModeVisual',
    'MiniStatuslineModeReplace',
    'MiniStatuslineModeCommand',
    'MiniStatuslineModeOther',
    'MiniStatuslineDevinfo',
    'MiniStatuslineDiagnostics',
    'MiniStatuslineFileinfo',
  }

  local function rebuild_edge_hls()
    local base_bg = (vim.api.nvim_get_hl(0, { name = 'MiniStatuslineFilename', link = false })).bg
    for _, name in ipairs(edge_groups) do
      local seg_bg = (vim.api.nvim_get_hl(0, { name = name, link = false })).bg
      vim.api.nvim_set_hl(0, name .. '_Edge', { fg = base_bg, bg = seg_bg })
      vim.api.nvim_set_hl(0, name .. '_EdgeR', { fg = seg_bg, bg = base_bg })
    end
  end

  local function ensure_diagnostics_hl()
    local diag = vim.api.nvim_get_hl(0, { name = 'MiniStatuslineDiagnostics', link = false })
    if not diag.bg then
      local devinfo = vim.api.nvim_get_hl(0, { name = 'MiniStatuslineDevinfo', link = false })
      vim.api.nvim_set_hl(0, 'MiniStatuslineDiagnostics', { bg = devinfo.bg, fg = devinfo.fg })
    end
  end

  vim.api.nvim_create_autocmd('ColorScheme', {
    callback = function()
      ensure_diagnostics_hl()
      rebuild_edge_hls()
    end,
  })
  ensure_diagnostics_hl()
  rebuild_edge_hls()

  local function section_venv()
    local venv = vim.env.VIRTUAL_ENV
    if not venv then return '' end
    return '  ' .. vim.fn.fnamemodify(venv, ':t')
  end

  local function section_progress()
    local cur = vim.fn.line('.')
    local total = vim.fn.line('$')
    if cur == 1 then return 'Top' end
    if cur == total then return 'Bot' end
    return math.floor(cur / total * 100) .. '%%'
  end

  statusline.setup({
    use_icons = true,
    content = {
      active = function()
        local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
        local git = statusline.section_git({ trunc_width = 40 })
        local diff = statusline.section_diff({ trunc_width = 75 })
        local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
        local filename = statusline.section_filename({ trunc_width = 140 })
        local filetype = vim.bo.filetype
        local venv = section_venv()
        local progress = section_progress()

        local devinfo = table.concat(vim.tbl_filter(function(s) return s ~= '' end, { git, diff }), ' ')

        local mode_edge = mode_hl .. '_Edge'
        local devinfo_edge = 'MiniStatuslineDevinfo_Edge'
        local diag_edge = 'MiniStatuslineDiagnostics_Edge'
        local fileinfo_edge = 'MiniStatuslineFileinfo_Edge'

        local parts = {}
        local R = SLANT_RIGHT
        local L = SLANT_LEFT

        parts[#parts + 1] = '%#' .. mode_hl .. '# ' .. mode .. ' '
        parts[#parts + 1] = '%#' .. mode_edge .. '#' .. R

        if devinfo ~= '' then
          parts[#parts + 1] = '%#' .. devinfo_edge .. 'R#' .. R
          parts[#parts + 1] = '%#MiniStatuslineDevinfo# ' .. devinfo .. ' '
          parts[#parts + 1] = '%#' .. devinfo_edge .. '#' .. R
        end

        if diagnostics ~= '' then
          parts[#parts + 1] = '%#' .. diag_edge .. 'R#' .. R
          parts[#parts + 1] = '%#MiniStatuslineDiagnostics# ' .. diagnostics .. ' '
          parts[#parts + 1] = '%#' .. diag_edge .. '#' .. R
        end

        parts[#parts + 1] = '%#MiniStatuslineFilename# ' .. filename .. ' '
        parts[#parts + 1] = '%<%='

        if venv ~= '' then
          parts[#parts + 1] = '%#' .. devinfo_edge .. '#' .. L
          parts[#parts + 1] = '%#MiniStatuslineDevinfo#' .. venv .. ' '
          parts[#parts + 1] = '%#' .. devinfo_edge .. 'R#' .. L
        end

        if filetype ~= '' then
          parts[#parts + 1] = '%#' .. fileinfo_edge .. '#' .. L
          parts[#parts + 1] = '%#MiniStatuslineFileinfo# ' .. filetype .. ' '
          parts[#parts + 1] = '%#' .. fileinfo_edge .. 'R#' .. L
        end

        parts[#parts + 1] = '%#' .. mode_edge .. '#' .. L
        parts[#parts + 1] = '%#' .. mode_hl .. '# ' .. progress .. ' '

        return table.concat(parts)
      end,
    },
  })
end)

now(function()
  local tab_fill_bg = 0x011628
  local tab_inactive_bg = 0x1a2b3c
  local tab_inactive_fg = 0x627E97
  local tab_active_bg = 0x275378
  local tab_active_fg = 0xCBE0F0

  vim.api.nvim_set_hl(0, 'TabActive', { fg = tab_active_fg, bg = tab_active_bg, bold = true })
  vim.api.nvim_set_hl(0, 'TabInactive', { fg = tab_inactive_fg, bg = tab_inactive_bg })
  vim.api.nvim_set_hl(0, 'TabFill', {})

  local SLANT_L = '\u{1fb5b}'

  local function tab_sep_hl(name, fg, bg)
    vim.api.nvim_set_hl(0, name, { fg = fg, bg = bg })
    return '%#' .. name .. '#' .. SLANT_L
  end

  function _G.custom_tabline()
    local bufs = {}
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[b].buflisted and vim.bo[b].buftype == '' then
        bufs[#bufs + 1] = b
      end
    end

    local cur = vim.api.nvim_get_current_buf()
    local parts = {}

    for i, b in ipairs(bufs) do
      local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(b), ':t')
      if name == '' then name = '[No Name]' end
      local modified = vim.bo[b].modified and ' +' or ''
      local is_active = (b == cur)
      local cur_bg = is_active and tab_active_bg or tab_inactive_bg
      local tab_hl = is_active and 'TabActive' or 'TabInactive'

      parts[#parts + 1] = '%#' .. tab_hl .. '# ' .. name .. modified .. ' '

      local is_last = (i == #bufs)
      local sep_bg = is_last and 'NONE' or tab_fill_bg

      parts[#parts + 1] = tab_sep_hl('TabSep_' .. i .. 'a', cur_bg, sep_bg)

      if not is_last then
        local next_active = (bufs[i + 1] == cur)
        local next_bg = next_active and tab_active_bg or tab_inactive_bg
        parts[#parts + 1] = tab_sep_hl('TabSep_' .. i .. 'b', tab_fill_bg, next_bg)
      end
    end

    parts[#parts + 1] = '%#TabFill#'
    return table.concat(parts)
  end

  vim.o.tabline = '%!v:lua.custom_tabline()'
  vim.o.showtabline = 2
end)

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
  require('mini.files').setup({
    mappings = {
      go_in_plus = '<CR>',
    },
    windows = {
      preview = true,
      width_preview = 40,
    },
  })

  local function files_open_split(direction)
    local entry = MiniFiles.get_fs_entry()
    if entry and entry.fs_type == 'file' then
      MiniFiles.close()
      vim.cmd(direction .. ' ' .. vim.fn.fnameescape(entry.path))
    end
  end

  Config.new_autocmd('User', 'MiniFilesBufferCreate', function(args)
    local buf = args.data.buf_id
    vim.keymap.set('n', '<C-x>', function() files_open_split('split') end, { buffer = buf, desc = 'Open in horizontal split' })
    vim.keymap.set('n', '<C-v>', function() files_open_split('vsplit') end, { buffer = buf, desc = 'Open in vertical split' })
  end, 'MiniFiles split keymaps')

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

later(function() require('mini.indentscope').setup({ symbol = '┊' }) end)

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
