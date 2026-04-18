local themelib = {}

-- SET THEME BASED ON TIME OF DAY
function themelib.get_scheme_for_now(current_time)
  local dark_chunk = {
    -- colourscheme = 'catppuccin-mocha',
    -- colourscheme = 'oasis-starlight',
    colourscheme = 'sora',
    bg = 'dark',
    lualine_theme = 'lualine.themes.nightfly',
    start_hour = 16,
    start_min = 0,
  }
  local evening_chunk = {
    colourscheme = 'vimbones',
    bg = 'light',
    lualine_theme = 'lualine.themes.gruvbox_light'
  }
  local light_chunk = {
    -- colourscheme = 'catppuccin-latte',
    colourscheme = 'modus_operandi',
    bg = 'light',
    lualine_theme = 'lualine.themes.onelight',
    start_hour = 6,
    start_min = 0,
  }
  f = io.open('/home/colin/.config/nvim/light.theme.txt')
  if not f then
    f = io.open('/home/colin/.config/nvim/evening.theme.txt')
    if f then
      return evening_chunk
    else
      return dark_chunk
    end
  else
    f:close()
    return light_chunk
  end
end

return themelib
