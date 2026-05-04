-- ~/.config/nvim/lua/config/keymaps.lua
local deps = require("utils.deps")

-- Терминал рядом с Flutter консолью (справа от неё на том же уровне)
vim.keymap.set("n", "<leader>ft", function()
  local flutter_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_get_name(buf):match("__FLUTTER_DEV_LOG__") then
      flutter_win = win
      break
    end
  end

  if flutter_win then
    vim.api.nvim_set_current_win(flutter_win)
    vim.cmd("vsplit | terminal")
    vim.cmd("startinsert")
  else
    Snacks.terminal(nil, { cwd = LazyVim.root(), win = { position = "bottom", height = 14 } })
  end
end, { desc = "Terminal beside Flutter log" })

-- Проектный grep без падений
vim.keymap.set("n", "<leader>/", function()
  if deps.has("rg") then
    -- LazyVim направит это в текущий picker (snacks/telescope/fzf) [web:108]
    LazyVim.pick("live_grep")()
    return
  end

  -- fallback: встроенный :vimgrep (медленнее, но кросс-окружение и без внешних бинари) [web:93]
  vim.ui.input({ prompt = "Search (vimgrep, no rg) > " }, function(q)
    if not q or q == "" then
      return
    end
    vim.cmd("silent! vimgrep /" .. vim.fn.escape(q, "/\\") .. "/gj **/*")
    vim.cmd("copen")
  end)

  vim.notify("ripgrep (rg) not found; used vimgrep fallback.\n" .. deps.install_hint({ "rg" }), vim.log.levels.WARN)
end, { desc = "Search in project" })

-- Flutter pub get (только в dart файлах чтобы не конфликтовать с LazyVim)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "dart",
  callback = function(ev)
    vim.keymap.set("n", "<leader>Fp", ":FlutterPubGet<CR>", { buffer = ev.buf, desc = "Flutter: pub get" })
  end,
})

vim.keymap.set({ "n", "t" }, "<c-/>", function()
  Snacks.terminal(nil, { cwd = LazyVim.root(), win = { position = "float" } })
end, { desc = "Floating terminal" })

vim.keymap.set("t", "<Esc>", function()
  local config = vim.api.nvim_win_get_config(0)
  if config.relative ~= "" then
    vim.cmd("close")
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
  end
end, { desc = "Exit terminal mode / close float" })

vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode", noremap = true })

-- Сигнатура функции только по требованию
vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })
