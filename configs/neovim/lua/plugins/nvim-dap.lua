return {
    'mfussenegger/nvim-dap',
    keys = function()
      local dap = require("dap")
      return {
        { "<leader><Down>", dap.step_over, desc = "Step Over" },
        { "<leader><Right>", dap.step_into, desc = "Step Into" },
        { "<leader><Left>", dap.step_out, desc = "Step Out" },
        { "<leader><Up>", dap.restart_frame, desc = "Restart Frame" },
        { "<F9>", dap.toggle_breakpoint, desc = "Toggle Breakpoint" },
      }
    end
}
