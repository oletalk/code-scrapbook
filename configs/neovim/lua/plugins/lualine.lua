return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      sections = {
        lualine_a = { 
					{ 
            'swenv', 
            icon = "🀀",
            color = { bg = "#2596be" },
          } 
        }, -- uses default options
        lualine_b = {
					{
						'filetype',
						colored = true,
						icon_only = false,
						padding = 1,
          }
        },
        lualine_x = { 'swenv' } -- passing lualine component options
      }
    }
}
