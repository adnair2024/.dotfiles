local lazypath = vim.fn.stdpath('data')..'/lazy/lazy.nvim'
print("Lazy path: " .. lazypath)
local stat = vim.loop.fs_stat(lazypath)
if stat then
  print("Lazy exists on disk")
else
  print("Lazy does NOT exist on disk")
end

vim.opt.rtp:prepend(lazypath)

local ok, lazy = pcall(require, "lazy")
if ok then
  print("Successfully required lazy")
else
  print("Failed to require lazy")
end
