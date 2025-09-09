-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
   { import = "plugins" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

-- Enable lsp for ruby
vim.lsp.config['ruby_lsp'] = require("lsp.ruby_lsp")
vim.lsp.enable('ruby_lsp')
-- Enable lsp for go
vim.lsp.config['gopls'] = require("lsp.gopls")
vim.lsp.enable('gopls')
-- Enable lsp for bash
vim.lsp.config['bashls'] = require("lsp.bashls")
vim.lsp.enable('bashls')

-- Configure toggleterm (in-nvim terminal)
require("toggleterm").setup{
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

-- Configure conform formatter
require("conform").setup({
	formatters_by_ft = {
		go = { "gofmt" },
		json = { "jq" },
		rust = { "rustfmt", lsp_format = "fallback" },
		xml = { "xmlstarlet" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback"
	},
})
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})

-- use catppuccin
require("catppuccin").setup({
	flavour = "mocha",

	color_overrides = {
		mocha = {
			base = "#090909",
			mantle = "#101412",
			crust = "#090909"
		}
	}
})
vim.cmd.colorscheme "catppuccin"
