-- ~/.config/nvim/lua/config/keymaps.lua
local deps = require("utils.deps")

-- Удобный терминал (через Snacks.terminal, раз ты используешь snacks)
vim.keymap.set("n", "<leader>ft", function()
  local ok, _ = pcall(require, "snacks")
  if not ok then
    vim.notify("Snacks not available (disable snacks extras or enable them in :LazyExtras)", vim.log.levels.WARN)
    return
  end
  Snacks.terminal(nil, {
    cwd = LazyVim.root(),
    win = { position = "bottom", height = 14 },
  })
end, { desc = "Terminal (Root Dir, fixed height)" })

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

vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode", noremap = true })
