require("config.lazy")

-- basic vim formatting stuff
vim.o.expandtab = true
vim.o.number = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
-- vim.o.autochdir = true

vim.g.transparent_enabled = true

-- run plugin setups (n.b. plugins found/loaded in lua/plugins)
require "pluginsetup"
-- filetype hacks for docker compose files
require("filetype")
-- all config EXCEPT lazy init
require "config"
