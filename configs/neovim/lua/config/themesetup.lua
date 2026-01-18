-- setup for catppuccin
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
-- no setup for tokyonight

-- vim.cmd.colorscheme "catppuccin"
vim.cmd.colorscheme "tokyonight-storm"
