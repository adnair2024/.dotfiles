-- ===========================================
-- 🔑 lua/keymaps.lua (Mappings)
-- ===========================================

-- 1. Dependency Check
-- Ensure utils functions are available. If not, we define dummies or rely on _G checks.
local run_cpp_file = _G.run_cpp_file or function() print("Run C++ not loaded") end
local run_specific_cpp_file = _G.run_specific_cpp_file or function() print("Run Specific C++ not loaded") end
local run_java = _G.run_java or function() print("Run Java not loaded") end
local open_db_viewer = _G.open_db_viewer or function() print("DB Viewer not loaded") end
local correct_first_spell_suggestion = _G.correct_first_spell_suggestion or function() print("Spell check not loaded") end
local close_current_terminal = _G.close_current_terminal or function() print("Close term not loaded") end
local add_markdown_table_row = _G.add_markdown_table_row or function() print("MD Table Row not loaded") end
local markdown_to_pdf = _G.markdown_to_pdf or function() print("MD to PDF not loaded") end
local create_markdown_table = _G.create_markdown_table or function() print("Create MD Table not loaded") end
local save_tmux_session = _G.save_tmux_session or function() print("Save Tmux not loaded") end
local scan_with_deepseek = _G.scan_with_deepseek or function() print("Deepseek not loaded") end
local reload_config = _G.reload_config or function() vim.cmd("source $MYVIMRC") end

-- MD Helper
local md
if pcall(require, "md-helper") then
    md = require("md-helper")
else
    md = {
        generate_toc = function() print("md-helper not found") end,
        create_image = function() print("md-helper not found") end,
        create_link = function() print("md-helper not found") end,
        create_table = function() print("md-helper not found") end,
        toggle_checkbox = function() print("md-helper not found") end,
    }
end

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Helper to combine opts with desc
local function desc(d)
  return vim.tbl_extend("force", opts, { desc = d })
end

-- ============================================================================
-- 🚀 CORE MAPPINGS (Using standard vim.keymap.set)
-- ============================================================================

-- Basic
map("n", "<leader>w", ":w<CR>", desc("Save File"))
map("n", "<leader>q", ":wq<CR>", desc("Save and Exit"))
map("n", "<leader>v", ":ViewPDF<CR>", desc("View PDF"))
map("n", "<leader>d", function() require("snacks").dashboard() end, desc("Return to Dashboard (Snacks)"))
map("n", "<leader>e", function() require("snacks").explorer() end, desc("Toggle Explorer (Snacks)"))
map("n", "<leader>o", "<cmd>Outline<CR>", desc("Markdown outline"))

-- Run Group
map("n", "<leader>rp", ":w | !python3 %<CR>", desc("Run Python File"))
map("n", "<leader>rc", ":lua run_cpp_file()<CR>", desc("Run C++ File"))
map("n", "<leader>rn", ":w | !node %<CR>", desc("Run Node.js File"))
map("n", "<leader>rt", function() run_specific_cpp_file() end, desc("Run ToDo in Fall 2024"))
map("n", "<leader>rg", ":lua RunGoFile()<CR>", desc("Run Go File"))
map("n", "<leader>rj", function() run_java() end, desc("Run Java File"))
map("n", "<leader>rf", "<cmd>lua require'cmp'.complete()<CR>", desc("Trigger Autocomplete"))

-- Markdown Group
map("n", "<leader>mo", ":MarkdownPreview<CR>", desc("Open Markdown Preview"))
map("n", "<leader>mt", "<cmd>MarkdownPreviewToggle<CR>", desc("Toggle Markdown Preview"))
map("n", "<leader>ma", function() add_markdown_table_row() end, desc("Add markdown table row"))
map("n", "<leader>mc", function() markdown_to_pdf() end, desc("Convert Markdown to PDF"))
map("n", "<leader>mv", ":ViewPDF<CR>", desc("View PDF"))
map("n", "<leader>mx", function() require("my_markdown").toggle_checkbox() end, desc("Toggle checkbox"))
map("n", "<leader>mC", function() md.generate_toc() end, desc("Create TOC"))
map("n", "<leader>mi", function() md.create_image() end, desc("Insert Image"))
map("n", "<leader>ml", function() md.create_link() end, desc("Insert Link"))
map("n", "<leader>mm", function() md.create_table() end, desc("Create table"))

-- Database Group
map("n", "<leader>Du", "<cmd>DBUI<CR>", desc("Open DBUI"))

-- Terminal Group
map("n", "<leader>tt", function() require("snacks").terminal.toggle() end, desc("Toggle Terminal (Snacks)"))
map("n", "<leader>tr", "<cmd>lua open_right_terminal_with_mst()<CR>", desc("Open Split with Mistral"))
map("n", "<leader>tc", function() require("snacks").terminal.toggle() end, desc("Toggle Terminal"))
map("n", "<leader>tx", "<cmd>lua close_current_terminal()<CR>", desc("Close Current Terminal"))
map("n", "<leader>td", function() scan_with_deepseek() end, desc("Scan with Deepseek"))

-- Harpoon Group
map("n", "<leader>ha", function() require("harpoon"):list():add() end, desc("Add File"))
map("n", "<leader>hr", function() require("harpoon"):list():remove() end, desc("Remove File"))
map("n", "<leader>hh", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc("Toggle Menu"))
map("n", "<leader>h1", function() require("harpoon"):list():select(1) end, desc("Go to File 1"))
map("n", "<leader>h2", function() require("harpoon"):list():select(2) end, desc("Go to File 2"))
map("n", "<leader>h3", function() require("harpoon"):list():select(3) end, desc("Go to File 3"))
map("n", "<leader>h4", function() require("harpoon"):list():select(4) end, desc("Go to File 4"))

-- Todo Group
map("n", "<leader>Ta", "<cmd>TodoTrouble<cr>", desc("Show Todos in Trouble"))
map("n", "<leader>Tf", "<cmd>TodoTelescope<cr>", desc("Find Todos"))
map("n", "<leader>Tn", "<cmd>TodoNext<cr>", desc("Next Todo"))
map("n", "<leader>Tp", "<cmd>TodoPrev<cr>", desc("Previous Todo"))
map("n", "<leader>Tt", "<cmd>TodoToggle<cr>", desc("Toggle Todo Highlighting"))

-- Word Count Group
map("n", "<leader>Wc", ":echo wordcount().words<CR>", desc("Show Word Count"))

-- Tools Group
map("n", "<leader>xr", function() reload_config() end, desc("Reload Config"))
map("n", "<leader>xf", "<cmd>lua _PYTHON_FLOAT()<CR>", desc("Flashcards"))
map("n", "<leader>xt", "<cmd>lua _python_planner_toggle()<CR>", desc("Planner"))
map("n", "<leader>xn", "<cmd>lua _python_inkdex_toggle()<CR>", desc("Inkdex"))
map("n", "<leader>xp", "<cmd>lua _python_pomo_toggle()<CR>", desc("Pomodoro"))
map("n", "<leader>xo", function() _G._python_totp_toggle() end, desc("OTP Dashboard"))
map("n", "<leader>xd", function() open_db_viewer() end, desc("Open DB Viewer"))
map("n", "<leader>xs", function() require("snacks").scratch() end, desc("Toggle Scratch Pad"))

-- Spell Check Group
map("n", "<leader>st", ":set spell!<CR>", desc("Toggle Spell Check"))
map("n", "<leader>sn", "]s", desc("Next Spelling Error"))
map("n", "<leader>sp", "[s", desc("Previous Spelling Error"))
map("n", "<leader>ss", "z=", desc("Suggestions for Word"))
map("n", "<leader>sa", "zg", desc("Add Word to Dictionary"))
map("n", "<leader>sr", "zw", desc("Remove Word from Dictionary"))
map("n", "<leader>sc", function() correct_first_spell_suggestion() end, desc("Correct word"))

-- Find (Snacks Picker) Group
map("n", "<leader>ff", function() require("snacks").picker.files() end, desc("Find files"))
map("n", "<leader>fg", function() require("snacks").picker.grep() end, desc("Find text (Grep)"))
map("n", "<leader>fb", function() require("snacks").picker.buffers() end, desc("Find buffers"))
map("n", "<leader>fh", function() require("snacks").picker.command_history() end, desc("Find history"))
map("n", "<leader>fH", function() require("snacks").picker.help() end, desc("Find Help"))
map("n", "<leader>fd", function() require("snacks").picker.diagnostics() end, desc("Find Diagnostics"))
map("n", "<leader>fc", function() require("snacks").picker.git_log() end, desc("Find commits"))
map("n", "<leader>fl", function() require("snacks").picker.lines() end, desc("Find in buffer"))
map("n", "<leader>fm", function() require("snacks").picker.keymaps() end, desc("Find keymaps"))
map("n", "<leader>fk", function() require("snacks").picker.keymaps() end, desc("Find keymaps (Snacks)"))
map("n", "<leader>fr", function() require("snacks").picker.recent() end, desc("Find Recent Files"))
map("n", "<leader>f'", function() require("snacks").picker.marks() end, desc("Find marks"))
map("n", "<leader>ft", function() require("snacks").picker.colorschemes() end, desc("Find Themes"))

-- Theme Group
map("n", "<leader>ld", function() vim.o.background = "dark"; vim.cmd("colorscheme purple") end, desc("Dark Theme"))
map("n", "<leader>ll", function() vim.o.background = "light"; vim.cmd("colorscheme purplecalm_light") end, desc("Light Theme"))
map("n", "<leader>lt", function() require("snacks").picker.colorschemes() end, desc("Theme Picker (Snacks)"))

-- TMUX Group
map("n", "<leader>ur", ":silent !tmux source ~/.tmux.conf<CR>", desc("Reload tmux config"))
map("n", "<leader>us", ":silent !tmux new-session -s mysession<CR>", desc("Start new session"))
map("n", "<leader>ua", ":silent !tmux attach-session -t mysession<CR>", desc("Attach to session"))
map("n", "<leader>uk", ":!tmux kill-session -t mysession<CR>", desc("Kill session"))
map("n", "<leader>uv", ":silent !tmux split-window -v<CR>", desc("Vertical Split"))
map("n", "<leader>uh", ":silent !tmux split-window -h<CR>", desc("Horizontal Split"))
map("n", "<leader>ue", function() save_tmux_session() end, desc("Save Tmux Session"))
map("n", "<leader>un", ":!tmux new-window<CR>", desc("New window"))
map("n", "<leader>uw", function() _G.tmux_window_picker() end, desc("List windows (Menu)"))
map("n", "<leader>up", ":!tmux previous-window<CR>", desc("Previous window"))
map("n", "<leader>ux", ":!tmux next-window<CR>", desc("Next window"))
map("n", "<leader>ud", ":!tmux detach<CR>", desc("Detach session"))
map("n", "<leader>ul", function() _G.tmux_session_picker() end, desc("List sessions (Menu)"))

-- Buffer Group
map("n", "<leader>bn", "<cmd>enew<CR>", desc("New Buffer"))
map("n", "<leader>bc", "<cmd>bdelete<CR>", desc("Close Buffer"))
map("n", "<leader>bh", "<cmd>bprevious<CR>", desc("Previous Buffer"))
map("n", "<leader>bl", "<cmd>bnext<CR>", desc("Next Buffer"))

-- Git Group (Replaced Fugit2 with Snacks.lazygit)
map("n", "<leader>gg", function() require("snacks").lazygit() end, desc("Open LazyGit"))
map("n", "<leader>gb", function() require("snacks").picker.git_status() end, desc("Git Status"))
map("n", "<leader>gl", function() require("snacks").picker.git_log() end, desc("Git Log"))
map("n", "<leader>gd", "<cmd>Fugit2<CR>", desc("Fugit2 Dashboard"))

-- Ranger Group (Replaced with Snacks Explorer)
map("n", "<leader>Rr", function() require("snacks").explorer() end, desc("Toggle Explorer"))

-- Extra Bufferline mappings
map("n", "<S-l>", ":bnext<CR>", desc("Next Buffer"))
map("n", "<S-h>", ":bprevious<CR>", desc("Previous Buffer"))


-- ============================================================================
-- 🏷️ WHICH-KEY GROUP NAMING (Optional, for display only)
-- ============================================================================
local ok, wk = pcall(require, "which-key")
if ok then
  if wk.add then
    -- V3 Syntax
    wk.add({
      { "<leader>D", group = "Database" },
      { "<leader>R", group = "Explorer" },
      { "<leader>T", group = "Todo" },
      { "<leader>W", group = "Word Count" },
      { "<leader>b", group = "Buffer" },
      { "<leader>f", group = "Find (Snacks)" },
      { "<leader>g", group = "Git" },
      { "<leader>h", group = "Harpoon" },
      { "<leader>l", group = "Theme" },
      { "<leader>m", group = "Markdown" },
      { "<leader>mx", desc = "Toggle checkbox" },
      { "<leader>r", group = "Run" },
      { "<leader>s", group = "Spell Check" },
      { "<leader>t", group = "Terminal" },
      { "<leader>u", group = "TMUX" },
      { "<leader>x", group = "Tools" },
    })
  else
    -- V2 Syntax
    wk.register({
      D = { name = "Database" },
      R = { name = "Explorer" },
      T = { name = "Todo" },
      W = { name = "Word Count" },
      b = { name = "Buffer" },
      f = { name = "Find (Snacks)" },
      g = { name = "Git" },
      h = { name = "Harpoon" },
      l = { name = "Theme" },
      m = { 
        name = "Markdown",
        x = { function() require("my_markdown").toggle_checkbox() end, "Toggle checkbox" },
      },
      r = { name = "Run" },
      s = { name = "Spell Check" },
      t = { name = "Terminal" },
      u = { name = "TMUX" },
      x = { name = "Tools" },
    }, { prefix = "<leader>" })
  end
end