-- File: lua/colors/rose_lavender.lua
local theme = {}

local rose      = "#d87ca0"   -- muted rose
local rose_dark = "#b56586"
local lavender  = "#f3ecf9"   -- main soft lavender bg
local lavender2 = "#efe7f6"
local lavender3 = "#e7def0"
local ink       = "#3b3054"   -- plum/ink text
local soft_ink  = "#6e5d8c"
local subtle    = "#aa95c4"
local subtle2   = "#c8b7e6"

theme.setup = function()
  local hl = vim.api.nvim_set_hl

  -- Core UI -----------------------------------------------------
  hl(0, "Normal",           { bg = lavender,  fg = ink })
  hl(0, "NormalFloat",      { bg = lavender2, fg = ink })
  hl(0, "FloatBorder",      { bg = lavender2, fg = subtle })
  hl(0, "LineNr",           { fg = subtle, bg = "NONE" })
  hl(0, "CursorLineNr",     { fg = rose_dark, bold = true })
  hl(0, "CursorLine",       { bg = lavender3 })
  hl(0, "Visual",           { bg = subtle2 })

  -- Editor chrome ------------------------------------------------
  hl(0, "StatusLine",       { bg = lavender2, fg = ink })
  hl(0, "StatusLineNC",     { bg = lavender3, fg = soft_ink })
  hl(0, "WinSeparator",     { fg = subtle })

  -- Search / matches ---------------------------------------------
  hl(0, "Search",           { bg = rose, fg = "#ffffff" })
  hl(0, "IncSearch",        { bg = rose_dark, fg = "#ffffff" })
  hl(0, "MatchParen",       { bg = "#e8d3ed", bold = true })

  -- Completion menu ----------------------------------------------
  hl(0, "Pmenu",            { bg = lavender2, fg = ink })
  hl(0, "PmenuSel",         { bg = subtle2 })
  hl(0, "PmenuBorder",      { fg = subtle2 })

  -- Syntax Colors -------------------------------------------------
  hl(0, "Comment",          { fg = soft_ink, italic = true })
  hl(0, "Identifier",       { fg = ink })
  hl(0, "Function",         { fg = rose_dark })
  hl(0, "Statement",        { fg = rose_dark })
  hl(0, "Keyword",          { fg = rose })
  hl(0, "Type",             { fg = subtle })
  hl(0, "Constant",         { fg = rose_dark })
  hl(0, "String",           { fg = "#a06faf" })
  hl(0, "Number",           { fg = "#c55b89" })
  hl(0, "Boolean",          { fg = rose_dark })

  -- Diagnostics ---------------------------------------------------
  hl(0, "DiagnosticError",  { fg = "#d1507b" })
  hl(0, "DiagnosticWarn",   { fg = "#c28f47" })
  hl(0, "DiagnosticInfo",   { fg = "#6d7cd1" })
  hl(0, "DiagnosticHint",   { fg = "#7a99b8" })

  -- Telescope -----------------------------------------------------
  hl(0, "TelescopeNormal",  { bg = lavender2, fg = ink })
  hl(0, "TelescopeBorder",  { bg = lavender2, fg = subtle })
  hl(0, "TelescopeSelection",{ bg = subtle2 })

  -- Noice + Notify -----------------------------------------------
  hl(0, "NotifyINFOBorder", { fg = subtle, bg = lavender2 })
  hl(0, "NotifyERRORBorder",{ fg = rose_dark, bg = lavender2 })
  hl(0, "NotifyWARNBorder", { fg = "#c28f47", bg = lavender2 })
  hl(0, "NotifyINFOBody",   { fg = ink, bg = lavender2 })
end

theme.setup()

return theme
