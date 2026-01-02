-- setup lualine (status line)
local mytheme = require 'lualine.themes.nightfly'
require('lualine').setup({
  options = { theme = mytheme },
})
