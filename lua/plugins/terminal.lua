-- ~/.config/nvim/lua/plugins/terminal.lua
return {
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup({
        direction = "horizontal",
        size = 15,
      })

      local Terminal = require("toggleterm.terminal").Terminal

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
        Terminal:new({
          cmd = "flutter pub get",
          direction = "horizontal",
          close_on_exit = true,
        }):open()
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
          if _G.flutterTerm and _G.flutterTerm.is_open and _G.flutterTerm:is_open() then
            _G.flutterTerm:send("r\n")
            vim.notify("Hot reload sent to Flutter", vim.log.levels.INFO)
          end
        end,
      })
    end,
  },
}
