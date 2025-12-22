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

-- Configure neotree
require("neo-tree").setup({
  default_component_configs = {
    git_status = {
      symbols = {
        -- Change type
        added = "✚",
        modified = "",
        deleted = "✖", -- this can only be used in the git_status source
        renamed = "󰁕", -- this can only be used in the git_status source
        -- Status type
        untracked = "",
        ignored = "",
        unstaged = "󰄱",
        staged = "",
        conflict = "",
      },
    },
  }
})
