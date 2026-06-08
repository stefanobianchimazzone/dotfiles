Config.now(function()
  vim.pack.add({ 'https://github.com/folke/tokyonight.nvim' })
  require('tokyonight').setup({
    style = 'night',
    transparent = true,
    styles = {
      sidebars = 'transparent',
      floats = 'transparent',
    },
  })
  vim.cmd.colorscheme('tokyonight')
end)
