-- ===========================================
-- 📅 lua/autocmds.lua (Autocommands)
-- ===========================================

-- 1. Header Insertion
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = { "*.cpp", "*.py", "*.md", "*.go" },
  callback = function()
    local date = os.date("%Y-%m-%d")
    local filename = vim.fn.expand("%:t")
    local banner

    if vim.bo.filetype == "cpp" then
      banner = string.format([[ 
/*****************************
Author: Ashwin Nair
Date: %s
Project name: %s
Summary: Enter summary here.
*****************************/
]], date, filename)
    elseif vim.bo.filetype == "python" then
      banner = string.format([[ 
"""
Author: Ashwin Nair
Date: %s
Project name: %s
Summary: Enter summary here.
"""
]], date, filename)
    elseif vim.bo.filetype == "markdown" then
      banner = string.format([[ 
<!--
Author: Ashwin Nair
Date: %s
Project name: %s
Summary: Enter summary here.
-->
]], date, filename)
   elseif vim.bo.filetype == "go" then
    banner = string.format([[ 
/*****************************
Author: Ashwin Nair
Date: %s
Project name: %s
Package: %s
Summary: Enter summary here.
*****************************/

package %s
]], date, filename, vim.fn.expand('%:t:r'), vim.fn.expand('%:t:r'))
    end

    if banner then
      vim.api.nvim_buf_set_lines(0, 0, 0, false, vim.split(banner, "\n"))
    end
  end,
})

-- 2. Linting and Diagnostics on Save
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.cpp", "*.py", "*.md", "*.go", "*.java" }, -- Combined patterns from init.lua
  callback = function()
    if pcall(require, 'lint') then
        require('lint').try_lint()
    end
    vim.diagnostic.hide()
  end,
})

-- 3. Filetype Specific Settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "fzf",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.laststatus = 0
    vim.api.nvim_create_autocmd("BufLeave", {
      buffer = 0,
      callback = function()
        vim.opt_local.laststatus = 2
      end
    })
  end
})

-- 4. CursorHold for Spell Notification
local function notify_spell_error()
  if vim.wo.spell then
    local line = vim.api.nvim_get_current_line()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local col = cursor_pos[2]
    local word = vim.fn.matchstr(line:sub(1, col + 1), "\\k*$")
        .. vim.fn.matchstr(line:sub(col + 2), "^\\k*")

    if word ~= "" and vim.fn.spellbadword(word)[1] ~= "" then
      if pcall(require, "noice") then
          require("noice").notify("Misspelled Word: " .. word, "warn", {
              title = "Spell Check",
          })
      end
    end
  end
end
vim.api.nvim_create_autocmd("CursorHold", { callback = notify_spell_error })

-- 5. LspAttach Monkey Patch (for cmp_nvim_lsp error)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function()
    local ok, source = pcall(require, "cmp_nvim_lsp.source")
    if not ok then return end
    
    local old_request = source._request
    source._request = function(self, method, params, callback) 
      local _, request_id = self.client.request(method, params, function(a1, a2, a3) 
        if self.request_ids[method] ~= request_id then return end
        self.request_ids[method] = nil
        if a1 and a1.code == -32801 then
          self:_request(method, params, callback)
          return
        end
        if method == a2 then callback(a1, a3) else callback(a1, a2) end
      end, 0)
      self.request_ids[method] = request_id
    end
  end,
})

-- 6. Highlight Overrides
vim.cmd [[ 
  highlight ColorColumn ctermbg=0 guibg=blue
  highlight clear SpellBad
  highlight SpellBad cterm=underline ctermfg=Red guibg=None guifg=Red

  " NeoTree Overrides
  highlight NeoTreeNormal guifg=#005F87
  highlight NeoTreeNormalNC guifg=#005F87
  highlight NeoTreeRootName guifg=#005F87 gui=bold
  highlight NeoTreeFileName guifg=#005F87
  highlight NeoTreeFileIcon guifg=#005F87
  highlight NeoTreeFileNameOpened guifg=#005F87 gui=bold
  highlight NeoTreeIndentMarker guifg=#005F87
  highlight NeoTreeGitAdded guifg=#005F87
  highlight NeoTreeGitModified guifg=#005F87
  highlight NeoTreeGitUntracked guifg=#005F87
  highlight NeoTreeDirectoryName guifg=#005F87
  highlight NeoTreeDirectoryIcon guifg=#005F87

  " Noice Overrides
  highlight NoicePopup guibg=#333333 guifg=#005F87
  highlight NoicePopupBorder guifg=#005F87
  highlight NoicePopupTitle guifg=#005F87
  highlight NoiceCmdline guifg=#005F87
  highlight NoiceCmdlineIcon guifg=#005F87
  highlight NoiceCmdlinePopup guibg=#333333 guifg=#005F87
  highlight NoiceCmdlinePopupBorder guifg=#005F87
  highlight NoiceCmdlinePrompt guifg=#005F87
  highlight NoiceConfirmBorder guifg=#005F87
  highlight NoiceFormatTitle guifg=#005F87 gui=bold
  highlight NoiceFormatProgressDone guibg=#005F87 guifg=#000000
  highlight NoiceFormatProgressTodo guibg=#333333 guifg=#005F87
  
  " RenderMarkdown overrides (from init.lua)
  highlight RenderMarkdownCode guifg=#ff8800
  highlight RenderMarkdownLink guifg=#ff8800 gui=underline
  highlight RenderMarkdownBullet guifg=#ff8800
  highlight RenderMarkdownCheckbox guifg=#ff8800
  highlight RenderMarkdownChecked guifg=#ff8800
  highlight RenderMarkdownUnchecked guifg=#ff8800
]]

-- 7. Markdown Fenced Code Blocks (Final overrides)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    local bg     = "#221F2F" -- muted purple
    local text   = "#C8C3D9" -- soft grey-purple
    local fence  = "#D08770" -- muted orange

    vim.cmd(string.format([[ 
      " Background + text
      hi! markdownCodeBlock      guibg=%s guifg=%s
      hi! @markup.raw.markdown   guibg=%s guifg=%s
      hi! @markup.raw_block.markdown guibg=%s guifg=%s

      " Code fences (```bash)
      hi! markdownCodeDelimiter guifg=%s gui=bold
      hi! @markup.raw.delimiter.markdown guifg=%s gui=bold

      " *** Disable ALL injected highlighting ***
      hi! link @text.literal.markdown        NONE
      hi! link @text.literal.block.markdown  NONE
      hi! link @text.literal.delimiter.markdown NONE
      hi! link @string.markdown              NONE
      hi! link @string.special.markdown      NONE
      hi! link @keyword.markdown             NONE
      hi! link @function.markdown            NONE
      hi! link @variable.builtin.markdown    NONE
      hi! link @type.markdown                NONE
      hi! link @constant.markdown            NONE
      hi! link @comment.markdown             NONE
      hi! link @punctuation.markdown         NONE

      " Treesitter code fenced language injection killers:
      hi! link @markup.fenced_code           NONE
      hi! link @markup.fenced_code.block     NONE
      hi! link @markup.raw                   NONE
      hi! link @markup.raw_block             NONE
    ]], bg, text, bg, text, bg, text, fence, fence))
  end,
})
