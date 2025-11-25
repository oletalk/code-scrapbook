return {
	name = "go build",
  builder = function()
		local file = vim.fn.expand("%:p")
		return {
			cmd = { "go", "build" },
			-- attach a component to the task that will pipe the output to quickfix
			components = { { "on_output_quickfix", open = true }, "default" },
		}
  end,
  -- only available for go files
  condition = {
		filetype = { "gomod" },
  },
}
