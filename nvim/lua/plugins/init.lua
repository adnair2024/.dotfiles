-- ===========================================
-- 📦 lua/plugins/init.lua (Lazy.nvim Specs)
-- ===========================================

-- Retrieve global functions defined in utils.lua
local word_count = _G.word_count

require("lazy").setup({
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "neovim/nvim-lspconfig",
      "jose-elias-alvarez/null-ls.nvim",
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
        experimental = {
          ghost_text = true,
        },
      })

      -- Setup for cmdline completion
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        })
      })

      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.diagnostics.eslint_d,
        },
      })
    end,
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()
    end,
  },
  { -- presence.nvim
    "andweeb/presence.nvim",
    config = function()
      require("presence").setup({
        -- auto_update = true, -- Removed to prevent duplicate option error
        neovim_image_text = "The One True Text Editor",
        main_image = "file",
        large_image_text = "neovim",
        edit_mode = "false",
        enable_line_number = true,
        client_id = "1330968227001532560",
        log_level = "info",
        editing_text = "Editing %s",
        file_explorer_text = "Browsing %s",
        reading_text = "Reading %s",
        plugin_manager_text = "Managing Plugins",
        line_number_text = "Line %s out of %s"
      })
    end
  },
  {
    "ellisonleao/glow.nvim",
    cmd = "Glow",
    config = function()
      require("glow").setup({
        style = "dark",
        width = 120,
      })
    end,
  },
  {
    "adnair2024/mm",
    ft = { "markdown" },
    config = function()
      require("mm").setup()
    end
  },
  { -- md-helper.nvim
    "adnair2024/md-helper.nvim",
    dependencies = {
      "MeanderingProgrammer/render-markdown.nvim",
    },
    ft = { "markdown" },
    config = function()
      require("md-helper").setup()
    end
  },
  { -- vim-tmux-navigator
    "christoomey/vim-tmux-navigator",
    lazy = false
  },
  { -- outline.nvim
    "hedyhli/outline.nvim",
    config = function()
      require("outline").setup {
        symbols = {
          markdown = {
            icon = "󰽂",
          },
        },
      }
    end
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require('lualine').setup({
        options = { theme = 'auto' },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch' },
          lualine_c = { 'filename', word_count }, -- Uses global word_count
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' }
        }
      })
    end
  },
  {
    "alex-laycalvert/flashcards.nvim",
    config = function()
      require("flashcards").setup({
        deck_dir = "~/notes/flashcards",
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
          -- icons = {
          --   unchecked = "󰄱 ",
          --   checked = "󰱒 ",
          --   pending = "󱍢 ",
          -- },
        },
        code = { enabled = true, style = "full" },
        quote = { enabled = true, icon = "󰉺" },
      })
    end,
  },
  { -- auto-dark-mode
    "f-person/auto-dark-mode.nvim",
    config = function()
      require("auto-dark-mode").setup({
        update_interval = 1000,
        set_dark_mode = function()
          vim.o.background = "dark"
          vim.cmd("colorscheme carbonfox")
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
        ensure_installed = { "lua", "markdown", "markdown_inline", "regex" },
        auto_install = true,
        highlight = { enable = true },
      })
    end,
  },
  { 
    "EdenEast/nightfox.nvim",
    config = function()
      vim.cmd("colorscheme carbonfox") -- Current Colorscheme
    end,
  },
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
          group = '+'
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
  },
  { -- Comment.nvim
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup({
        toggler = {
          line = 'gcc',
          block = 'gbc',
        },
        opleader = {
          line = 'gc',
          block = 'gb',
        },
        mappings = {
          basic = true,
          extra = true
        },
        pre_hook = nil,
        post_hook = nil,
      })
    end
  },
  {
    'iamcco/markdown-preview.nvim',
    build = 'cd app && npm install',
    ft = 'markdown',
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
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
      -- Keymaps moved to keymaps.lua
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
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local servers = { "pyright", "ts_ls", "clangd", "gopls" } 
      for _, server in ipairs(servers) do
        lspconfig[server].setup({
          capabilities = capabilities,
        })
      end
      
      vim.diagnostic.config({
        virtual_text = true,  
        signs = true,         
        update_in_insert = false,  
      })
    end,
  },
  {
    "SuperBo/fugit2.nvim",
    opts = {
      libgit2_path = "/usr/local/lib/libgit2.dylib",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("fugit2").setup()
    end,
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = {
        enabled = true,
        sections = {
          { section = "terminal", cmd = "cal", indent = 15, padding = 3 },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
          { section = "recent_files", name = "Recent Files", limit = 5, padding = 1 },
        },
      },
      explorer = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      lazygit = { enabled = true },
      notifier = { enabled = true },
      picker = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scratch = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      terminal = { enabled = true },
      words = { enabled = true },
      zen = { enabled = true },
    },
  },
  {
    "mfussenegger/nvim-lint",
    config = function()
      require('lint').linters_by_ft = {
        cpp = { 'cppcheck' },        
        python = { 'flake8' },       
        go = { 'golangcilint' },     
        java = { 'checkstyle' },     
      }
      -- Auto-lint is handled in autocmds.lua
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
          {
            filter = { event = "notify" },
            view = "mini",
          },
          {
            filter = { event = "msg_show" },
            view = "mini",
          },
        },
        views = {
          mini = {
            position = { row = -1, col = -1 },
            border = { style = "rounded" },
            win_options = { winblend = 20 },
          },
          messages = {
            view = "mini",
            position = { row = -1, col = -1 },
          },
        },
      })
    end,
  },
  { -- todo-comments.nvim
    "folke/todo-comments.nvim",
    config = function()
      require("todo-comments").setup()
    end,
  }
})
