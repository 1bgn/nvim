return {
  "HampusHauffman/block.nvim",
  keys = {
    { "<leader>uB", "<cmd>Block<cr>", desc = "Toggle Block Highlight" },
  },
  config = function()
    require("block").setup({
      percent = 0.8,
      depth = 4,
      automatic = true,
    })
  end,
}
