require("config.lazy")

-- basic vim formatting stuff
vim.o.expandtab = true
vim.o.number = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2

-- transparent background
vim.cmd [[
  highlight Normal guibg=none
  highlight NonText guibg=none
  highlight Normal ctermbg=none
  highlight NonText ctermbg=none
]]

-- setup formatting (conform, format-on-save)
require("config.formatting")
-- setup LSP (including endhints)
require("lsp.initialsetup")
-- setup DAP (debug adapters)
require("config.dapsetup")
-- keybindings
require("config.keybindings")
require("config.keybindings-plugins")

-- python virtual environments with swenv
require("config.virtualenvs")

-- setup lualine (status line)
require('lualine').setup()

-- setup aerial
require("aerial").setup({
  -- optionally use on_attach to set keymaps when aerial has attached to a buffer
  on_attach = function(bufnr)
    -- Jump forwards/backwards with '{' and '}'
    vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
    vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
  end,
})
-- You probably also want to set a keymap to toggle aerial
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")
