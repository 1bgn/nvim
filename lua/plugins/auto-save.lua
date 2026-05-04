return {
  "okuuva/auto-save.nvim",
  cmd = "ASToggle",
  event = { "InsertLeave", "TextChanged" },
  opts = {
    debounce_delay = 1000,
    condition = function(buf)
      -- не сохраняем пока в insert mode — иначе форматтер смещает курсор
      if vim.fn.mode() == "i" then
        return false
      end
      if not vim.bo[buf].modifiable then
        return false
      end
      return true
    end,
  },
  keys = {
    { "<leader>ua", "<cmd>ASToggle<CR>", desc = "Toggle autosave" },
  },
}
