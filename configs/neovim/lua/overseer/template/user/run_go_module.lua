return {
	name = "go run module",
  builder = function()
		return {
			cmd = { "go", "run", "*.go" },
			-- attach a component to the task that will pipe the output to quickfix
			components = { { "on_output_quickfix", open = true }, "default" },
		}
  end,
  -- only available for go files
  condition = {
		filetype = { "go" },
  },
}
