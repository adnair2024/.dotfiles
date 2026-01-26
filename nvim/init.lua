-- ===========================================
-- 🚀 init.lua (Core Startup)
-- ===========================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local function safe_require(module)
  local ok, err = pcall(require, module)
  if not ok then
    vim.notify("Error loading " .. module .. ":\n" .. err, vim.log.levels.ERROR)
  end
end

-- 1. Load Core Options (Sets leader key, etc.)
safe_require("options")      -- Global Vim settings and options

-- 2. Lazy.nvim Setup
local lazypath = vim.fn.stdpath('data')..'/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none', '--single-branch', 'https://github.com/folke/lazy.nvim', lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- 3. Load Remaining Modules
safe_require("utils")        -- Utility functions, patches, and shared logic
safe_require("plugins.init") -- Lazy.nvim plugin specifications and configs
safe_require("autocmds")     -- Auto-commands (filetype, linting, etc.)
safe_require("keymaps")      -- All Which-Key mappings
