return {
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    config = function()
      require("crates").setup({
        completion = {
          cmp = { enabled = true },
          crates = { enabled = true, max_results = 8, min_chars = 3 },
        },
        lsp = {
          enabled = true,
          actions = true,
          completion = true,
          hover = true,
        },
      })

      vim.keymap.set("n", "<leader>ct", require("crates").toggle, { desc = "Crates: toggle" })
      vim.keymap.set("n", "<leader>cr", require("crates").reload, { desc = "Crates: reload" })
      vim.keymap.set("n", "<leader>cu", require("crates").update_crate, { desc = "Crates: update" })
      vim.keymap.set("n", "<leader>cU", require("crates").upgrade_crate, { desc = "Crates: upgrade" })
      vim.keymap.set("n", "<leader>ca", require("crates").update_all_crates, { desc = "Crates: update all" })
      vim.keymap.set("n", "<leader>cA", require("crates").upgrade_all_crates, { desc = "Crates: upgrade all" })
      vim.keymap.set("n", "<leader>cv", require("crates").show_versions_popup, { desc = "Crates: versions" })
      vim.keymap.set("n", "<leader>cf", require("crates").show_features_popup, { desc = "Crates: features" })
      vim.keymap.set("n", "<leader>cd", require("crates").show_dependencies_popup, { desc = "Crates: deps" })
    end,
  },
}
