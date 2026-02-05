-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
local deps = require("utils.deps")

vim.api.nvim_create_user_command("DepsCheck", function()
  deps.ensure({ "rg", "fd", "git" }, { ok_notify = true })
end, { desc = "Check external dependencies (rg/fd/git)" })

-- Один раз предупредить, если нет rg (иначе поиск по проекту будет падать у многих пикеров).
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    deps.ensure({ "rg" })
  end,
})
