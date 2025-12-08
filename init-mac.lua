-- Lazy.nvim setup

local lazypath = vim.fn.stdpath('data')..'/lazy/lazy.nvim'

if not vim.loop.fs_stat(lazypath) then

  vim.fn.system({

    'git', 'clone', '--filter=blob:none', '--single-branch', 'https://github.com/folke/lazy.nvim', lazypath

  })

end

vim.opt.rtp:prepend(lazypath)

vim.opt.number = true

vim.opt.relativenumber = true



-- Set leader key to space

vim.g.mapleader = " "



-- DB Save location

vim.g.db_ui_save_location = "~/.config/nvim/db_queries"



-- Patch vim.lsp.client.resolve_bufnr to avoid bufnr errors

local client = require("vim.lsp.client")

local old_resolve_bufnr = client.resolve_bufnr



client.resolve_bufnr = function(bufnr)

  if type(bufnr) == "function" then

    return 0 -- default to current buffer if a function is passed

  end

  return old_resolve_bufnr(bufnr)

end



-- Word count function for lualine

local function word_count()

    local wc = vim.fn.wordcount()

    if wc["visual_words"] then

        return wc["visual_words"] .. " words"

    else

        return wc["words"] .. " words"

    end

end



-- Lazy.nvim setup

require("lazy").setup({

   {

  "hrsh7th/nvim-cmp",

  dependencies = {

    "hrsh7th/cmp-nvim-lsp",

    "neovim/nvim-lspconfig",

    "jose-elias-alvarez/null-ls.nvim",

    "nvim-lua/plenary.nvim",

  },

  config = function()

-- 🔧 Patch resolve_bufnr early to prevent "expected number, got function"

    do

      local client = require("vim.lsp.client")

      local old_resolve_bufnr = client.resolve_bufnr

      client.resolve_bufnr = function(bufnr)

        if type(bufnr) == "function" then

          return vim.api.nvim_get_current_buf()

        end

        return old_resolve_bufnr(bufnr)

      end

    end

    pcall(function()

      local cmp = require("cmp")

      cmp.setup({

        mapping = cmp.mapping.preset.insert({

          ["<Tab>"]   = cmp.mapping.select_next_item(),

          ["<S-Tab>"] = cmp.mapping.select_prev_item(),

          ["<CR>"]    = cmp.mapping.confirm({ select = true }),

        }),

        sources = {

          { name = "nvim_lsp" },

          { name = "buffer"   },

          { name = "path"     },

        },

      })



      local lspconfig = require("lspconfig")

      lspconfig.tsserver.setup({

        capabilities = require("cmp_nvim_lsp").default_capabilities(),

      })



      local null_ls = require("null-ls")

      null_ls.setup({

        sources = {

          null_ls.builtins.formatting.prettier,

          null_ls.builtins.diagnostics.eslint_d,

        },

      })

    end)

  end,

}, {

  "ThePrimeagen/harpoon",

  branch = "harpoon2",

  dependencies = { "nvim-lua/plenary.nvim" },

  config = function()

    local harpoon = require("harpoon")

    harpoon:setup()

  end,

},{

  "glepnir/dashboard-nvim",

  event = "VimEnter",

  config = function()

    local function safe_cmd(cmd)

      local output = vim.fn.system(cmd)

      if vim.v.shell_error ~= 0 then

        return nil

      end

      return output:gsub("\n", "")

    end



    local function get_system_info()

      local uname = safe_cmd("uname -sr") or "Unknown OS"



      -- uptime: fallback if -p isn't supported

      local uptime = safe_cmd("uptime -p") or safe_cmd("uptime") or "Unknown Uptime"



      local date = os.date("%a %d %b %Y %H:%M:%S")



      -- macOS RAM usage

      local meminfo = safe_cmd([[

        vm_stat | awk 'NR==2{free=$3} NR==3{active=$3} NR==4{inactive=$3} NR==5{spec=$3} NR==6{wired=$3} 

        END{

          total=(free+active+inactive+spec+wired)*4096/1024/1024; 

          used=(active+inactive+spec+wired)*4096/1024/1024; 

          printf("%dMi/%dMi", used, total)

        }'

      ]]) or "Unknown Mem"



      -- macOS CPU usage

      local cpu = safe_cmd([[ps -A -o %cpu | awk '{s+=$1} END {print s "%"}']]) or "Unknown CPU"



      return {

        "  " .. uname,

        "  " .. uptime,

        "  CPU: " .. cpu,

        "  RAM: " .. meminfo,

        "  " .. date,

      }

    end



    require("dashboard").setup({

      config = {

        header = {

          "      ___                                 ___     ",

          "     /__/\\         ___       ___         /__/\\    ",

          "     \\  \\:\\       /__/\\     /  /\\       |  |::\\   ",

          "      \\  \\:\\      \\  \\:\\   /  /:/       |  |:|:\\  ",

          "  _____\\__\\:\\      \\  \\:\\ /__/::\\     __|__|:|\\:\\ ",

          " /__/::::::::\\  ___ \\__\\:\\\\__\\/\\:\\__ /__/::::| \\:\\",

          " \\  \\:\\~~\\~~\\/ /__/\\ |  |:|   \\  \\:\\/\\ \\  \\:\\~~\\__\\/",

          "  \\  \\:\\  ~~~  \\  \\:\\|  |:|    \\__\\::/  \\  \\:\\      ",

          "   \\  \\:\\       \\  \\:\\__|:|    /__/:/    \\  \\:\\     ",

          "    \\  \\:\\       \\__\\::::/     \\__\\/      \\  \\:\\    ",

          "     \\__\\/           ~~~~                  \\__\\/    ",

          "",

          ""

        },

        footer = get_system_info(),

        packages = { enable = false },

        project = { enable = false },

        mru = { limit = 5 },

        shortcut = {

          { desc = " Update", group = "@property", action = "Lazy update", key = "u" },

          { icon = " ", desc = "Files", group = "@property", action = ":FzfFiles<CR>", key = "f" },

          { desc = " Grep", group = "@property", action = ":FzfRg<CR>", key = "g" },

          { desc = " Exit", group = "@property", action = "qa", key = "q" },

        },

      },

    })

  end,

},{

        "andweeb/presence.nvim",

        config = function()

            require("presence").setup({

                -- configuration options

                auto_update = true,   -- Automatically update presence

                neovim_image_text = "The One True Text Editor",  -- Text displayed for Neovim

                main_image = "file",  -- Main image used for RPC (can use other sources like 'file', 'text', etc.)

                large_image_text = "neovim",

                edit_mode = "false",

                enable_line_number = true,

                client_id = "1330968227001532560",  -- You'll need to create a Discord application to get this ID

                log_level = "info",    -- Log level for RPC updates

                editing_text = "Editing %s",  -- Shows the file you're editing

                file_explorer_text = "Browsing %s",

                reading_text = "Reading %s",

                plugin_manager_text = "Managing Plugins",

                line_number_text = "Line %s out of %s"

            })

        end

    },

{

  'SuperBo/fugit2.nvim',

  dependencies = {

    'nvim-lua/plenary.nvim',

    'nvim-telescope/telescope.nvim',

  },

  config = function()

    require('fugit2').setup()

  end,

},

    {

  "ellisonleao/glow.nvim",

  cmd = "Glow", -- only load when you run :Glow

  config = function()

    require("glow").setup({

      style = "dark", -- or "light"

      width = 120,

    })

  end,

}, {

  "christoomey/vim-tmux-navigator",

  lazy = false

},{

  "hedyhli/outline.nvim",

  config = function()

    require("outline").setup {

      symbols = {

        markdown = {

          -- headings are supported

          icon = "󰽂",

        },

      },

    }

  end

},{

  "junegunn/fzf.vim",

  dependencies = {

    "junegunn/fzf",

    build = ":call fzf#install()",

  },

  config = function()

    -- Basic FZF configuration

    vim.g.fzf_layout = {

      window = {

        width = 0.9,

        height = 0.9,

        border = 'rounded'

      }

    }



    -- Custom colors to match your theme

    vim.cmd([[

      let g:fzf_colors = {

        \ 'fg':      ['fg', 'Normal'],

        \ 'bg':      ['bg', 'Normal'],

        \ 'hl':      ['fg', 'Comment'],

        \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],

        \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],

        \ 'hl+':     ['fg', 'Statement'],

        \ 'info':    ['fg', 'PreProc'],

        \ 'border':  ['fg', 'Ignore'],

        \ 'prompt':  ['fg', 'Conditional'],

        \ 'pointer': ['fg', 'Exception'],

        \ 'marker':  ['fg', 'Keyword'],

        \ 'spinner': ['fg', 'Label'],

        \ 'header':  ['fg', 'Comment']

      \ }

    ]])

  end

    },

  {

    'nvim-lualine/lualine.nvim',

    config = function()

      require('lualine').setup({

        options = { theme = 'auto' },

        sections = {

          lualine_a = {'mode'},

          lualine_b = {'branch'},

          lualine_c = {'filename', word_count},

          lualine_x = {'encoding', 'fileformat', 'filetype'},

          lualine_y = {'progress'},

          lualine_z = {'location'}

        }

      })

    end

  },

  {

  "kelly-lin/ranger.nvim",

  config = function()

    require("ranger-nvim").setup({

      replace_netrw = true,

      enable_cmds = true,

      keybinds = {

        ["o"] = "open",

        ["v"] = "open_vsplit",

        ["s"] = "open_split",

        ["t"] = "open_tab",

        ["q"] = "quit",

      },

    })

  end,

},

  {

  "alex-laycalvert/flashcards.nvim",

  config = function()

    require("flashcards").setup({

      -- path to your deck folder

      deck_dir = "~/notes/flashcards",

      -- optional: how many cards per session

      session_length = 20,

    })

  end,

  },

  {

  "MeanderingProgrammer/render-markdown.nvim",

  ft = { "markdown" },

  dependencies = {

    "nvim-treesitter/nvim-treesitter",

    "nvim-tree/nvim-web-devicons",

  },

  config = function()

    require("render-markdown").setup({

      heading = { enabled = true },

      bullet = {

        enabled = true,

        icons = { "●", "○", "◆", "◇" },

      },

      checkbox = {

        enabled = true,

        icons = {

          unchecked = "󰄱 ",

          checked = "󰱒 ",

          pending = "󱍢 ",

        },

      },

      code = { enabled = true, style = "full" },

      quote = { enabled = true, icon = "󰉺" },

    })

  end,

},{

  "f-person/auto-dark-mode.nvim",

  config = function()

    require("auto-dark-mode").setup({

      update_interval = 1000,

      set_dark_mode = function()

        vim.o.background = "dark"

      end,

      set_light_mode = function()

        vim.o.background = "light"

      end,

    })

  end,

},

{

  "nvim-treesitter/nvim-treesitter",

  build = ":TSUpdate",

  config = function()

    require("nvim-treesitter.configs").setup({

      -- Automatically install Markdown parsers if missing

      ensure_installed = { "lua", "markdown", "markdown_inline" },

      auto_install = true,

      highlight = { enable = true },

    })

  end,

},

  {

    'nvim-telescope/telescope.nvim',

    dependencies = { 'nvim-lua/plenary.nvim' },

  },

  { "EdenEast/nightfox.nvim" },

  {

    'folke/which-key.nvim',

    config = function()

      require("which-key").setup {

        plugins = {

          marks = true,

          registers = true,

          spelling = { enabled = true, suggestions = 20 },

        },

        icons = {

          breadcrumb = '»', 

          separator = '➔', 

          group = '+',

        },

        window = {

          border = 'rounded',

          position = 'bottom',

          margin = { 1, 0, 1, 0 },

        },

      }

    end

  },

{

    "morhetz/gruvbox",

    config = function()

    end

},{

    'numToStr/Comment.nvim',

    config = function()

        require('Comment').setup({

            -- Add your custom configuration here

            toggler = {

                line = 'gcc', -- Line comment toggle keymap

                block = 'gbc', -- Block comment toggle keymap

            },

            opleader = {

                line = 'gc', -- Line comment keymap

                block = 'gb', -- Block comment keymap

            },

            mappings = {

                basic = true,

                extra = true

            }, -- Enable default keybindings

            pre_hook = nil, -- Add pre-hook for integration with Treesitter or LSP

            post_hook = nil, -- Add post-hook if needed

        })

    end

},

   {

    'akinsho/toggleterm.nvim',

    config = function()

      require("toggleterm").setup({

        size = 20,

        open_mapping = [[<c-\>]], -- You can change this shortcut

        shade_filetypes = {},

        shade_terminals = true,

        shading_factor = 2,

        direction = "vertical",

        float_opts = {

          border = "curved",

        },

      })

    end

  },

 {

        'iamcco/markdown-preview.nvim',

        build = 'cd app && npm install', -- Ensures dependencies are installed

        ft = 'markdown',                -- Lazy load for markdown files

        config = function()

            vim.g.mkdp_auto_start = 0   -- Prevent auto-start

            vim.g.mkdp_auto_close = 1   -- Close preview on buffer switch

        end

    },

{

    "akinsho/bufferline.nvim",

    version = "*",

    dependencies = "nvim-tree/nvim-web-devicons",

    config = function()

      require("bufferline").setup({

        options = {

          mode = "buffers",

          diagnostics = "nvim_lsp",

          show_buffer_close_icons = true,

          show_close_icon = false,

          separator_style = "slant",

        },

      })

      vim.keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next Buffer" })

      vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { desc = "Previous Buffer" })

    end,

  },

  {

    "nvim-neo-tree/neo-tree.nvim",

    branch = "v2.x",

    dependencies = {

      "nvim-lua/plenary.nvim",       -- Required dependency

      "nvim-tree/nvim-web-devicons", -- Optional, for file icons

      "MunifTanjim/nui.nvim",        -- Required dependency for neo-tree

    },

    config = function()

      require("neo-tree").setup({

        close_if_last_window = true,      -- Close Neo-tree if it's the last open window

        filesystem = {

          filtered_items = {

            hide_dotfiles = false,        -- Show dotfiles by default

            hide_gitignored = true,       -- Hide Git ignored files

          },

        },

        window = {

          width = 30,                     -- Set the width of the neo-tree window

        },

        git_status = {

          enabled = true,                 -- Show git status in neo-tree

        },

      })

    end,

  },

  {

    "tpope/vim-dadbod",

    dependencies = {

        "kristijanhusak/vim-dadbod-ui",

        "kristijanhusak/vim-dadbod-completion"

    }

},

  {

        'neovim/nvim-lspconfig',

        config = function()

            local lspconfig = require("lspconfig")

            require("lspconfig").pyright.setup({}) -- Example: Python LSP

            require("lspconfig").tsserver.setup({}) -- Example: TypeScript LSP 

            -- Setup for Python (pyright) and C++ (clangd)

            lspconfig.pyright.setup({})

            lspconfig.clangd.setup({})

            lspconfig.gopls.setup({})

            

            -- Diagnostics configurations

            vim.diagnostic.config({

                virtual_text = true,  -- Display error messages inline

                signs = true,         -- Show error signs in the gutter

                update_in_insert = false,  -- Only update diagnostics when not in insert mode

            })

        end,

    },

    {

  "folke/snacks.nvim",

  lazy = false,

  priority = 1000,

  config = function()

    local Snacks = require("snacks")



    Snacks.setup({

      picker = {

        enabled = true,

      },

    })



    -- example mapping

    vim.keymap.set("n", "<leader>ff", function()

      Snacks.picker.files()

    end)

  end

},

   {

    "mfussenegger/nvim-lint",

    config = function()

        require('lint').linters_by_ft = {

            cpp = { 'cppcheck' },        -- Linter for C++

            python = { 'flake8' },       -- Linter for Python

            go = { 'golangcilint' },     -- Linter for Go

            java = { 'checkstyle' },     -- Linter for Java

        }

        -- Auto-lint on save

        vim.cmd([[

            autocmd BufWritePost *.cpp,*.py,*.go,*.java lua require('lint').try_lint()

        ]])

    end,

    },

{

  "folke/noice.nvim",

  dependencies = {

    "MunifTanjim/nui.nvim",

    "rcarriga/nvim-notify",

  },

  config = function()

    require("noice").setup({

      lsp = {

        progress = { enabled = true },

        hover = { enabled = true },

        signature = { enabled = false },

      },

      presets = {

        bottom_search = true,

        command_palette = true,

        long_message_to_split = true,

      },



      routes = {

        -- your existing compilation error route

        {

          filter = { event = "msg_show", kind = "error" },

          opts = {

            skip = false,

            title = "Compilation Error",

            icon = " ",

            message = function(msg)

              return "Error: " .. msg

            end,

          },

        },



        -- bottom-right notify

        {

          filter = { event = "notify" },

          view = "mini",

        },



        -- bottom-right regular messages (yanks, writes, errors, info)

        {

          filter = { event = "msg_show" },

          view = "mini",

        },

      },



      views = {

        -- bottom-right popup for all mini views

        mini = {

          position = { row = -1, col = -1 },

          border = { style = "rounded" },

          win_options = { winblend = 20 },

        },



        -- also route message view → mini, bottom-right

        messages = {

          view = "mini",

          position = { row = -1, col = -1 },

        },

      },

    })

  end,

},{

    "folke/todo-comments.nvim",

    config = function()

      require("todo-comments").setup()

    end,

  }

})



-- Creates banner for .cpp files

vim.api.nvim_create_autocmd("BufNewFile", {

  pattern = { "*.cpp", "*.py", "*.md", "*.go" },

  callback = function()

    local date = os.date("%Y-%m-%d")

    local filename = vim.fn.expand("%:t")

    local banner



    if vim.bo.filetype == "cpp" then

      -- C++ file banner

      banner = string.format([[

/*****************************

Author: Ashwin Nair

Date: %s

Project name: %s

Summary: Enter summary here.

*****************************/

]], date, filename)



    elseif vim.bo.filetype == "python" then

      -- Python file banner

      banner = string.format([[

"""

Author: Ashwin Nair

Date: %s

Project name: %s

Summary: Enter summary here.

"""

]], date, filename)



    elseif vim.bo.filetype == "markdown" then

      -- Markdown file banner

      banner = string.format([[

<!--

Author: Ashwin Nair

Date: %s

Project name: %s

Summary: Enter summary here.

-->

]], date, filename)



   elseif vim.bo.filetype == "go" then

    -- Go file banner

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



    -- Insert the banner at the top of the file

    if banner then

      vim.api.nvim_buf_set_lines(0, 0, 0, false, vim.split(banner, "\n"))

    end

  end,

})



local orig_notify = vim.notify

vim.notify = function(msg, level, opts)

  if type(msg) == "string" and msg:match("nvim%-cmp") then

    return -- drop cmp-related errors

  end

  orig_notify(msg, level, opts)

end



vim.api.nvim_create_user_command("WordCount", function()

    -- Get the current buffer number

    local bufnr = vim.api.nvim_get_current_buf()

    -- Get all lines in the buffer

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)



    -- Initialize word count

    local word_count = 0



    -- Iterate through each line

    for _, line in ipairs(lines) do

        -- Skip empty or whitespace-only lines

        if vim.trim(line) ~= "" then

            -- Count words in the line

            local words = vim.fn.split(vim.trim(line), "\\s+")

            word_count = word_count + #words

        end

    end



    -- Display the word count using vim.notify

    vim.notify("Word Count: " .. word_count, vim.log.levels.INFO, { title = "Word Count" })

end, { desc = "Counts words in the current buffer and displays the result" })



--  Monkey patch solution for lsp error

vim.api.nvim_create_autocmd("LspAttach", {

  callback = function()

    local source = require("cmp_nvim_lsp.source")

    local old_request = source._request

    source._request = function(self, method, params, callback)

      -- call with bufnr=0 (current buffer)

      local _, request_id = self.client:request(method, params, function(a1, a2, a3)

        if self.request_ids[method] ~= request_id then

          return

        end

        self.request_ids[method] = nil

        if a1 and a1.code == -32801 then

          self:_request(method, params, callback)

          return

        end

        if method == a2 then

          callback(a1, a3)

        else

          callback(a1, a2)

        end

      end, 0)

      self.request_ids[method] = request_id

    end

  end,

})



-- Replace vim.notify with a filtered version

local orig_notify = vim.notify



vim.notify = function(msg, level, opts)

  -- Always allow file write/save messages

  if msg:match("written") or msg:match("saved") then

    return orig_notify(msg, level, opts)

  end



  -- You can also allow errors/warnings if you want:

  if level == vim.log.levels.ERROR or level == vim.log.levels.WARN then

    return orig_notify(msg, level, opts)

  end



  -- Everything else: ignore silently

end



-- Silence giant error popups

vim.lsp.handlers["window/showMessage"] = function(_, result, _)

  local msg_type = result.type

  if msg_type == vim.lsp.protocol.MessageType.Warning

     or msg_type == vim.lsp.protocol.MessageType.Info then

    vim.notify(result.message, vim.log.levels.INFO)

  end

  -- Errors are ignored

end



-- Copy and paste from wez to other apps

vim.api.nvim_set_option("clipboard", "unnamed")



-- Function to switch theme and notify with Noice

local function set_theme(mode)

  if mode == "dark" then

    vim.opt.background = "dark"

    require("noice").notify("Switched to Dark Mode", "info")

  elseif mode == "light" then

    vim.opt.background = "light"

    require("noice").notify("Switched to Light Mode", "info")

  end

end



-- Function to scan the current file and get suggestions from DeepSeek

local function scan_with_deepseek()

    local file_path = vim.fn.expand('%:p') -- Get the full file path

    if file_path == "" or vim.bo.filetype == "" then

        vim.notify("No file selected!", vim.log.levels.WARN)

        return

    end



    local deepseek_cmd = "ollama run nezahatkorkmaz/deepseek-v3 < " .. file_path



    -- Open ToggleTerm and run DeepSeek command

    require("toggleterm.terminal").Terminal:new({

        cmd = deepseek_cmd,

        direction = "vertical", -- Opens in a horizontal split (you can change to "float" or "vertical")

        close_on_exit = false,    -- Keeps the terminal open after execution

    }):toggle()

end



-- Function to run Go files

function RunGoFile()

    local filepath = vim.fn.expand('%:p') -- Get the full path of the current file

    if vim.bo.filetype == "go" then

        vim.cmd("!go run " .. filepath)

    else

        print("Not a Go file!")

    end

end



-- PDF Viewer

vim.api.nvim_create_user_command('ViewPDF', function()

  local file = vim.fn.expand('%:p')  -- Get the full file path

  if file:match('%.pdf$') then  -- Check if the file is a PDF

    -- Open the PDF with Skim

    vim.fn.system("open -a Skim " .. file)

  else

    print("Not a PDF file!")

  end

end, { desc = "View the current PDF file" })



-- Basically sets comment.nvim and which-key to silent (they spam me :( ).

vim.notify = function(msg, ...)

    if msg:match("which-key") or msg:match("Comment.nvim") then

        return

    end

    require("notify")(msg, ...)

end



-- Custom command to open a floating terminal and send a notification

vim.api.nvim_create_user_command("ToggleTerminal", function()

  require("toggleterm").toggle()

  local path = vim.fn.getcwd()

  if pcall(require, "noice") then

    require("noice").notify("Opened terminal in " .. path, "info", { title = "Terminal" })

  else

    vim.notify("Opened terminal in " .. path, "info", { title = "Terminal" })

  end

end, {})



local totp_path = "/Users/ashwinnair/Documents/otpman"

local venv_totp = totp_path .. "/venv/bin/python3"

local totp_script = totp_path .. "/totp_ui.py"



-- Function to run the TOTP script in a floating terminal

local totp_path = "/Users/ashwinnair/Documents/otpman"

local venv_activate = totp_path .. "/venv/bin/activate"

local totp_script = totp_path .. "/totpui.py"



_G._python_totp_toggle = function()

  -- create a no-file buffer for the terminal

  local buf = vim.api.nvim_create_buf(false, true)

  local width = math.floor(vim.o.columns * 0.8)

  local height = math.floor(vim.o.lines * 0.8)

  local row = math.floor((vim.o.lines - height) / 2)

  local col = math.floor((vim.o.columns - width) / 2)



  local win = vim.api.nvim_open_win(buf, true, {

    relative = "editor",

    width = width,

    height = height,

    row = row,

    col = col,

    style = "minimal",

    border = "rounded",

  })



  -- Build a shell command that:

  -- 1) sources the venv activate script

  -- 2) runs the Python script

  -- 3) prints the exit code and waits for a keypress so you can read errors

  local shell_cmd = string.format([[

source "%s" >/dev/null 2>&1 || true

python3 "%s"

ret=$?

echo ""

echo "---- PROCESS EXITED (code $ret) ----"

echo "Press any key to close..."

read -n1 -s

exit $ret

]], venv_activate, totp_script)



  -- Run using bash -lc so the multiline command works

  vim.fn.termopen({ "bash", "-lc", shell_cmd }, {

    on_exit = function(_, exit_code, _)

      -- we don't auto-close here because the shell 'read' keeps it open until keypress.

      -- if you want it to forcibly close after keypress, uncomment below:

      -- if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end

    end,

  })



  -- enter insert mode automatically so the terminal is interactive

  vim.cmd("startinsert")

end



-- Ensure you have installed the necessary plugins by running :Lazy sync in Neovim

vim.api.nvim_create_user_command('OldFiles', function()

  require('telescope.builtin').oldfiles()

end, { desc = 'Show Recently Opened Files with Telescope' })



-- ToggleTerm setup for running C++ files in a floating terminal

local toggleterm = require("toggleterm.terminal").Terminal



function _G.close_current_terminal()

  local current_buf = vim.api.nvim_get_current_buf()

  -- Check if the current buffer is a terminal

  if vim.bo[current_buf].filetype == "toggleterm" then

    vim.cmd("bdelete!") -- Close the current terminal buffer

  else

    print("Not a terminal window")

  end

end



local Terminal  = require("toggleterm.terminal").Terminal



-- Define a terminal that runs a specific Python file

local python_term = Terminal:new({

  cmd = "python3 ~/Dropbox/LoyolaCoursework/flashcards/flashcards.py", -- change to your Python file path

  hidden = true,

  direction = "float",

  float_opts = {

    border = "curved",

    width = 100,

    height = 30,

  }

})



-- Define a terminal that runs a specific Python file

local python_term_planner = Terminal:new({

  cmd = "python3 ~/Dropbox/LoyolaCoursework/Dash/daily-planner.py", -- change to your Python file path

  hidden = true,

  direction = "float",

  float_opts = {

    border = "curved",

    width = 100,

    height = 30,

  }

})



-- Define a terminal that runs a specific Python file

local python_term_inkdex = Terminal:new({

  cmd = "python3 ~/Dropbox/LoyolaCoursework/notes/notebook.py", -- change to your Python file path

  hidden = true,

  direction = "float",

  float_opts = {

    border = "curved",

    width = 100,

    height = 30,

  }

})



-- Define a terminal that runs a specific Python file

local python_term_pomo = Terminal:new({

  cmd = "python3 ~/Dropbox/LoyolaCoursework/pomo/pomo.py", -- change to your Python file path

  hidden = true,

  direction = "vertical",

  float_opts = {

    border = "curved",

    width = 100,

    height = 30,

  }

})



-- Function to toggle it

function _PYTHON_FLOAT()

  python_term:toggle()

end



-- Wrapper function to toggle it

function _python_planner_toggle()

  python_term_planner:toggle()

end



-- Wrapper function to toggle it

function _python_inkdex_toggle()

  python_term_inkdex:toggle()

end



-- Wrapper function to toggle it

function _python_pomo_toggle()

  python_term_pomo:toggle()

end



local function run_java()

  local file = vim.fn.expand("%:p") -- Full path of the current file

  local class_name = vim.fn.expand("%:t:r") -- Extract class name without extension

  local compile_run_cmd = "javac " .. file .. " && java " .. class_name

  -- If using tmux instead of toggleterm

  os.execute("tmux new-session -d '" .. compile_run_cmd .. "'")

  os.execute("tmux attach-session -d")

end



local function set_pending()

  local line = vim.api.nvim_get_current_line()

  -- replace [ ] or [x] with [-]

  line = line:gsub("%[.%]", "[-]")

  -- write line back

  vim.api.nvim_set_current_line(line)

end



function run_cpp_file()

  vim.cmd("w")  -- Save the file

  local compile_cmd = "g++ " .. vim.fn.expand("%") .. " -o " .. vim.fn.expand("%:r")

  vim.fn.system(compile_cmd)



  if vim.v.shell_error == 0 then

    local executable = vim.fn.expand("%:r")

    local cpp_terminal = toggleterm:new({

      cmd = executable,

      direction = "float",

      close_on_exit = false,

      hidden = true

    })

    cpp_terminal:toggle()

  else

    print("Compilation failed. Please check for errors.")

  end

end



-- Runs the TODO file in a toggle term window

local function run_specific_cpp_file()

    local filepath = "/Users/ashwinnair/Dropbox/LoyolaCoursework/Fall2024/COSC-A211/final_project/main.cpp" 

    local compile_cmd = "g++ -std=c++17 -Wall -o temp_exec " .. filepath

    local run_cmd = "./temp_exec"



    vim.notify("Opened ToDo List!")

    -- Open a floating terminal and execute the commands

    require("toggleterm.terminal").Terminal:new({

        cmd = compile_cmd .. " && " .. run_cmd,

        direction = "float",

        close_on_exit = false, -- Keeps the terminal open after running

    }):toggle()

end



-- Run Tmux Session saving protocol

local function save_tmux_session()

  vim.fn.system("tmux run-shell ~/.tmux/plugins/tmux-resurrect/scripts/save.sh")

  require("noice").notify("Tmux session saved successfully!", {

    title = "Tmux Session",

    icon = "💾",

    level = "success",

    timeout = 2000,

  })

end



-- ─────────────────────────────────────────────

-- Local function: Add Markdown Table Row

-- ─────────────────────────────────────────────

local function add_markdown_table_row()

  local line = vim.api.nvim_get_current_line()



  -- Count how many '|' characters there are

  local pipe_count = select(2, line:gsub("|", "")) - 1

  if pipe_count < 1 then

    vim.notify("Not inside a Markdown table", vim.log.levels.WARN)

    return

  end



  -- Create a new row with the same number of columns

  local new_row = "|" .. string.rep(" --- |", pipe_count)

  new_row = new_row:sub(1, #new_row - 1) .. "|" -- ensure final pipe



  -- Insert it below the current line

  local row_num = vim.fn.line(".")

  vim.fn.append(row_num, new_row)

  vim.cmd("normal! j0")

end

-- Runs java file.

local Terminal = require("toggleterm.terminal").Terminal



local function run_java()

  local file = vim.fn.expand("%:p") -- Get the full path of the current file

  local filename_without_ext = vim.fn.expand("%:t:r") -- Get filename without extension

  local compile_run_cmd = "javac " .. file .. " && java " .. filename_without_ext



  local java_terminal = Terminal:new({

    cmd = compile_run_cmd,

    direction = "float", -- or "horizontal", "vertical"

    close_on_exit = false

  })



  java_terminal:toggle()

end



-- For Neo-tree

vim.cmd [[

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

]]



-- For Noice notifications

vim.cmd [[

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

]]





-- Automatically lint and clear diagnostics on save

vim.cmd([[

    autocmd BufWritePost *.cpp,*.py,*.md lua require('lint').try_lint()

    autocmd BufWritePost *.cpp,*.py,*.md lua vim.diagnostic.hide() -- Clears diagnostics after display

]])



-- Enable spell checking for specific file types

vim.api.nvim_create_autocmd("FileType", {

    pattern = { "markdown", "text", "gitcommit" }, -- Add other file types as needed

    callback = function()

        vim.opt_local.spell = true

        vim.opt_local.spelllang = "en"

    end,

})



vim.api.nvim_create_autocmd("FileType", {

  pattern = "fzf",

  callback = function()

    -- Make FZF window more prominent

    vim.opt_local.number = false

    vim.opt_local.relativenumber = false

    -- Hide statusline in fzf buffer

    vim.opt_local.laststatus = 0

    -- Return to normal laststatus after closing fzf

    vim.api.nvim_create_autocmd("BufLeave", {

      buffer = 0,

      callback = function()

        vim.opt_local.laststatus = 2

      end

    })

  end

})



-- Custom highlighting for spelling errors

vim.cmd([[

highlight clear SpellBad

highlight SpellBad cterm=underline ctermfg=Red guibg=None guifg=Red

]])



-- Set color bar at :80 characters

vim.opt.colorcolumn = "80"   -- Set color bar at the 80th column

vim.cmd([[highlight ColorColumn ctermbg=0 guibg=blue]])   -- Customize the color



-- Set tab width to 4 spaces

vim.opt.tabstop = 4      -- Number of spaces that a <Tab> in the file counts for

vim.opt.shiftwidth = 4   -- Number of spaces to use for each step of (auto)indent

vim.opt.expandtab = true -- Convert tabs to spaces



-- Autocomplete polishing?

vim.opt.pumblend = 10 -- 0 to 100 for transparency

vim.opt.winblend = 10  -- Make floating windows more transparent



-- Function to run the DB viewer on the current file's directory

local function open_db_viewer()

  local home = vim.fn.expand("~")

  local file_dir = vim.fn.expand("%:p:h")  -- current file's directory

  local script_path = home .. "/Documents/GitHub/terminal-database-scanner/db_viewer.py"



  local cmd = "python3 " .. script_path .. " " .. file_dir



  require("toggleterm.terminal").Terminal

      :new({ cmd = cmd, direction = "float", hidden = true })

      :toggle()

end



-- Ensure toggleterm.nvim is loaded

local Terminal = require("toggleterm.terminal").Terminal



-- Create a custom terminal instance with specified options

local mst_terminal = Terminal:new({

  direction = "vertical",

  size = 30, -- Adjust the width as needed

  on_open = function(term)

    -- Send 'mst' command to the terminal when it opens

    vim.api.nvim_feedkeys("mst\n", "n", false)

  end,

})



-- Function to toggle the custom terminal

function _G.open_right_terminal_with_mst()

  mst_terminal:toggle()

end



-- Function for Markdown -> PDF

local function markdown_to_pdf()

    local file_path = vim.fn.expand("%:p")

    if file_path == "" or not file_path:match("%.md$") then

        vim.notify("No Markdown file selected", vim.log.levels.WARN)

        return

    end



    local pdf_name = vim.fn.input("Enter PDF name (without .pdf extension): ") .. ".pdf"

    local pdf_path = vim.fn.expand("%:p:h") .. "/" .. pdf_name



    -- Pandoc command with xelatex for font customization

    local command = {

        "pandoc", file_path,

        "--pdf-engine=xelatex",

        "-o", pdf_path,

        "-V", "mainfont=Times New Roman",

        "-V", "fontsize=12pt"

    }



    vim.fn.jobstart(command, {

        stdout_buffered = true,

        stderr_buffered = true,

        on_stdout = function(_, data)

            if data then

                vim.notify(table.concat(data, "\n"), vim.log.levels.INFO)

            end

        end,

        on_stderr = function(_, data)

            if data then

                -- Filter out title warnings

                local filtered_errors = {}

                for _, line in ipairs(data) do

                    if not line:match("requires a nonempty <title> element") then

                        table.insert(filtered_errors, line)

                    end

                end

                if #filtered_errors > 0 then

                    vim.notify("Pandoc Error: " .. table.concat(filtered_errors, "\n"), vim.log.levels.ERROR)

                end

            end

        end,

        on_exit = function(_, exit_code)

            if exit_code == 0 then

                vim.notify("PDF created: " .. pdf_path, vim.log.levels.INFO)

            else

                vim.notify("Error creating PDF", vim.log.levels.ERROR)

            end

        end,

    })

end





local noice = require("noice")



-- Function to notify about misspelled words

local function notify_spell_error()

    if vim.wo.spell then

        local line = vim.api.nvim_get_current_line()

        local cursor_pos = vim.api.nvim_win_get_cursor(0)

        local col = cursor_pos[2]

        local word = vim.fn.matchstr(line:sub(1, col + 1), "\\k*$")

            .. vim.fn.matchstr(line:sub(col + 2), "^\\k*")



        if word ~= "" and vim.fn.spellbadword(word)[1] ~= "" then

            noice.notify("Misspelled Word: " .. word, "warn", {

                title = "Spell Check",

            })

        end

    end

end



-- Function to create a markdown table

local function create_markdown_table()

  vim.ui.input({ prompt = "Enter rows,columns (e.g. 2,3): " }, function(input)

    if not input then return end

    local rows, cols = input:match("(%d+),(%d+)")

    rows, cols = tonumber(rows), tonumber(cols)

    if not rows or not cols then

      vim.notify("Invalid format. Use rows,cols (e.g. 2,3)", vim.log.levels.ERROR)

      return

    end



    local lines = {}



    -- Header row

    local header = {}

    for c = 1, cols do

      table.insert(header, "Header" .. c)

    end

    table.insert(lines, "| " .. table.concat(header, " | ") .. " |")



    -- Separator row

    local separator = {}

    for _ = 1, cols do

      table.insert(separator, "---")

    end

    table.insert(lines, "| " .. table.concat(separator, " | ") .. " |")



    -- Data rows

    for r = 1, rows do

      local row = {}

      for c = 1, cols do

        table.insert(row, "Row" .. r .. "Col" .. c)

      end

      table.insert(lines, "| " .. table.concat(row, " | ") .. " |")

    end



    -- Insert at cursor

    vim.api.nvim_put(lines, "l", true, true)

  end)

end



-- Define a custom command for toggling Markdown preview

vim.api.nvim_create_user_command('MarkdownPreviewToggle', function()

    vim.cmd("MarkdownPreviewToggle") -- Use the plugin's built-in toggle

end, { desc = "Toggle Markdown Preview" })



-- Call function on CursorHold for real-time updates

vim.api.nvim_create_autocmd("CursorHold", {

    callback = notify_spell_error,

})



-- Silence all LSP notifications

vim.lsp.handlers["window/showMessage"] = function() end



-- Save original notify

local orig_notify = vim.notify



-- Override to filter out giant cmp-nvim-lsp errors

vim.notify = function(msg, log_level, opts)

  if type(msg) == "string" and msg:match("bufnr: expected number, got function") then

    return -- ignore this error

  end

  orig_notify(msg, log_level, opts) -- otherwise show normally

end



-- Enable treesitter-based folding

vim.o.foldmethod = "expr"

vim.o.foldexpr = "nvim_treesitter#foldexpr()"

vim.o.foldlevel = 99 -- start unfolded



local wk = require("which-key")



vim.cmd("colorscheme purple")



-- ===========================================

-- Markdown fenced code block color overrides

-- ===========================================

vim.api.nvim_create_autocmd("FileType", {

  pattern = "markdown",

  callback = function()

    -- Color palette (muted purple + accents)

    local bg      = "#221F2F"  -- dark muted purple

    local border  = "#2E2B3B"  -- slightly lighter for subtle edges

    local cyan    = "#88C0D0"  -- soft cyan accent

    local orange  = "#D08770"  -- muted orange

    local green   = "#A3BE8C"  -- muted green



    vim.cmd(string.format([[

      " Background for fenced code blocks

      hi! markdownCodeBlock guibg=%s guifg=%s



      " Backticks and fences (```lang)

      hi! markdownCodeDelimiter guifg=%s gui=bold



      " Remove harsh syntax injection but keep *subtle* accents

      hi! @markup.raw.markdown guibg=%s guifg=%s

      hi! @markup.raw_block.markdown guibg=%s guifg=%s

      hi! @markup.raw.delimiter.markdown guifg=%s gui=bold



      " Very soft syntax coloring for code inside fences

      hi! @string.markdown guifg=%s

      hi! @keyword.markdown guifg=%s

      hi! @function.markdown guifg=%s

    ]], bg, cyan, orange, bg, cyan, bg, cyan, orange, green, orange, cyan))

  end,

})



-- Turn hard LSP errors into silent logs

vim.lsp.handlers["window/showMessage"] = function(_, result, ctx, config)

  local client = vim.lsp.get_client_by_id(ctx.client_id)

  local msg = string.format("[%s] %s", client and client.name or "LSP", result.message)



  -- Only show warnings/errors if you want:

  if result.type == vim.lsp.protocol.MessageType.Error or result.type == vim.lsp.protocol.MessageType.Warning then

    vim.notify(msg, vim.log.levels.WARN, config)

  else

    -- ignore info/log messages

  end

end



-- Also prevent LSP from crashing the UI on bad bufnr

local old_request = vim.lsp.buf_request

vim.lsp.buf_request = function(bufnr, ...)

  if type(bufnr) ~= "number" then

    bufnr = vim.api.nvim_get_current_buf()

  end

  return old_request(bufnr, ...)

end





local Snacks = require("snacks")



-- Correct word under cursor using first spellcheck suggestion

local function correct_first_spell_suggestion()

  local word = vim.fn.expand("<cword>")

  local suggestions = vim.fn.spellsuggest(word)



  if suggestions ~= nil and #suggestions > 0 then

    local first = suggestions[1]

    vim.cmd("normal! ciw" .. first)

  else

    print("No spell suggestions available")

  end

end



vim.lsp.handlers["window/showMessage"] = function() end

vim.lsp.handlers["window/showMessageRequest"] = function() end



-- Prevent crashes from bad bufnr

local old_request = vim.lsp.buf_request

vim.lsp.buf_request = function(bufnr, ...)

  if type(bufnr) ~= "number" then

    bufnr = vim.api.nvim_get_current_buf()

  end

  return old_request(bufnr, ...)

end



-- In your `after/plugin/render-markdown.lua` or just in `init.lua`

vim.api.nvim_set_hl(0, "RenderMarkdownCode", { fg = "#ff8800" })

vim.api.nvim_set_hl(0, "RenderMarkdownLink", { fg = "#ff8800", underline = true })

vim.api.nvim_set_hl(0, "RenderMarkdownBullet", { fg = "#ff8800" })

vim.api.nvim_set_hl(0, "RenderMarkdownCheckbox", { fg = "#ff8800" })

vim.api.nvim_set_hl(0, "RenderMarkdownChecked", { fg = "#ff8800" })

vim.api.nvim_set_hl(0, "RenderMarkdownUnchecked", { fg = "#ff8800" })



wk.register({

  w = { ":w<CR>", "Save File" },

  o = { "<cmd>Outline<CR>", "Markdown outline"},

  r = { 

        name = "Run",

        p = { ":w | !python3 %<CR>", "Run Python File" },

        c = { ":lua run_cpp_file()<CR>", "Run C++ File" },

        n = { ":w | !node %<CR>", "Run Node.js File" },

        t = { run_specific_cpp_file, "Run ToDo in Fall 2024" },

        g = { ":lua RunGoFile()<CR>", "Run Go File" },

        j = { run_java, "Run Java File" },

        f = { "<cmd>lua require'cmp'.complete()<CR>", "Trigger Autocomplete" }, -- Autocomplete Trigger

    },

  q = { ":wq<CR>", "Save and Exit" },

  v = { ":ViewPDF<CR>", "View PDF" },

  m = {

    name = "Markdown",

    o = { ":MarkdownPreview<CR>", "Open Markdown Preview" },

    t = { "<cmd>MarkdownPreviewToggle<CR>", "Toggle Markdown Preview" },

    a = { add_markdown_table_row, "Add markdown table row" },

    c = { markdown_to_pdf, "Convert Markdown to PDF" },

    v = { view_pdf, "View PDF" },

    m = { create_markdown_table, "Create table" },

    x = {

    function()

      require("my_markdown").toggle_checkbox()

    end,

    "Toggle checkbox",

  },

    p = { function() require("my_markdown").set_pending() end, "Mark checkbox pending" },

    },

  n = { },

  d = { ":Dashboard<CR>", "Return to Dashboard" },

  D = {

    name = "Database",

    u = { "<cmd>DBUI<CR>", "Open DBUI" },

  },

  e = { "<cmd>Neotree toggle<CR>", "Toggle Neo-tree" },

  t = {

    name = "Terminal",

    t = { "<cmd>ToggleTerminal<CR>", "Open Terminal" },

    r = { "<cmd>lua open_right_terminal_with_mst()<CR>", "Open Split with Mistral" },

    c = { "<cmd>ToggleTermToggleAll<CR>", "Close All Terminals" },

    x = { "<cmd>lua close_current_terminal()<CR>", "Close Current Terminal" },

    d = { scan_with_deepseek, "Scan with Deepseek" }

  },

h = {

    name = "Harpoon",

    a = { function() require("harpoon"):list():add() end, "Add File" },

    r = { function() require("harpoon"):list():remove() end, "Remove File" },

    h = { function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, "Toggle Menu" },

    ["1"] = { function() require("harpoon"):list():select(1) end, "Go to File 1" },

    ["2"] = { function() require("harpoon"):list():select(2) end, "Go to File 2" },

    ["3"] = { function() require("harpoon"):list():select(3) end, "Go to File 3" },

    ["4"] = { function() require("harpoon"):list():select(4) end, "Go to File 4" },

  },

  T = {

    name = "Todo",

    a = { "<cmd>TodoTrouble<cr>", "Show Todos in Trouble" },

    f = { "<cmd>TodoTelescope<cr>", "Find Todos" },

    n = { "<cmd>TodoNext<cr>", "Next Todo" },

    p = { "<cmd>TodoPrev<cr>", "Previous Todo" },

    t = { "<cmd>TodoToggle<cr>", "Toggle Todo Highlighting" },

  },

  W = {

    name = "Word Count",

    c = { ":echo wordcount().words<CR>", "Show Word Count" },

  },

  x = {

    name = "Tools",

    f = { "<cmd>lua _PYTHON_FLOAT()<CR>", "Flashcards" },

    t = { "<cmd>lua _python_planner_toggle()<CR>", "Planner"},

    n = { "<cmd>lua _python_inkdex_toggle()<CR>", "Inkdex"},

    p = { "<cmd>lua _python_pomo_toggle()<CR>", "Pomodoro"},

    o = { function() _python_totp_toggle() end, "OTP Dashboard" },

    d = { open_db_viewer, "Open DB Viewer" },

  },

   s = {

    name = "Spell Check", -- Spell-check-related commands

    t = { ":set spell!<CR>", "Toggle Spell Check" },

    n = { "]s", "Next Spelling Error" },

    p = { "[s", "Previous Spelling Error" },

    s = { "z=", "Suggestions for Word" },

    a = { "zg", "Add Word to Dictionary" },

    r = { "zw", "Remove Word from Dictionary" },

    c = { correct_first_spell_suggestion, "Correct word (first suggestion)" },

  },

  f = {

    name = "Find (FZF)",

    f = { ":Files<CR>", "Find files" },

    g = { ":Rg<CR>", "Find text" },

    b = { ":Buffers<CR>", "Find buffers" },

    h = { ":History<CR>", "Find history" },

    c = { ":Commits<CR>", "Find commits" },

    l = { ":BLines<CR>", "Find in current buffer" },

    m = { ":Maps<CR>", "Find keymaps" },

    w = { ":Windows<CR>", "Find windows" },

    t = { ":Tags<CR>", "Find tags" },

    r = { ":OldFiles<CR>", "Find Recent Files" },

    ["/"] = { ":History/<CR>", "Find search history" },

    ["'"] = { ":Marks<CR>", "Find marks" }

  },

  l = {

    name = "Theme",

    d = {

      function()

        vim.o.background = "dark"

        vim.cmd("colorscheme purple")

      end,

      "Dark Theme",

    },

    l = {

      function()

        vim.o.background = "light"

        vim.cmd("colorscheme purplecalm_light")

      end,

      "Light Theme",

    },

  },

  u = {

    name = "TMUX",

    r = { ":silent !tmux source ~/.tmux.conf<CR>", "Reload tmux config" },

    s = { ":silent !tmux new-session -s mysession<CR>", "Start new session" },

    a = { ":silent !tmux attach-session -t mysession<CR>", "Attach to session" },

    k = { ":!tmux kill-session -t mysession<CR>", "Kill session" },

    v = { ":silent !tmux split-window -v<CR>", "Vertical Split" },

    h = { ":silent !tmux split-window -h<CR>", "Horizontal Split" },

    e = { function() save_tmux_session() end, "Save Tmux Session" },

    n = { ":!tmux new-window<CR>", "New window" },

    p = { "<cmd>bprevious<CR>", "Previous window" },

    x = { "<cmd>bnext<CR>", "Next window" },

    d = { ":!tmux detach<CR>", "Detach session" },

    l = { ":!tmux list-sessions<CR>", "List sessions" },

  },

b = {

    name = "Buffer",

    n = { "<cmd>enew<CR>", "New Buffer" },

    c = { "<cmd>bdelete<CR>", "Close Buffer" },

    h = { "<cmd>bprevious<CR>", "Previous Buffer" },

    l = { "<cmd>bnext<CR>", "Next Buffer" },

  },

    g = {

  name = "Git",

  d = { "<cmd>Fugit2<CR>", "Open Git Dashboard" },

  a = { ":lua require('fugit2').stage_file()<CR>", "Stage File" },

  u = { ":lua require('fugit2').unstage_file()<CR>", "Unstage File" },

  h = { ":lua require('fugit2').stage_hunk()<CR>", "Stage Hunk" },

  H = { ":lua require('fugit2').unstage_hunk()<CR>", "Unstage Hunk" },

  v = { ":lua require('fugit2').diff_file()<CR>", "View Diff File" },

  c = { ":lua require('fugit2').commit()<CR>", "Commit Staged" },

  p = { ":lua require('fugit2').pull()<CR>", "Pull from Remote" },

  P = { ":lua require('fugit2').push()<CR>", "Push to Remote" },

  b = { ":lua require('fugit2').blame_line()<CR>", "Blame Line" },

  q = { ":lua require('fugit2').close()<CR>", "Quit Dashboard" },

},

R = {

  name = "Ranger",

  r = { "<cmd>Ranger<CR>", "Ranger (replace buffer)" },

  f = { function() require("ranger-nvim").open(true) end, "Ranger (float)" },

  d = {

    function()

      require("ranger-nvim").open({

        path = vim.fn.getcwd(),

        select = "directory",

      })

    end,

    "Pick Directory",

  },

},





}, { prefix = "<leader>" })



-- =====================================================

-- FINAL override: clean markdown fenced code blocks

-- =====================================================

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
