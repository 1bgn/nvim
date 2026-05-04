-- ~/.config/nvim/lua/plugins/dap.lua
return {
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

      dapui.setup({
        layouts = {
          {
            -- layout 1: минимальный для Flutter — только консоль + кнопки
            elements = { { id = "console", size = 1.0 } },
            size = 8,
            position = "bottom",
          },
          {
            -- layout 2: боковая панель для Rust/Python
            elements = {
              { id = "scopes",      size = 0.4 },
              { id = "breakpoints", size = 0.2 },
              { id = "stacks",      size = 0.2 },
              { id = "watches",     size = 0.2 },
            },
            size = 40,
            position = "left",
          },
          {
            -- layout 3: нижняя панель для Rust/Python
            elements = {
              { id = "repl",    size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 10,
            position = "bottom",
          },
        },
        controls = {
          enabled = true,
          element = "console",  -- кнопки рисуются поверх консоли
        },
      })

      dap.listeners.after.event_initialized["dapui_config"] = function(session)
        if session.config.type == "dart" then
          dapui.open({ layout = 1 })   -- Flutter: только консоль + кнопки снизу
        else
          dapui.open({ layout = 2 })   -- Rust/Python: боковая панель
          dapui.open({ layout = 3 })   -- + нижняя консоль
        end
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Rust: codelldb (mason install: codelldb)
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.exepath("codelldb"),
          args = { "--port", "${port}" },
        },
      }
      dap.configurations.rust = {
        {
          name = "Launch binary",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Binary: ", vim.fn.getcwd() .. "/target/debug/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
        {
          name = "Launch binary (with args)",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Binary: ", vim.fn.getcwd() .. "/target/debug/", "file")
          end,
          args = function()
            local args = vim.fn.input("Args: ")
            return vim.split(args, " ", { trimempty = true })
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
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

      vim.keymap.set("n", "<F5>", dap.continue, { desc = "DAP continue" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP step over" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "DAP step into" })
      vim.keymap.set("n", "<F12>", dap.step_out, { desc = "DAP step out" })
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP breakpoint" })
      vim.keymap.set("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "DAP conditional breakpoint" })
      vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "DAP REPL" })
      vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "DAP UI toggle" })
    end,
  },

  {
    "mfussenegger/nvim-dap-python",
    dependencies = { "mfussenegger/nvim-dap" },
    ft = "python",
    config = function()
      local function pick_venv_python()
        local cwd = vim.fn.getcwd()
        if vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
          return cwd .. "/.venv/bin/python"
        end
        if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
          return cwd .. "/venv/bin/python"
        end
        return "python3"
      end

      require("dap-python").setup(pick_venv_python())
      require("dap-python").test_runner = "pytest"

      vim.keymap.set("n", "<leader>dn", function()
        require("dap-python").test_method()
      end, { desc = "DAP: test method" })
      vim.keymap.set("n", "<leader>df", function()
        require("dap-python").test_class()
      end, { desc = "DAP: test class" })
      vim.keymap.set("v", "<leader>ds", function()
        require("dap-python").debug_selection()
      end, { desc = "DAP: debug selection" })
    end,
  },
}
