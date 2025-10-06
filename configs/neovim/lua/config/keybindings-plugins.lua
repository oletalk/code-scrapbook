-- KEYBINDINGS
-- if you want to set other plugin options, see nvim/lua/config/lazy.lua
-- understand vim keymaps by going here https://www.meetgor.com/vim-keymaps/
-- tl;dr  you press ] then 't' in normal ('n') mode

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

-- setup keybindings for swenv
vim.keymap.set("n", "<Leader>ph", function()
	require('swenv.api').pick_venv()
end, { desc = "Next todo comment" })
