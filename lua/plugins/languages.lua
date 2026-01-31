return {
  ---------------------------------------------------------------------------
  -- LSP
  ---------------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    opts = function(_, opts)
      opts = opts or {}

      -- base capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      -- If cmp_nvim_lsp already loaded (InsertEnter happened), extend capabilities.
      -- Do NOT force-load it, otherwise it can pull cmp too early and crash. [web:60][web:61]
      local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if ok and cmp_nvim_lsp then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities) -- merge with defaults [web:60]
      end

      opts.capabilities = capabilities
      opts.servers = opts.servers or {}

      -- Python interpreter: prefer ./venv or ./.venv inside workspace
      local function get_python_path(workspace)
        local p1 = workspace .. "/.venv/bin/python"
        local p2 = workspace .. "/venv/bin/python"
        if vim.fn.executable(p1) == 1 then
          return p1
        end
        if vim.fn.executable(p2) == 1 then
          return p2
        end
        return vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3") or "python"
      end

      opts.servers.pyright = vim.tbl_deep_extend("force", opts.servers.pyright or {}, {
        before_init = function(_, config)
          config.settings = config.settings or {}
          config.settings.python = config.settings.python or {}
          config.settings.python.pythonPath = get_python_path(config.root_dir or vim.fn.getcwd())
        end,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
            },
          },
        },
      })

      opts.servers.rust_analyzer = opts.servers.rust_analyzer or {}
      opts.servers.dartls = opts.servers.dartls or {}

      return opts
    end,
  },

  ---------------------------------------------------------------------------
  -- Completion (CMP)
  ---------------------------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      -- IMPORTANT: keep all cmp sources here so they never load before nvim-cmp. [web:61]
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body) -- required pattern for snippets in nvim-cmp [page:1]
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- DAP core
  ---------------------------------------------------------------------------
  { "mfussenegger/nvim-dap" },

  ---------------------------------------------------------------------------
  -- DAP UI + generic keymaps + Dart adapter
  ---------------------------------------------------------------------------
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

      -- Dart DAP (as you had)
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

      -- Generic DAP keymaps
      vim.keymap.set("n", "<F5>", function()
        dap.continue()
      end, { desc = "DAP continue" })
      vim.keymap.set("n", "<F10>", function()
        dap.step_over()
      end, { desc = "DAP step over" })
      vim.keymap.set("n", "<F11>", function()
        dap.step_into()
      end, { desc = "DAP step into" })
      vim.keymap.set("n", "<F12>", function()
        dap.step_out()
      end, { desc = "DAP step out" })
      vim.keymap.set("n", "<leader>db", function()
        dap.toggle_breakpoint()
      end, { desc = "DAP breakpoint" })
      vim.keymap.set("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "DAP conditional breakpoint" })
      vim.keymap.set("n", "<leader>dr", function()
        dap.repl.toggle()
      end, { desc = "DAP REPL" })
      vim.keymap.set("n", "<leader>du", function()
        dapui.toggle()
      end, { desc = "DAP UI toggle" })
    end,
  },

  ---------------------------------------------------------------------------
  -- Python DAP (debugpy) via nvim-dap-python
  ---------------------------------------------------------------------------
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

      -- Requires debugpy available in that interpreter. [web:2]
      require("dap-python").setup(pick_venv_python()) -- [web:2]
      require("dap-python").test_runner = "pytest" -- supported by plugin [web:2]

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

  ---------------------------------------------------------------------------
  -- Flutter
  ---------------------------------------------------------------------------
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

  ---------------------------------------------------------------------------
  -- Formatting (Conform)
  ---------------------------------------------------------------------------
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      local conform = require("conform")
      opts = opts or {}
      opts.formatters_by_ft = opts.formatters_by_ft or {}

      opts.formatters_by_ft.rust = { "rustfmt" }
      opts.formatters_by_ft.dart = { "dartfmt" }

      -- Prefer ruff_format when available; else isort+black (known conform pattern) [web:7]
      opts.formatters_by_ft.python = function(bufnr)
        if conform.get_formatter_info("ruff_format", bufnr).available then
          return { "ruff_format" }
        end
        return { "isort", "black" }
      end

      opts.format_on_save = function(bufnr)
        if vim.bo[bufnr].filetype == "python" then
          return { lsp_fallback = true, timeout_ms = 2000 }
        end
      end

      return opts
    end,
  },

  ---------------------------------------------------------------------------
  -- Toggleterm + Flutter helpers
  ---------------------------------------------------------------------------
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup({
        direction = "horizontal",
        size = 15,
      })

      local Terminal = require("toggleterm.terminal").Terminal

      local smallTerm = Terminal:new({
        direction = "horizontal",
        size = 10,
        hidden = true,
      })

      vim.keymap.set("n", "<leader>ft", function()
        smallTerm:toggle()
      end, { desc = "Small terminal (10 lines)" })

      _G.flutterTerm = _G.flutterTerm or nil

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
          close_on_exit = true,
        })
        pubTerm:open()
      end, {})

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
