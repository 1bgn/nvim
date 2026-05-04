return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "rouge8/neotest-rust",
      "nvim-neotest/neotest-python",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-rust")({
            args = { "--no-capture" },
          }),
          require("neotest-python")({
            dap = { justMyCode = false },
            runner = "pytest",
            python = function()
              local cwd = vim.fn.getcwd()
              for _, venv in ipairs({ ".venv", "venv" }) do
                local py = cwd .. "/" .. venv .. "/bin/python"
                if vim.fn.executable(py) == 1 then
                  return py
                end
              end
              return "python3"
            end,
          }),
        },
        output = { open_on_run = true },
        summary = { animated = true },
      })

      local nt = require("neotest")
      vim.keymap.set("n", "<leader>tt", nt.run.run, { desc = "Test: run nearest" })
      vim.keymap.set("n", "<leader>tf", function() nt.run.run(vim.fn.expand("%")) end, { desc = "Test: run file" })
      vim.keymap.set("n", "<leader>ta", function() nt.run.run(vim.fn.getcwd()) end, { desc = "Test: run all" })
      vim.keymap.set("n", "<leader>ts", nt.summary.toggle, { desc = "Test: summary" })
      vim.keymap.set("n", "<leader>to", function() nt.output.open({ enter = true }) end, { desc = "Test: output" })
      vim.keymap.set("n", "<leader>tl", nt.run.run_last, { desc = "Test: run last" })
      vim.keymap.set("n", "<leader>td", function() nt.run.run({ strategy = "dap" }) end, { desc = "Test: debug nearest" })
    end,
  },
}
