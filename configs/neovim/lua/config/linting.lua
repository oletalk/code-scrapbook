require('lint').linters_by_ft = {
	go = {'golangcilint'},
  json = {'yq'},
  javascript = {'biomejs'},
  typescriptreact = {'biomejs'},
	python = {'ruff'},
  xml = {'yq'},
  yaml = {'yq'}
}
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
  callback = function()

    -- try_lint without arguments runs the linters defined in `linters_by_ft`
    -- for the current filetype
    require("lint").try_lint()

  end,
})
