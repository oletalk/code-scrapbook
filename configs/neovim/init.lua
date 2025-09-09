require("config.lazy")

-- basic vim formatting stuff
vim.o.expandtab = true
vim.o.number = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2

-- KEYBINDINGS
-- if you want to set other plugin options, see nvim/lua/config/lazy.lua
-- understand vim keymaps by going here https://www.meetgor.com/vim-keymaps/
-- tl;dr  you press ] then 't' in normal ('n') mode

-- open neogit
vim.keymap.set("n", "<Leader>g", function()
  require('neogit').open()
end, { desc = "Open NeoGit" })

-- jump between TODO comments
vim.keymap.set("n", "]t", function()
  require("todo-comments").jump_next()
end, { desc = "Next todo comment" })

vim.keymap.set("n", "[t", function()
  require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })

-- setup keybindings for Gitsigns
-- your 'Leader' key was setup as [Spacebar] in lazy.lua
require('gitsigns').setup{
  on_attach = function(bufnr)
    local gitsigns = require('gitsigns')

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end
    -- blame
    map('n', '<Leader>tb', gitsigns.toggle_current_line_blame)
    -- diff
	  map('n', '<Leader>hd', gitsigns.diffthis)
  end
}

--  vim.keymap.set('n', '<leader>fu', ':lua require("telescope.builtin").lsp_references()<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fu', ':lua vim.lsp.buf.references()<CR>', { noremap = true, silent = true })

-- setup lualine (status line)
require('lualine').setup()
