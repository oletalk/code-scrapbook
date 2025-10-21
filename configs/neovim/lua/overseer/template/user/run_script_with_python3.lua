-- /home/stevearc/.config/nvim/lua/overseer/template/user/run_script.lua
return {
  name = "run script with Python 3",
  builder = function()
    local file = vim.fn.expand("%:p")
    local cmd = { "python3", file }
    return {
      cmd = cmd,
      components = {
        { "on_output_quickfix", set_diagnostics = true },
        "on_result_diagnostics",
        "default",
      },
    }
  end,
  condition = {
    filetype = { "python" },
  },
}
