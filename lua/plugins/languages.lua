return {
  -- LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        rust_analyzer = {},
        pyright = {},
        dartls = {},
      },
    },
  },

  -- Автодополнение
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
    },
  },

  -- DAP
  { "mfussenegger/nvim-dap" },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      dap.adapters.python = {
        type = "executable",
        command = "python3",
        args = { "-m", "debugpy.adapter" },
      }
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
        },
      }

      dap.adapters.dart = {
        type = "executable",
        command = "dart",
        args = { "debug_adapter" },
      }
      dap.configurations.dart = {
        {
          type = "dart",
          request = "launch",
          name = "Launch Dart/Flutter",
          program = "${workspaceFolder}/lib/main.dart",
        },
      }
    end,
  },

  -- Flutter
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
            dart = {
              analysisExcludedFolders = { "build" },
            },
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

  -- Форматирование
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        rust = { "rustfmt" },
        python = { "black", "isort" },
        dart = { "dartfmt" },
      },
    },
  },

  -- Быстрый Flutter-терминал + hot reload

  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup({
        direction = "horizontal",
        size = 15,
      })

      local Terminal = require("toggleterm.terminal").Terminal

      -- Маленький терминал по <leader>ft
      local smallTerm = Terminal:new({
        direction = "horizontal",
        size = 10,
        hidden = true,
      })

      vim.keymap.set("n", "<leader>ft", function()
        smallTerm:toggle()
      end, { desc = "Small terminal (10 lines)" })

      -- Глобальный flutter терминал
      _G.flutterTerm = _G.flutterTerm or nil

      -- Команда: FlutterQuickRun
      vim.api.nvim_create_user_command("FlutterQuickRun", function()
        if not _G.flutterTerm then
          _G.flutterTerm = Terminal:new({
            cmd = "flutter run",
            direction = "horizontal",
            hidden = true,
            close_on_exit = false,
            count = 99,
          })
        end
        _G.flutterTerm:open()
        vim.cmd("wincmd p")
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
      end, {})
      vim.api.nvim_create_user_command("FlutterPubGet", function()
        local pubTerm = Terminal:new({
          cmd = "flutter pub get",
          direction = "horizontal",
          close_on_exit = true, -- закроется после выполнения
        })
        pubTerm:open()
      end, {})

      -- Команда: FlutterQuickRestart
      vim.api.nvim_create_user_command("FlutterQuickRestart", function()
        if _G.flutterTerm then
          _G.flutterTerm:shutdown()
          _G.flutterTerm:close()
          _G.flutterTerm = nil
        end
        vim.defer_fn(function()
          _G.flutterTerm = Terminal:new({
            cmd = "flutter run",
            direction = "horizontal",
            hidden = true,
            close_on_exit = false,
            count = 99,
          })
          _G.flutterTerm:open()
          vim.cmd("wincmd p")
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
        end, 100)
      end, {})

      -- Автокоманда: Hot reload при сохранении .dart файла
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*.dart",
        callback = function()
          if _G.flutterTerm and _G.flutterTerm:is_open() then
            _G.flutterTerm:send("r\n")
            vim.notify("🔥 Hot reload sent to Flutter", vim.log.levels.INFO)
          end
        end,
      })
    end,
  },
}
