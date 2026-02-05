-- ~/.config/nvim/lua/plugins/flutter.lua
return {
  {
    "akinsho/flutter-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
    config = function()
      require("flutter-tools").setup({
        lsp = {
          settings = {
            dart = { analysisExcludedFolders = { "build" } },
          },
        },
        debugger = {
          enabled = true,
          run_via_dap = true,
          exception_breakpoints = {},
        },
      })
    end,
  },
}
