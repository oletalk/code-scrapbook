-- setup neogit, neoterm and toggleterm
require('pluginsetup.windowandterm')

-- setup lualine(status line at bottom) and bufferline (buffers at top)
require('pluginsetup.bufferstatus')

-- setup overseer (run jobs like your cargo build...)
require('overseer').setup({
  templates = { "builtin", "user.run_go_module", "user.run_script", "user.run_script_with_python3", "user.build_go_module" },
  strategy = "toggleterm",
})

-- setup refactoring
require('refactoring').setup({
})
