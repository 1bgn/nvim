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

-- Drag-and-drop из Finder в neo-tree
-- Ghostty передаёт файл как bracketed paste; перехватываем vim.paste
-- только пока neo-tree в фокусе, чтобы не затронуть другие буферы.
local function neo_tree_paste(lines, phase)
  if phase == 2 or phase == 3 then return true end

  local function decode(p)
    p = vim.trim(p)
    p = p:gsub("^file://[^/]*", "")
    p = p:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
    return p
  end

  local paths = {}
  for _, line in ipairs(lines) do
    local p = decode(line)
    if p ~= "" and (vim.fn.filereadable(p) == 1 or vim.fn.isdirectory(p) == 1) then
      table.insert(paths, p)
    end
  end

  if #paths == 0 then return true end

  local ok, manager = pcall(require, "neo-tree.sources.manager")
  if not ok then return true end
  local state = manager.get_state("filesystem")
  local node = state and state.tree and state.tree:get_node()
  if not node then return true end

  local target_dir = node.type == "directory" and node:get_id()
    or vim.fn.fnamemodify(node:get_id(), ":h")

  for _, path in ipairs(paths) do
    local name = vim.fn.fnamemodify(path, ":t")
    local target = target_dir .. "/" .. name
    if vim.fn.filereadable(target) == 1 or vim.fn.isdirectory(target) == 1 then
      vim.notify("Уже существует: " .. name, vim.log.levels.WARN)
    else
      vim.fn.system({ "mv", path, target })
      if vim.v.shell_error == 0 then
        vim.notify(name .. " → " .. target_dir)
      else
        vim.notify("Ошибка перемещения: " .. name, vim.log.levels.ERROR)
      end
    end
  end

  vim.schedule(function()
    manager.refresh("filesystem")
  end)
  return true
end

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function(ev)
    if vim.bo[ev.buf].filetype == "neo-tree" and vim.paste ~= neo_tree_paste then
      vim._neo_tree_saved_paste = vim.paste
      vim.paste = neo_tree_paste
    end
  end,
})

vim.api.nvim_create_autocmd("BufLeave", {
  callback = function(ev)
    if vim.bo[ev.buf].filetype == "neo-tree" and vim._neo_tree_saved_paste then
      vim.paste = vim._neo_tree_saved_paste
      vim._neo_tree_saved_paste = nil
    end
  end,
})

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
