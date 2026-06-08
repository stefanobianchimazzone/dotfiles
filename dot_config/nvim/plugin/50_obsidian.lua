local later = Config.later

later(function()
  local vault_path = vim.fn.expand('~/.brain-vault')

  if vim.fn.isdirectory(vault_path) == 0 then
    return
  end

  require('obsidian').setup({
    legacy_commands = false,
    workspaces = {
      {
        name = 'brain',
        path = vault_path,
      },
    },
    daily_notes = {
      folder = '01-daily',
      date_format = '%Y-%m-%d',
    },
    notes_subdir = '00-inbox',
    new_notes_location = 'notes_subdir',
    templates = {
      folder = '.brain/templates',
    },
    completion = {
      nvim_cmp = false,
      min_chars = 0,
    },
  })

  Config.new_autocmd('FileType', 'markdown', function()
    local path = vim.fn.expand('%:p')
    if path:find(vault_path, 1, true) then
      vim.opt_local.conceallevel = 2
    else
      vim.opt_local.conceallevel = 1
    end
  end, 'Set conceallevel for Obsidian vault')

  local map = vim.keymap.set
  map('n', '<leader>oo', '<cmd>Obsidian quick_switch<cr>', { desc = 'Find note' })
  map('n', '<leader>os', '<cmd>Obsidian search<cr>', { desc = 'Search vault' })
  map('n', '<leader>ot', '<cmd>Obsidian today<cr>', { desc = "Today's daily note" })
  map('n', '<leader>on', '<cmd>Obsidian new<cr>', { desc = 'New note' })
  map('n', '<leader>ob', '<cmd>Obsidian backlinks<cr>', { desc = 'Backlinks' })
  map('n', '<leader>oc', '<cmd>Obsidian toggle_checkbox<cr>', { desc = 'Toggle checkbox' })
  map('n', '<leader>ol', '<cmd>Obsidian links<cr>', { desc = 'Links in note' })
  map('n', '<leader>og', '<cmd>Obsidian tags<cr>', { desc = 'Find by tag' })
  map('n', '<leader>or', '<cmd>Obsidian rename<cr>', { desc = 'Rename note' })
  map('n', '<leader>op', '<cmd>Obsidian template<cr>', { desc = 'Insert template' })
end)
