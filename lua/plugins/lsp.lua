return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    opts = function(_, opts)
      opts = opts or {}
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if ok and cmp_nvim_lsp then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
      end
      opts.capabilities = capabilities
      opts.servers = opts.servers or {}

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
      opts.servers.tailwindcss = {
        filetypes = { "html", "css", "javascript", "typescript", "vue" },
        settings = {
          tailwindCSS = {
            includeLanguages = {
              html = "html",
            },
          },
        },
      }
      -- TypeScript/JavaScript (Nuxt/Vue)
      opts.servers.ts_ls = vim.tbl_deep_extend("force", opts.servers.ts_ls or {}, {
        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
            },
          },
        },
      })

      -- Vue Language Server (обязателен для Nuxt/Vue 3)
      opts.servers.volar = vim.tbl_deep_extend("force", opts.servers.volar or {}, {
        filetypes = { "vue", "typescript", "javascript" },
        init_options = {
          vue = { hybridMode = true }, -- Hybrid Mode: volar для .vue, ts_ls для .ts/.js
        },
      })

      -- ESLint LSP
      opts.servers.eslint = vim.tbl_deep_extend("force", opts.servers.eslint or {}, {
        filetypes = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "vue",
        },
        settings = {
          workingDirectory = { mode = "auto" },
          format = true,
        },
        on_attach = function(_, bufnr)
          -- Автоисправление ESLint при сохранении
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
          })
        end,
      })

      opts.servers.rust_analyzer = vim.tbl_deep_extend("force", opts.servers.rust_analyzer or {}, {
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = { command = "clippy" },
            completion = {
              callable = { snippets = "none" },
            },
            inlayHints = {
              bindingModeHints = { enable = true },
              chainingHints = { enable = true },
              closureReturnTypeHints = { enable = "always" },
              lifetimeElisionHints = { enable = "skip_trivial" },
              typeHints = { enable = true },
              parameterHints = { enable = true },
            },
            procMacro = { enable = true },
            cargo = { allFeatures = true, loadOutDirsFromCheck = true },
            diagnostics = { enable = true, experimental = { enable = true } },
          },
        },
      })

      opts.servers.ruff = vim.tbl_deep_extend("force", opts.servers.ruff or {}, {
        init_options = {
          settings = { lineLength = 100 },
        },
        on_attach = function(client, _)
          -- pyright занимается hover, ruff — lint
          client.server_capabilities.hoverProvider = false
        end,
      })

      opts.servers.dartls = opts.servers.dartls or {}

      return opts
    end,
  },
}
