local themelib = {}

-- SET THEME BASED ON TIME OF DAY
function themelib.get_scheme_for_now(current_time)
	local colourscheme_time_chunks = {
		{
			colourscheme = 'tokyonight-storm',
			bg = 'dark',
      lualine_theme = 'lualine.themes.nightfly',
			start_hour = 20,
			start_min = 0,
		},
		{
			colourscheme = 'modus_operandi',
			bg = 'light',
      lualine_theme = 'lualine.themes.gruvbox_light',
			start_hour = 6,
			start_min = 0,
		},
	}
	-- sort the time chunks by start time
	table.sort(colourscheme_time_chunks, function(a, b)
		return a.start_hour > b.start_hour or (a.start_hour == b.start_hour and a.start_min > b.start_min)
	end)

  -- find the current colour scheme
  local curr_chunk = colourscheme_time_chunks[1]
	-- local colourscheme = colourscheme_time_chunks[1].colourscheme
	-- local bg = colourscheme_time_chunks[1].bg
	for _, tc in ipairs(colourscheme_time_chunks) do
		if current_time.hour > tc.start_hour or (current_time.hour == tc.start_hour and current_time.min > tc.start_min) then
      curr_chunk = tc
			break
		end
  end
  return curr_chunk
end

return themelib
