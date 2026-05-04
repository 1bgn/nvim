return {
  {
    "akinsho/flutter-tools.nvim",
    ft = "dart",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
    keys = {
      { "<leader>Fe", "<cmd>FlutterEmulators<cr>",     desc = "Flutter: emulators" },
      { "<leader>Fd", "<cmd>FlutterDevices<cr>",       desc = "Flutter: devices" },
      { "<leader>Fr", "<cmd>FlutterRun<cr>",           desc = "Flutter: run" },
      { "<leader>FR", "<cmd>FlutterReload<cr>",        desc = "Flutter: hot reload" },
      { "<leader>FS", "<cmd>FlutterRestart<cr>",       desc = "Flutter: hot restart" },
      { "<leader>Fq", "<cmd>FlutterQuit<cr>",          desc = "Flutter: quit" },
      { "<leader>Fl", "<cmd>FlutterLogClear<cr>",      desc = "Flutter: clear log" },
      { "<leader>Fo", "<cmd>FlutterOutlineToggle<cr>", desc = "Flutter: outline" },
    },
    config = function()
      require("flutter-tools").setup({
        widget_guides = { enabled = true },
        closing_tags = { enabled = true, highlight = "Comment", prefix = " // " },
        dev_log = { enabled = true, notify_errors = true, open_cmd = "botright 12split" },
        lsp = {
          color = {
            enabled = true,
            background = true,
            virtual_text = true,
            virtual_text_str = "■",
          },
          settings = {
            dart = {
              analysisExcludedFolders = { "build", ".dart_tool", ".pub-cache" },
              showTodos = true,
              completeFunctionCalls = true,
              renameFilesWithClasses = "prompt",
              enableSnippets = true,
            },
          },
        },
        debugger = { enabled = false },
      })

      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*.dart",
        callback = function()
          vim.schedule(function()
            pcall(vim.cmd, "FlutterReload")
          end)
        end,
      })
    end,
  },
}