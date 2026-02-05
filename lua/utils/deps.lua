-- ~/.config/nvim/lua/utils/deps.lua
local M = {}

function M.has(cmd)
  return vim.fn.executable(cmd) == 1
end

function M.sysname()
  return (vim.uv or vim.loop).os_uname().sysname
end

function M.install_hint(cmds)
  cmds = cmds or { "rg", "fd" }
  local sys = M.sysname()

  local want_rg = vim.tbl_contains(cmds, "rg")
  local want_fd = vim.tbl_contains(cmds, "fd")

  if sys == "Darwin" then
    local parts = {}
    if want_rg then
      table.insert(parts, "ripgrep")
    end
    if want_fd then
      table.insert(parts, "fd")
    end
    return "macOS: brew install " .. table.concat(parts, " ")
  end

  if sys == "Linux" then
    if want_fd then
      return "Linux: apt install ripgrep fd-find  (или pacman -S ripgrep fd)"
    end
    return "Linux: apt install ripgrep  (или pacman -S ripgrep)"
  end

  if sys:match("Windows") then
    return "Windows: winget install BurntSushi.ripgrep sharkdp.fd"
  end

  return "Install ripgrep (rg) and fd using your OS package manager"
end

function M.missing(cmds)
  local missing = {}
  for _, c in ipairs(cmds) do
    if not M.has(c) then
      table.insert(missing, c)
    end
  end
  return missing
end

function M.ensure(cmds, opts)
  opts = opts or {}
  local missing = M.missing(cmds)
  if #missing == 0 then
    if opts.ok_notify then
      vim.notify("Deps OK: " .. table.concat(cmds, ", "), vim.log.levels.INFO)
    end
    return true
  end

  vim.notify(
    ("Missing external tools: %s\n%s"):format(table.concat(missing, ", "), M.install_hint(cmds)),
    vim.log.levels.WARN
  )
  return false
end

return M

