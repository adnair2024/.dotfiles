-- File: lua/colors/purplecalm.lua
local theme = {}

local colors = {
  bg        = "#1D1B26",
  bg_alt    = "#242130",
  fg        = "#CFC9E6",
  fg_dim    = "#AFA9C8",

  purple1   = "#6F6A8F",
  purple2   = "#8B84A5",
  purple3   = "#B2ADD4",

  orange    = "#E39A5F",
  orange_dim= "#C88145",

  red       = "#D97474",
  green     = "#8FBF8F",
  yellow    = "#D8C27A",
  blue      = "#7EA8C9",
  cyan      = "#82C6C4",
  magenta   = "#C49BCF",
}

theme.colors = colors

theme.setup = function()
  local set = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- Editor
  set("Normal",         { fg = colors.fg, bg = colors.bg })
  set("NormalFloat",    { fg = colors.fg, bg = colors.bg_alt })
  set("FloatBorder",    { fg = colors.purple1, bg = colors.bg_alt })
  set("CursorLine",     { bg = "#221F2D" })
  set("CursorLineNr",   { fg = colors.orange })
  set("LineNr",         { fg = colors.purple1 })
  set("SignColumn",     { bg = colors.bg })

  -- UI elements
  set("Visual",         { bg = colors.purple1 })
  set("StatusLine",     { fg = colors.fg, bg = colors.bg_alt })
  set("StatusLineNC",   { fg = colors.fg_dim, bg = colors.bg_alt })
  set("VertSplit",      { fg = colors.purple1 })

  -- Syntax
  set("Comment",        { fg = colors.purple1, italic = true })
  set("Keyword",        { fg = colors.purple3 })
  set("Function",       { fg = colors.orange })
  set("Identifier",     { fg = colors.fg })
  set("String",         { fg = colors.green })
  set("Number",         { fg = colors.orange_dim })
  set("Boolean",        { fg = colors.orange })
  set("Type",           { fg = colors.blue })
  set("Constant",       { fg = colors.magenta })
  set("Operator",       { fg = colors.purple2 })

  -- Diagnostics
  set("DiagnosticError", { fg = colors.red })
  set("DiagnosticWarn",  { fg = colors.yellow })
  set("DiagnosticInfo",  { fg = colors.blue })
  set("DiagnosticHint",  { fg = colors.cyan })

  -- Treesitter (enhanced hues)
  set("@variable",      { fg = colors.fg })
  set("@function",      { fg = colors.orange })
  set("@keyword",       { fg = colors.purple3 })
  set("@type",          { fg = colors.blue })
  set("@string",        { fg = colors.green })
  set("@number",        { fg = colors.orange_dim })
end

theme.setup()

return theme
