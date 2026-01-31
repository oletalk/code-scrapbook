local themelib = {}

-- SET THEME BASED ON TIME OF DAY
function themelib.get_scheme_for_now(current_time)
  
	local dark_chunk = {
			-- colourscheme = 'tokyonight-storm',
			colourscheme = 'oldworld',
			bg = 'dark',
      lualine_theme = 'lualine.themes.nightfly',
			start_hour = 16,
			start_min = 0,
	}
	local light_chunk = {
			-- colourscheme = 'catppuccin-latte',
			colourscheme = 'modus_operandi',
			bg = 'light',
      lualine_theme = 'lualine.themes.gruvbox_light',
			start_hour = 6,
			start_min = 0,
	}
  f = io.open('/home/colin/.config/nvim/light.theme.txt')
  if not f then
    return dark_chunk
  else
    f:close()
    return light_chunk
  end
end

return themelib
