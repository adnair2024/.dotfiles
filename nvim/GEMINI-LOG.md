# Neovim Configuration Log

**Date:** Monday, January 5, 2026
**System:** Darwin (macOS)

## Overview
This configuration is a modularized Neovim setup centered around `lazy.nvim` for plugin management and `snacks.nvim` for a modern UI/UX (dashboard, terminal, explorer, picker). It is designed for C++, Python, Go, Java, and Markdown development.

## Modular Structure
The configuration is split into logical modules loaded by `init.lua`:

*   **`init.lua`**: Entry point. Sets up `lazy.nvim` and loads the modules below.
*   **`lua/options.lua`**: Global settings (line numbers, tabs, theme `carbonfox`).
*   **`lua/utils.lua`**: Global helper functions (`_G.run_cpp_file`, `_G.markdown_to_pdf`), LSP patches, and custom tools.
*   **`lua/autocmds.lua`**: Automations (file headers, lint-on-save, highlight overrides).
*   **`lua/keymaps.lua`**: Centralized keybindings using standard `vim.keymap.set` and `which-key` groups.
*   **`lua/plugins/init.lua`**: Plugin specifications for `lazy.nvim`.

## Key Features & Plugins

### Core & UI
*   **Plugin Manager**: `lazy.nvim`.
*   **Dashboard/Tools**: `snacks.nvim` provides the Dashboard, File Explorer, Terminal, Picker (Fuzzy Finder), and Notifier.
*   **UI Enhancements**:
    *   `noice.nvim`: Modern UI for messages, cmdline, and popup menus.
    *   `lualine.nvim`: Statusline with custom word count component.
    *   `bufferline.nvim`: Tab/Buffer bar.
    *   `which-key.nvim`: Keybinding popup guide.
    *   `auto-dark-mode.nvim`: Syncs theme with system.
    *   `nightfox.nvim`: Theme (Carbonfox).

### Coding & LSP
*   **Completion**: `nvim-cmp` (with `LuaSnip`).
*   **LSP**: `nvim-lspconfig` configured for `pyright`, `ts_ls`, `clangd`, `gopls`.
*   **Linting/Formatting**: `null-ls` (Prettier, ESLint), `nvim-lint`.
*   **Comments**: `Comment.nvim`, `todo-comments.nvim`.

### Markdown
*   `render-markdown.nvim`: Rich rendering of Markdown (tables, checkboxes) in the buffer.
*   `markdown-preview.nvim`: Browser preview.
*   `md-helper.nvim`: Helper for tables, TOCs, links.
*   **PDF Export**: Custom `markdown_to_pdf` function using Pandoc.

## Keybindings (Leader: Space)

### General
*   `<leader>w`: Save File
*   `<leader>q`: Save and Exit
*   `<leader>d`: Dashboard (Snacks)
*   `<leader>e` / `<leader>Rr`: Toggle Explorer
*   `<leader>xr`: Reload Config

### Code Execution
*   `<leader>rp`: Run Python
*   `<leader>rc`: Run C++
*   `<leader>rg`: Run Go
*   `<leader>rj`: Run Java
*   `<leader>rn`: Run Node.js

### Find & Navigation (Snacks Picker)
*   `<leader>ff`: Find Files
*   `<leader>fg`: Grep Text
*   `<leader>fb`: Find Buffers
*   `<leader>fr`: Recent Files
*   `<leader>fk` / `<leader>fm`: Keymaps

### Terminal
*   `<leader>tt` / `<leader>tc`: Toggle Terminal
*   `<leader>tr`: Open Split with Mistral (LLM)
*   `<leader>tx`: Close Current Terminal

### Markdown
*   `<leader>mo` / `<leader>mt`: Preview / Toggle Preview
*   `<leader>mc`: Convert to PDF
*   `<leader>ma` / `<leader>mm`: Add Table Row / Create Table

### Tools
*   `<leader>xf`: Flashcards
*   `<leader>xt`: Planner
*   `<leader>xn`: Inkdex
*   `<leader>td`: Scan with Deepseek

## Custom Functions (`lua/utils.lua`)
*   **`run_cpp_file`**: Compiles C++ with `g++` and runs in a floating terminal.
*   **`run_java`**: Compiles and runs Java.
*   **`markdown_to_pdf`**: Converts current file to PDF using `pandoc` with `xelatex`.
*   **`scan_with_deepseek`**: Pipes current file to Ollama (`deepseek-v3`).
