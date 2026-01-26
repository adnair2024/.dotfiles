-- ===========================================
-- 🛠️ lua/utils.lua (Helper Functions and Patches)
-- ===========================================

-- === LSP Patching to Prevent Errors ===
do
  local client = require("vim.lsp.client")
  local old_resolve_bufnr = client.resolve_bufnr
  client.resolve_bufnr = function(bufnr)
    if type(bufnr) == "function" then
      return vim.api.nvim_get_current_buf()
    end
    return old_resolve_bufnr(bufnr)
  end

  local old_request = vim.lsp.buf_request
  vim.lsp.buf_request = function(bufnr, ...)
    if type(bufnr) ~= "number" then
      bufnr = vim.api.nvim_get_current_buf()
    end
    return old_request(bufnr, ...)
  end
end
vim.lsp.handlers["window/showMessage"] = function() end
vim.lsp.handlers["window/showMessageRequest"] = function() end

-- === Notification Patching (Filtering out noisey messages) ===
do
  local orig_notify = vim.notify
  vim.notify = function(msg, level, opts)
    local msg_str = type(msg) == "string" and msg or ""
    
    -- Filter out noisey plugins
    if msg_str:match("nvim%-cmp") or msg_str:match("which%-key") or msg_str:match("Comment%.nvim") then
      return -- Silent ignore
    end

    -- Allow writes, errors, and warnings
    if msg_str:match("written") or msg_str:match("saved")
        or level == vim.log.levels.ERROR or level == vim.log.levels.WARN then
      return orig_notify(msg, level, opts)
    end
    
    -- Filter out hard LSP info/log messages
    if level == vim.log.levels.INFO and msg_str:match("^LSP") then
      if pcall(require, "noice") then
        return require("noice").notify(msg, "info", opts)
      end
    end

    orig_notify(msg, level, opts)
  end
end

-- === Global Utility Functions (_G.) ===

_G.word_count = function()
  local wc = vim.fn.wordcount()
  if wc["visual_words"] then
    return wc["visual_words"] .. " words"
  else
    return wc["words"] .. " words"
  end
end

-- Run functions
_G.run_cpp_file = function()
  vim.cmd("w")
  local compile_cmd = "g++ " .. vim.fn.expand("%") .. " -o " .. vim.fn.expand("%:r")
  vim.fn.system(compile_cmd)
  if vim.v.shell_error == 0 then
    local Snacks = require("snacks")
    Snacks.terminal(vim.fn.expand("%:r"), {
      win = {
        position = "float",
        backdrop = false,
      },
      interactive = true,
    })
  else
    print("Compilation failed. Please check for errors.")
  end
end

_G.run_specific_cpp_file = function()
    local filepath = "/Users/ashwinnair/Dropbox/LoyolaCoursework/Fall2024/COSC-A211/final_project/main.cpp" 
    local compile_cmd = "g++ -std=c++17 -Wall -o temp_exec " .. filepath
    local run_cmd = "./temp_exec"

    vim.notify("Opened ToDo List!")
    local Snacks = require("snacks")
    Snacks.terminal(compile_cmd .. " && " .. run_cmd, {
        win = { position = "float", backdrop = false },
        interactive = true
    })
end

_G.run_java = function()
  local file = vim.fn.expand("%:p")
  local filename_without_ext = vim.fn.expand("%:t:r")
  local compile_run_cmd = "javac " .. file .. " && java " .. filename_without_ext
  
  local Snacks = require("snacks")
  Snacks.terminal(compile_run_cmd, {
      win = { position = "float", backdrop = false },
      interactive = true
  })
end

_G.RunGoFile = function()
  local filepath = vim.fn.expand('%:p')
  if vim.bo.filetype == "go" then vim.cmd("!go run " .. filepath) else print("Not a Go file!") end
end

_G.close_current_terminal = function()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].buftype == "terminal" then
      vim.cmd("bdelete!")
  else
      vim.notify("Not a terminal buffer", vim.log.levels.WARN)
  end
end

-- Markdown Helpers
_G.add_markdown_table_row = function()
  local line = vim.api.nvim_get_current_line()
  local pipe_count = select(2, line:gsub("|", "")) - 1
  if pipe_count < 1 then
    vim.notify("Not inside a Markdown table", vim.log.levels.WARN)
    return
  end
  local new_row = "|" .. string.rep(" ---", pipe_count) .. " --|" 
  new_row = new_row:sub(1, #new_row - 1) .. "|" 
  local row_num = vim.fn.line(".")
  vim.fn.append(row_num, new_row)
  vim.cmd("normal! j0")
end

_G.create_markdown_table = function()
  vim.ui.input({ prompt = "Enter rows,columns (e.g. 2,3): " }, function(input)
    if not input then return end
    local rows, cols = input:match("(%d+),(%d+)")
    rows, cols = tonumber(rows), tonumber(cols)
    if not rows or not cols then
      vim.notify("Invalid format. Use rows,cols (e.g. 2,3)", vim.log.levels.ERROR)
      return
    end
    local lines = {}
    local header = {}
    for c = 1, cols do table.insert(header, "Header" .. c) end
    table.insert(lines, "| " .. table.concat(header, " | ") .. " |")
    local separator = {}
    for _ = 1, cols do table.insert(separator, "---") end
    table.insert(lines, "| " .. table.concat(separator, " | ") .. " |")
    for r = 1, rows do
      local row = {}
      for c = 1, cols do table.insert(row, "Row" .. r .. "Col" .. c) end
      table.insert(lines, "| " .. table.concat(row, " | ") .. " |")
    end
    vim.api.nvim_put(lines, "l", true, true)
  end)
end

_G.add_markdown_image_at_mouse = function()
    local clipboard = vim.fn.getreg('+')
    local url = ""
    if clipboard ~= "" and clipboard:match("^https?://") or clipboard:match("^/.*") then
        url = clipboard
    else
        url = vim.fn.input("Image URL/Path: ")
    end
    if url == "" then print("No URL provided. Aborting.") return end
    local mouse_pos = vim.fn.getmousepos()
    local row = mouse_pos.line
    local col = mouse_pos.column
    local img_tag = string.format("![](%s)", url)
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, {img_tag})
end

_G.markdown_to_pdf = function()
    local file_path = vim.fn.expand("%:p")
    if file_path == "" or not file_path:match("%.md$") then
        vim.notify("No Markdown file selected", vim.log.levels.WARN)
        return
    end
    local pdf_name = vim.fn.input("Enter PDF name (without .pdf extension): ") .. ".pdf"
    local pdf_path = vim.fn.expand("%:p:h") .. "/" .. pdf_name
    local command = {
        "pandoc", file_path,
        "--pdf-engine=xelatex",
        "-o", pdf_path,
        "-V", "mainfont=Times New Roman",
        "-V", "fontsize=12pt"
    }
    vim.fn.jobstart(command, {
        stdout_buffered = true, stderr_buffered = true,
        on_stdout = function(_, data) if data then vim.notify(table.concat(data, "\n"), vim.log.levels.INFO) end end,
        on_stderr = function(_, data) 
            if data then 
                local filtered_errors = {}
                for _, line in ipairs(data) do
                    if not line:match("requires a nonempty <title> element") then table.insert(filtered_errors, line) end
                end
                if #filtered_errors > 0 then vim.notify("Pandoc Error: " .. table.concat(filtered_errors, "\n"), vim.log.levels.ERROR) end
            end
        end,
        on_exit = function(_, exit_code)
            if exit_code == 0 then vim.notify("PDF created: " .. pdf_path, vim.log.levels.INFO) else vim.notify("Error creating PDF", vim.log.levels.ERROR) end
        end,
    })
end

-- Spellcheck Helper
_G.correct_first_spell_suggestion = function()
  local word = vim.fn.expand("<cword>")
  local suggestions = vim.fn.spellsuggest(word)
  if suggestions ~= nil and #suggestions > 0 then
    local first = suggestions[1]
    vim.cmd("normal! ciw" .. first)
  else
    print("No spell suggestions available")
  end
end

-- DB Viewer
_G.open_db_viewer = function()
  local home = vim.fn.expand("~")
  local file_dir = vim.fn.expand("%:p:h")  
  local script_path = home .. "/Documents/GitHub/terminal-database-scanner/db_viewer.py"
  local cmd = "python3 " .. script_path .. " " .. file_dir
  local Snacks = require("snacks")
  Snacks.terminal(cmd, { win = { position = "float", backdrop = false } })
end

-- DeepSeek
_G.scan_with_deepseek = function()
    local file_path = vim.fn.expand('%:p') 
    if file_path == "" or vim.bo.filetype == "" then
        vim.notify("No file selected!", vim.log.levels.WARN)
        return
    end
    local deepseek_cmd = "ollama run nezahatkorkmaz/deepseek-v3 < " .. file_path
    local Snacks = require("snacks")
    Snacks.terminal(deepseek_cmd, { win = { position = "right", backdrop = false }, interactive = true })
end

-- Tmux
_G.save_tmux_session = function()
  vim.fn.system("tmux run-shell ~/.tmux/plugins/tmux-resurrect/scripts/save.sh")
  require("noice").notify("Tmux session saved successfully!", { title = "Tmux Session", icon = "💾", level = "success", timeout = 2000 })
end

_G.tmux_session_picker = function()
  local snacks = require("snacks")
  local function get_sessions()
    local cmd = "/usr/local/bin/tmux list-sessions -F \"#{session_name}: #{?session_attached,(Attached),}\""
    local handle = io.popen(cmd)
    if not handle then
      vim.notify("Failed to run tmux command: " .. cmd, vim.log.levels.ERROR)
      return {}
    end
    local output = handle:read("*a")
    handle:close()
    
    if output == "" or output == nil then
      vim.notify("Tmux command returned no output", vim.log.levels.WARN)
      return {}
    end

    local items = {}
    for line in output:gmatch("[^\r\n]+") do
      local name = line:match("^(.-):")
      if name then
        table.insert(items, {
          text = line,
          value = name,
        })
      end
    end
    return items
  end

  snacks.picker.pick({
    source = "tmux_sessions",
    title = "Tmux Sessions",
    items = get_sessions(),
    format = "text",
    confirm = function(picker, item)
      picker:close()
      if item then
        vim.schedule(function()
          vim.fn.system("/usr/local/bin/tmux switch-client -t " .. item.value)
        end)
      end
    end,
    actions = {
      kill_session = function(picker, item)
        if item then
          picker:close()
          vim.schedule(function()
            vim.fn.system("/usr/local/bin/tmux kill-session -t " .. item.value)
            vim.defer_fn(function() 
               _G.tmux_session_picker()
            end, 100)
          end)
        end
      end
    },
    win = {
      input = {
        keys = {
          ["<c-x>"] = { "kill_session", mode = { "n", "i" }, desc = "Kill Session" },
        }
      }
    }
  })
end

_G.tmux_window_picker = function()
  local snacks = require("snacks")
  local function get_windows()
    local cmd = "/usr/local/bin/tmux list-windows -F \"#{window_index}: #{window_name} #{?window_active,(Active),}\""
    local handle = io.popen(cmd)
    if not handle then
      vim.notify("Failed to run tmux command: " .. cmd, vim.log.levels.ERROR)
      return {}
    end
    local output = handle:read("*a")
    handle:close()

    if output == "" or output == nil then
       return {}
    end

    local items = {}
    for line in output:gmatch("[^\r\n]+") do
      local idx = line:match("^(%d+):")
      if idx then
        table.insert(items, {
          text = line,
          value = idx,
        })
      end
    end
    return items
  end

  snacks.picker.pick({
    source = "tmux_windows",
    title = "Tmux Windows",
    items = get_windows(),
    format = "text",
    confirm = function(picker, item)
      picker:close()
      if item then
        vim.schedule(function()
          vim.fn.system("/usr/local/bin/tmux select-window -t " .. item.value)
        end)
      end
    end,
    actions = {
      kill_window = function(picker, item)
        if item then
          picker:close()
          vim.schedule(function()
            vim.fn.system("/usr/local/bin/tmux kill-window -t " .. item.value)
            vim.defer_fn(function() 
               _G.tmux_window_picker()
            end, 100)
          end)
        end
      end
    },
    win = {
      input = {
        keys = {
          ["<c-x>"] = { "kill_window", mode = { "n", "i" }, desc = "Kill Window" },
        }
      }
    }
  })
end

-- External Tool Wrappers (Replaced with Snacks.terminal)
_G._PYTHON_FLOAT = function() 
    require("snacks").terminal("python3 ~/Dropbox/LoyolaCoursework/flashcards/flashcards.py", {
        win = { position = "float", width = 0.8, height = 0.8, backdrop = false },
        interactive = true,
        start_insert = true
    })
end

_G._python_planner_toggle = function() 
    require("snacks").terminal("python3 ~/Dropbox/LoyolaCoursework/Dash/daily-planner.py", {
        win = { position = "float", width = 0.8, height = 0.8, backdrop = false },
        interactive = true,
        start_insert = true
    })
end

_G._python_inkdex_toggle = function() 
    require("snacks").terminal("python3 ~/Dropbox/LoyolaCoursework/notes/notebook.py", {
        win = { position = "float", width = 0.8, height = 0.8, backdrop = false },
        interactive = true,
        start_insert = true
    })
end

_G._python_pomo_toggle = function() 
     require("snacks").terminal("python3 ~/Dropbox/LoyolaCoursework/pomo/pomo.py", {
        win = { position = "right", width = 0.4, backdrop = false },
        interactive = true,
        start_insert = true
     })
end

_G._python_totp_toggle = function()
  local totp_path = "/Users/ashwinnair/Documents/otpman"
  local venv_activate = totp_path .. "/venv/bin/activate"
  local totp_script = totp_path .. "/totpui.py"
  
  -- Use Snacks.terminal for this too? Or keep it custom since it was using a special window?
  -- The previous one used a custom buffer/window. Snacks terminal float is similar.
  local cmd = string.format("source %s && python3 %s", venv_activate, totp_script)
  require("snacks").terminal(cmd, {
      win = { position = "float", width = 0.8, height = 0.8, backdrop = false },
      interactive = true,
      shell = "bash" -- Ensure bash for source
  })
end

-- Mistral Terminal
_G.open_right_terminal_with_mst = function()
    require("snacks").terminal("mst", {
        win = { position = "right", width = 0.3, backdrop = false },
        interactive = true,
        start_insert = true
    })
end

-- === User Commands ===

vim.api.nvim_create_user_command("WordCount", function()
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local word_count = 0
    for _, line in ipairs(lines) do
        if vim.trim(line) ~= "" then
            local words = vim.fn.split(vim.trim(line), "\\s+")
            word_count = word_count + #words
        end
    end
    vim.notify("Word Count: " .. word_count, vim.log.levels.INFO, { title = "Word Count" })
end, { desc = "Counts words in the current buffer and displays the result" })

vim.api.nvim_create_user_command('ViewPDF', function()
  local file = vim.fn.expand('%:p') 
  if file:match('%.pdf$') then
    vim.fn.system("open -a Skim " .. file)
  else
    print("Not a PDF file!")
  end
end, { desc = "View the current PDF file" })

vim.api.nvim_create_user_command('MarkdownPreviewToggle', function()
    vim.cmd("MarkdownPreviewToggle") 
end, { desc = "Toggle Markdown Preview" })

-- Reload Config
_G.reload_config = function()
  for name,_ in pairs(package.loaded) do
    if name:match("^options") or name:match("^utils") or name:match("^autocmds") or name:match("^keymaps") then
      package.loaded[name] = nil
    end
  end

  dofile(vim.env.MYVIMRC)
  
  if pcall(require, "noice") then
    require("noice").notify("Configuration Reloaded!", "info", { title = "Config" })
  else
    vim.notify("Configuration Reloaded!", vim.log.levels.INFO)
  end
end
