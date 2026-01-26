-- ~/.config/nvim/colors/grayscale.lua
local colors = {
  bg = "#0d0d0d",
  fg = "#e6e6e6",
  comment = "#6c6c6c",
  line = "#1c1c1c",
  cursorline = "#202020",
  selection = "#333333",
  accent = "#ff8800", -- 🔴 red accent (change to "#ff8800" for orange)
}

vim.opt.background = "dark"
vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end
vim.g.colors_name = "grayscale"

local set = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Editor basics
set("Normal", { fg = colors.fg, bg = colors.bg })
set("Comment", { fg = colors.comment, italic = true })
set("CursorLine", { bg = colors.cursorline })
set("Visual", { bg = colors.selection })
set("LineNr", { fg = colors.comment })
set("CursorLineNr", { fg = colors.accent, bold = true })
set("VertSplit", { fg = colors.line })
set("StatusLine", { fg = colors.fg, bg = colors.line })
set("Pmenu", { fg = colors.fg, bg = colors.line })
set("PmenuSel", { fg = colors.bg, bg = colors.accent })
set("Search", { fg = colors.bg, bg = colors.accent })

-- Syntax groups
set("Identifier", { fg = colors.fg })
set("Keyword", { fg = colors.accent, bold = true })
set("Function", { fg = colors.accent })
set("String", { fg = "#a0a0a0" })
set("Number", { fg = "#b0b0b0" })

-- Diagnostics
set("DiagnosticError", { fg = "#ff5f5f" })
set("DiagnosticWarn", { fg = "#ffaa00" })
set("DiagnosticInfo", { fg = "#aaaaaa" })
set("DiagnosticHint", { fg = "#888888" })

-- Neo-tree support (custom accents)
set("NeoTreeNormal", { fg = colors.fg, bg = colors.bg })
set("NeoTreeDirectoryIcon", { fg = colors.accent })
set("NeoTreeDirectoryName", { fg = colors.fg })
set("NeoTreeGitModified", { fg = colors.accent })
set("NeoTreeGitAdded", { fg = "#5fff87" })
set("NeoTreeGitDeleted", { fg = "#ff5f5f" })
set("NeoTreeCursorLine", { bg = colors.cursorline })

-- Markdown / todo checkboxes (used by render-markdown or Treesitter)
set("@text.todo.unchecked", { fg = "#ff8800" })  -- ☐
set("@text.todo.checked", { fg = "#ff8800" })    -- ☑
set("Boolean", { fg = "#ff8800" })
set("Special", { fg = "#ff8800" })

-- Headings are now purple
set("@markup.heading", { fg = "#bf5fff", bold = true })
set("markdownH1", { fg = "#bf5fff", bold = true })
set("markdownH2", { fg = "#bf5fff", bold = true })
set("markdownHeadingDelimiter", { fg = "#bf5fff" })


-- Remove or recolor markdown heading backgrounds from render-markdown.nvim
local accent = "#bf5fff"  -- or "#ff8800" for orange

-- For Treesitter / markdown built-ins
set("@markup.heading", { fg = accent, bg = "NONE", bold = true })

-- For render-markdown plugin headings
set("RenderMarkdownH1", { fg = accent, bg = "NONE", bold = true })
set("RenderMarkdownH2", { fg = accent, bg = "NONE", bold = true })
set("RenderMarkdownH3", { fg = accent, bg = "NONE", bold = true })
set("RenderMarkdownH4", { fg = accent, bg = "NONE", bold = true })
set("RenderMarkdownH5", { fg = accent, bg = "NONE", bold = true })
set("RenderMarkdownH6", { fg = accent, bg = "NONE", bold = true })

-- Optional: cursorline (the line highlight when your cursor is on it)
set("CursorLine", { bg = "#1a1a1a" })  -- darker gray, not blue

-- Code blocks and inline code
set("markdownCode", { fg = "#c0c0c0", bg = "#1a1a1a" })         -- inline `code`
set("markdownCodeBlock", { fg = "#c0c0c0", bg = "#1a1a1a" })    -- fenced blocks
set("markdownCodeDelimiter", { fg = colors.comment })           -- ```
set("@markup.raw", { fg = "#c0c0c0", bg = "#1a1a1a" })          -- Treesitter inline code
set("@markup.raw.block", { fg = "#c0c0c0", bg = "#1a1a1a" })    -- Treesitter code block
set("@markup.raw.delimiter", { fg = colors.comment })           -- ```
