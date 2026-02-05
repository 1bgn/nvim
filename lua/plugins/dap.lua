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
