-- YOUR OWN KEYBINDINGS
-- if you want to set other plugin options, see nvim/lua/config/lazy.lua
-- understand vim keymaps by going here https://www.meetgor.com/vim-keymaps/
-- tl;dr  you press ] then 't' in normal ('n') mode

-- rename a variable (lsp-aware)
vim.keymap.set('n', '<leader>R', ':lua vim.lsp.buf.rename()<CR>' )

-- grep (using snacks/picker):
vim.keymap.set('n', '<leader>pg', ':lua Snacks.picker.grep()<CR>' )
vim.keymap.set('n', '<leader>pl', ':lua Snacks.picker.git_log_line()<CR>' )

-- NeoTree removed as of 04/01/2026
-- Configure snacks-picker
vim.keymap.set('n', '<Leader>t', ':lua Snacks.explorer() <CR>' )

-- open neogit
vim.keymap.set("n", "<Leader>g", function()
  require('neogit').open()
end, { desc = "Open NeoGit" })

-- toggle dapview
vim.keymap.set('n', '<F10>', ':DapViewToggle <CR>' )

-- jump between TODO comments
vim.keymap.set("n", "]t", function()
  require("todo-comments").jump_next()
end, { desc = "Next todo comment" })

vim.keymap.set("n", "[t", function()
  require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })

-- restart lsp if you need to
vim.keymap.set('n', '<F5>', ':LspRestart<CR>' )
