-- ~/.config/nvim/lua/plugins/lsp.lua
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

      opts.servers.rust_analyzer = opts.servers.rust_analyzer or {}
      opts.servers.dartls = opts.servers.dartls or {}

      return opts
    end,
  },
}
