return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      sections = {
        lualine_a = { 
					{
  					'mode'
					},
        },
        lualine_c = { 
					{
  					'swenv',
            icon = "🀀",
            color = { bg = "#2596be" },
					},
        },
        lualine_x = {
          {
						'encoding'
					},
          {
						'fileformat'
					},
  				{
						'filetype',
						colored = true,
						icon_only = false,
						padding = 1,
         },
       },
      }
    }
}
