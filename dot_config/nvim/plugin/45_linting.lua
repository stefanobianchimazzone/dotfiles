local later = Config.later

later(function()
  local lint = require('lint')

  lint.linters_by_ft = {
    python = { 'pylint' },
    go = { 'golangcilint' },
  }

  lint.linters.pylint.cmd = 'python'
  lint.linters.pylint.args = { '-m', 'pylint', '-f', 'json' }

  Config.new_autocmd({ 'BufReadPost', 'BufWritePost', 'InsertLeave' }, '*', function()
    lint.try_lint()
  end, 'Auto-lint on save/read/leave')

  vim.keymap.set('n', '<leader>ll', function()
    lint.try_lint()
  end, { desc = 'Trigger linting' })
end)
