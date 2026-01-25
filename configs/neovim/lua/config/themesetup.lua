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

local themelib = require("config.themelib")

function set_colourscheme(current_time)
  local curr_chunk = themelib.get_scheme_for_now(current_time)
	vim.cmd('colorscheme ' .. curr_chunk.colourscheme)
	vim.cmd('set background=' .. curr_chunk.bg)
end

local current_time = os.date("*t")
set_colourscheme(current_time)

--DARK
-- vim.cmd.colourscheme "catppuccin"
--vim.cmd.colourscheme "tokyonight-storm"

--LIGHT
--vim.cmd.colourscheme "modus_operandi"
