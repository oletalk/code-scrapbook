-- YOUR OWN KEYBINDINGS
-- if you want to set other plugin options, see nvim/lua/config/lazy.lua
-- understand vim keymaps by going here https://www.meetgor.com/vim-keymaps/
-- tl;dr  you press ] then 't' in normal ('n') mode

-- rename a variable (lsp-aware)
vim.keymap.set('n', '<leader>R', ':lua vim.lsp.buf.rename()<CR>' )

-- show list of current-open buffers (using snacks/picker):
vim.keymap.set('n', '<leader>B', ':lua Snacks.picker.buffers()<CR>' )

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

--  vim.keymap.set('n', '<leader>fu', ':lua require("telescope.builtin").lsp_references()<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fu', ':lua vim.lsp.buf.references()<CR>', { noremap = true, silent = true })

