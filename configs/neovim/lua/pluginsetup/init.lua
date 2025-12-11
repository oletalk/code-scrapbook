-- setup lualine (status line)
local mytheme = require 'lualine.themes.nightfly'
require('lualine').setup({
  options = { theme = mytheme },
})

-- setup overseer (run jobs like your cargo build...)
require('overseer').setup({
  templates = { "builtin", "user.run_go_module", "user.run_script", "user.run_script_with_python3", "user.build_go_module" },
  strategy = "toggleterm",
})

-- setup bufferline
vim.opt.termguicolors = true
require("bufferline").setup({
  options = {
    separator_style = "thin"
  },
})

-- setup refactoring
require('refactoring').setup({
})

-- Configure toggleterm (in-nvim terminal)
require("toggleterm").setup {
  open_mapping = [[<c-#>]]
}

-- Configure neogit
require("neogit").setup({
  kind = "vsplit",
  signs = {
    section = { "", "" },
    item = { "", "" },
    hunk = { "", "" },
  },
  integrations = { diffview = true, fzf_lua = true },
})
