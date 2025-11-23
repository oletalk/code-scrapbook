require("config.lazy")

-- basic vim formatting stuff
vim.o.expandtab = true
vim.o.number = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.autochdir = true

vim.g.transparent_enabled = true

-- setup theme
require("config.themesetup")
-- setup formatting (conform, format-on-save)
require("config.formatting")
-- setup linting 
require("config.linting")
-- setup diagnostics 
require("config.diagnostics")
-- setup LSP (including endhints)
require("lsp.initialsetup")
-- setup DAP (debug adapters)
require("config.dapsetup")
-- keybindings
require("config.keybindings")
require("config.keybindings-plugins")

-- python virtual environments with swenv
require("config.virtualenvs")

-- setup lualine (status line)
local mytheme = require'lualine.themes.nightfly'
require('lualine').setup({
	options = { theme = mytheme },
})

-- setup overseer (run jobs like your cargo build...)
require('overseer').setup({
  templates = { "builtin", "user.run_script", "user.run_script_with_python3" },
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
