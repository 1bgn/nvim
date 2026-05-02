return {
  "okuuva/auto-save.nvim",
  cmd = "ASToggle",
  event = { "InsertLeave", "TextChanged" },
  opts = {
    debounce_delay = 500,
  },
  keys = {
    { "<leader>ua", "<cmd>ASToggle<CR>", desc = "Toggle autosave" },
  },
}
