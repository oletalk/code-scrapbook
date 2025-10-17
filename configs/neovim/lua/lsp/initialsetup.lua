-- Setup vim-lsp-endhints
-- default settings
require("lsp-endhints").setup {
	icons = {
		type = "󰜁 ",
		parameter = "󰏪 ",
		offspec = " ", -- hint kind not defined in official LSP spec
		unknown = " ", -- hint kind is nil
	},
	label = {
		truncateAtChars = 20,
		padding = 1,
		marginLeft = 0,
		sameKindSeparator = ", ",
	},
	extmark = {
		priority = 50,
	},
	autoEnableHints = true,
}
vim.lsp.inlay_hint.enable(true)

-- Enable lsp for ruby
vim.lsp.config['ruby_lsp'] = require("lsp.ruby_lsp")
vim.lsp.enable('ruby_lsp')
-- Enable lsp for go
vim.lsp.config['gopls'] = require("lsp.gopls")
vim.lsp.enable('gopls')
-- Enable lsp for bash
vim.lsp.config['bashls'] = require("lsp.bashls")
vim.lsp.enable('bashls')
-- Enable lsp for python
vim.lsp.config['jedi_language_server'] = require("lsp.jedi_language_server")
vim.lsp.enable('jedi_language_server')
-- Enable lsp for lua
vim.lsp.config['lua_ls'] = require("lsp.lua_ls")
vim.lsp.enable('lua_ls')
