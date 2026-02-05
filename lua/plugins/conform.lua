-- ~/.config/nvim/lua/plugins/conform.lua
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      local conform = require("conform")
      opts = opts or {}
      opts.formatters_by_ft = opts.formatters_by_ft or {}

      opts.formatters_by_ft.rust = { "rustfmt" }
      opts.formatters_by_ft.dart = { "dartfmt" }

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
}
