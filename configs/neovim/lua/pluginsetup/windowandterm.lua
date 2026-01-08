-- Configure toggleterm (in-nvim terminal)
require("toggleterm").setup {
  open_mapping = [[<c-#>]]
}

-- Configure neogit
require("neogit").setup({
  kind = "vsplit",
  signs = {
    section = { "", "" },
    item = { "", "" },
    hunk = { "", "" },
  },
  integrations = { diffview = true, fzf_lua = true },
})

