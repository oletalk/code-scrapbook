-- setup lualine (status line)
local mytheme = require 'lualine.themes.nightfly'
require('lualine').setup({
  options = { theme = mytheme },
})

-- setup bufferline
vim.opt.termguicolors = true
require("bufferline").setup({
  options = {
    separator_style = "thin"
  },
})
