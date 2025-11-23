-- Configure conform formatter
require("conform").setup({
	formatters_by_ft = {
		css = { "biome" },
		go = { "gofmt" },
		json = { "jq" },
		javascript = { "biome" },
		typescript = { "biome" },
		python = { "black" },
		rust = { "rustfmt", lsp_format = "fallback" },
		xml = { "xmlstarlet" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback"
	},
})
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})

