-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--vim.keymap.set("n", "<leader>ee", "<cmd>Neotree toggle<CR>", { desc = "Toggle Explorer" })ф
--vim.api.nvim_set_keymap("n", "<leader>fr", ":FlutterRun<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fq", ":FlutterQuickRun<CR>", { desc = "Flutter Quick Run" })
vim.keymap.set("n", "<leader>fQ", ":FlutterQuickRestart<CR>", { desc = "Flutter Restart" })
vim.keymap.set("n", "<leader>fp", ":FlutterPubGet<CR>", { desc = "Flutter pub get" })
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode", noremap = true })
