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
        lualine_x = { 'swenv' } -- passing lualine component options
      }
    }
}
