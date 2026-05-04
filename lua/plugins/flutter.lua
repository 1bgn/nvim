-- ~/.config/nvim/lua/plugins/flutter.lua
return {
  {
    "akinsho/flutter-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
    config = function()
      -- Глобальные функции для кнопок в winbar dev_log
      _G._ft_reload  = function() vim.cmd("FlutterReload") end
      _G._ft_restart = function() vim.cmd("FlutterRestart") end
      _G._ft_quit    = function() vim.cmd("FlutterQuit") end

      -- Добавляем winbar с кнопками когда открывается Flutter dev_log
      vim.api.nvim_create_autocmd("BufWinEnter", {
        callback = function(ev)
          local name = vim.api.nvim_buf_get_name(ev.buf):lower()
          if name:match("flutter") and name:match("log") then
            vim.wo.winbar =
              "  Flutter  " ..
              "%#DiagnosticOk#%@v:lua._ft_reload@  Reload %X%#Normal#" ..
              "  " ..
              "%#DiagnosticWarn#%@v:lua._ft_restart@  Restart %X%#Normal#" ..
              "  " ..
              "%#DiagnosticError#%@v:lua._ft_quit@ 󰓛 Quit %X%#Normal#"
          end
        end,
      })

      -- Flutter кейбинды только в dart файлах — не конфликтуют с LazyVim
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "dart",
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "<leader>Fe", "<cmd>FlutterEmulators<cr>", vim.tbl_extend("force", opts, { desc = "Flutter: emulators" }))
          vim.keymap.set("n", "<leader>Fd", "<cmd>FlutterDevices<cr>", vim.tbl_extend("force", opts, { desc = "Flutter: devices" }))
          vim.keymap.set("n", "<leader>Fr", "<cmd>FlutterRun<cr>", vim.tbl_extend("force", opts, { desc = "Flutter: run" }))
          vim.keymap.set("n", "<leader>FR", "<cmd>FlutterReload<cr>", vim.tbl_extend("force", opts, { desc = "Flutter: hot reload" }))
          vim.keymap.set("n", "<leader>FS", "<cmd>FlutterRestart<cr>", vim.tbl_extend("force", opts, { desc = "Flutter: hot restart" }))
          vim.keymap.set("n", "<leader>Fq", "<cmd>FlutterQuit<cr>", vim.tbl_extend("force", opts, { desc = "Flutter: quit" }))
          vim.keymap.set("n", "<leader>Fl", "<cmd>FlutterLogClear<cr>", vim.tbl_extend("force", opts, { desc = "Flutter: clear log" }))
          vim.keymap.set("n", "<leader>Fo", "<cmd>FlutterOutlineToggle<cr>", vim.tbl_extend("force", opts, { desc = "Flutter: outline" }))
        end,
      })

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
              analysisExcludedFolders = { "build" },
              showTodos = true,
              completeFunctionCalls = true,
              renameFilesWithClasses = "prompt",
              enableSnippets = true,
            },
          },
        },
        debugger = {
          enabled = true,
          run_via_dap = false,
          exception_breakpoints = {},
        },
      })
    end,
  },
}
