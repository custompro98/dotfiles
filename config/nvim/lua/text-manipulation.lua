local function wrap_in_quotes(content)
  return "'" .. content .. "'"
end

local function append_comma(content)
  return content .. ","
end

local function replace_text(bufnr, linenr, content)
  vim.api.nvim_buf_set_lines(bufnr, linenr - 1, linenr, true, {content})
end

local function listify_line(bufnr, linenr)
  local original = vim.api.nvim_buf_get_lines(bufnr, linenr - 1, linenr, true)[1]
  local modified = append_comma(wrap_in_quotes(original))

  replace_text(bufnr, linenr, modified)
end

local function collapse(bufnr)
  vim.cmd('1,$join')
end

function Listify(shouldCollapse, bufnr)
  local bufnr = bufnr or 0
  local lineCount = vim.api.nvim_buf_line_count(bufnr)

  for i=1,lineCount do
    listify_line(bufnr, i)
  end

  if shouldCollapse then
    collapse(bufnr)
  end
end

vim.cmd('command! Listify :lua Listify(true)')
