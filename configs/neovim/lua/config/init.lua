-- ALL CONFIG EXCEPT LAZY INIT

-- setup themes
require("config.themesetup")
-- setup formatting (conform, format-on-save)
require("config.formatting")
-- setup linting
require("config.linting")
-- setup diagnostics
require("config.diagnostics")
-- setup LSP (including endhints)
require "lsp"
-- setup DAP (debug adapters)
require("config.dapsetup")
-- keybindings
require("config.keybindings")
require("config.keybindings-plugins")

-- python virtual environments with swenv
require("config.virtualenvs")
