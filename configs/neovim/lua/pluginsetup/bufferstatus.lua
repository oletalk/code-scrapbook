-- setup lualine (status line)
--DARK
-- local mytheme = require 'lualine.themes.nightfly'
--LIGHT
-- local mytheme = require 'lualine.themes.gruvbox_light'
local themelib = require('config.themelib')

function set_theme()
	local current_time = os.date("*t")
	local themename = themelib.get_scheme_for_now(current_time).lualine_theme
  local mytheme = require( themename )
		
	require('lualine').setup({
		options = { theme = mytheme },
	})
end

set_theme()

--local mytheme = require 'lualine.themes.nightfly'

-- setup quicker (quickfix)
require("quicker").setup()
