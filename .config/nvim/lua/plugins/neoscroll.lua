return {
  {
  "karb94/neoscroll.nvim",
  config = function ()
      local neoscroll = require("neoscroll")
      neoscroll.setup({
        easing = "quadratic"
      })
  end,
  },
}
