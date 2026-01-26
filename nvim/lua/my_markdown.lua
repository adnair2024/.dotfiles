local M = {}

function M.toggle_checkbox()
  local line = vim.api.nvim_get_current_line()

  if line:match("%[%s%]") then
    -- 1. [ ] -> [-] (Todo to In Progress)
    line = line:gsub("%[%s%]", "[-]", 1)

  elseif line:match("%[%-%]") then
    -- 2. [-] -> [x] (In Progress to Done)
    line = line:gsub("%[%-%]", "[x]", 1)

  elseif line:match("%[x%]") then
    -- 3. [x] -> [ ] (Done back to Todo/Reset)
    line = line:gsub("%[x%]", "[ ]", 1)

  else
    -- Fallback: If no checkbox exists, create one at the start of the list item
    -- This is helpful for lines that are just bullet points
    line = line:gsub("^%s*[%*%-%+]%s*", "%0[ ] ", 1)
  end

  vim.api.nvim_set_current_line(line)
end

function M.set_pending()
  local line = vim.api.nvim_get_current_line()
  line = line:gsub("%[[^%]]%]", "[-]", 1)
  vim.api.nvim_set_current_line(line)
end

return M
