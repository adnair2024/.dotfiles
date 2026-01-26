-- ===========================================
-- ⚙️ lua/options.lua (Global Settings)
-- ===========================================

-- General Vim Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.colorcolumn = "80"
vim.opt.pumblend = 10
vim.opt.winblend = 10
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99
vim.opt.clipboard = "unnamed"

-- Global Variables
vim.g.mapleader = " "
vim.g.db_ui_save_location = "~/.config/nvim/db_queries"
vim.g.mkdp_auto_start = 0
vim.g.mkdp_auto_close = 1

-- Initial Theme
-- vim.cmd("colorscheme carbonfox") -- Moved to plugins/init.lua