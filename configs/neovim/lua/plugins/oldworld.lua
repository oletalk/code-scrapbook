return {
  "dgox16/oldworld.nvim",
  priority = 1000,
  config = function()
    require("oldworld").setup({
      variant = "oled",
    })
  end,
}
