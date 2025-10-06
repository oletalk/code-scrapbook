require("config.lazy")

-- basic vim formatting stuff
vim.o.expandtab = true
vim.o.number = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2

-- transparent background
vim.cmd [[
  highlight Normal guibg=none
  highlight NonText guibg=none
  highlight Normal ctermbg=none
  highlight NonText ctermbg=none
]]

-- setup formatting (conform, format-on-save)
require("config.formatting")
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
require('lualine').setup()
