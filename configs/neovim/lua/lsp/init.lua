-- Setup vim-lsp-endhints
-- default settings
require("lsp-endhints").setup {
  icons = {
    type = "󰜁 ",
    parameter = "󰏪 ",
    offspec = " ", -- hint kind not defined in official LSP spec
    unknown = " ", -- hint kind is nil
  },
  label = {
    truncateAtChars = 20,
    padding = 1,
    marginLeft = 0,
    sameKindSeparator = ", ",
  },
  extmark = {
    priority = 50,
  },
  autoEnableHints = true,
}
vim.lsp.inlay_hint.enable(true)

-- enable a bunch of lsps
local lsp_list = { 'docker_language_server', 'ruby_lsp', 'gopls', 'bashls', 'jedi_language_server', 'lua_ls' }

for _, mylsp in ipairs(lsp_list) do
  -- sorry for breaking 'gf' here
  -- lsp configs are in lua/lsp/
  vim.lsp.config[mylsp] = require("lsp." .. mylsp)
  vim.lsp.enable(mylsp)
end

-- 07/12/2025 FIXME this is out here because including this in lsp.lua_ls doesn't seem to work just now
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" } }
    }
  }
})
