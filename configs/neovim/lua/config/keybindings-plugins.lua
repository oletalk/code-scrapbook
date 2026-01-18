-- KEYBINDINGS
-- if you want to set other plugin options, see nvim/lua/config/lazy.lua
-- understand vim keymaps by going here https://www.meetgor.com/vim-keymaps/
-- tl;dr  you press ] then 't' in normal ('n') mode

-- setup keybindings for Gitsigns
-- your 'Leader' key was setup as [Spacebar] in lazy.lua
require('gitsigns').setup {
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
    -- preview hunk inline
    map('n', '<Leader>hi', gitsigns.preview_hunk_inline)
    -- stage hunk
    map('v', '<Leader>hs', function()
      gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end)
    -- reset hunk
    map('v', '<Leader>hr', function()
      gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end)
  end
}

-- ssetup keybindings for dropbar TEST

local dropbar_api = require('dropbar.api')
vim.keymap.set('n', '<Leader>;', function()
  require('dropbar.api').pick()
end, { desc = 'Pick symbols in winbar' })
-- setup keybindings for treewalker
vim.keymap.set({ 'n', 'v' }, '<C-k>', '<cmd>Treewalker Up<cr>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<C-j>', '<cmd>Treewalker Down<cr>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<C-h>', '<cmd>Treewalker Left<cr>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<C-l>', '<cmd>Treewalker Right<cr>', { silent = true })

-- swapping
vim.keymap.set('n', '<C-S-k>', '<cmd>Treewalker SwapUp<cr>', { silent = true })
vim.keymap.set('n', '<C-S-j>', '<cmd>Treewalker SwapDown<cr>', { silent = true })
vim.keymap.set('n', '<C-S-h>', '<cmd>Treewalker SwapLeft<cr>', { silent = true })
vim.keymap.set('n', '<C-S-l>', '<cmd>Treewalker SwapRight<cr>', { silent = true })

-- setup keybindings for neotest
vim.keymap.set("n", "<F4>", function()
  require('neotest').run.run()
end, { desc = "Run nearest test" })

-- setup keybindings for refactor
vim.keymap.set(
  { "n", "x" },
  "<leader>rr",
  function() require('refactoring').select_refactor({ prefer_ex_cmd = true }) end
)

-- setup keybindings for overseer
vim.keymap.set('n', '<F8>', ':OverseerRun<CR>')
vim.keymap.set('n', '<Leader><F8>', ':OverseerToggle<CR>')

-- setup keybindings for swenv
vim.keymap.set("n", "<Leader>ph", function()
  require('swenv.api').pick_venv()
end, { desc = "Next todo comment" })

-- setup keybindings for goto-preview
vim.keymap.set("n", "<F6>d", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", { noremap = true })
vim.keymap.set("n", "<F6>t", "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>", { noremap = true })
vim.keymap.set("n", "<F6>r", "<cmd>lua require('goto-preview').goto_preview_references()<CR>", { noremap = true })
vim.keymap.set("n", "<F6>q", "<cmd>lua require('goto-preview').close_all_win()<CR>", { noremap = true })
