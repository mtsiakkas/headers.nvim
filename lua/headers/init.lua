local M = {}

function M.setup(opts)
  opts = opts or { keymaps = true }

  if opts.keymaps then
    vim.keymap.set("n", "<leader>gh", function() M.create_header() end,
      { desc = "Create comment header from current line" })
    vim.keymap.set("v", "<leader>gh", function() M.create_header() end,
      { desc = "Create comment header from block selection" })
  end

  vim.api.nvim_create_user_command("CreateHeader", function() M.create_header() end,
    { desc = "Create comment header" })
end

local comment_strings = { start_str = "--", end_str = "--", mid_str = "-" }
local function setup_comment_strings()
  local ft = vim.bo.filetype
  if ft == "lua" then
    comment_strings = {
      start_str = "--",
      end_str = "--",
      mid_str = "-"
    }
  elseif ft == "javascript" or ft == "typescript" or ft == "go" then
    comment_strings = {
      start_str = "/*",
      end_str = "*/",
      mid_str = "*"
    }
  elseif ft == "sh" then
    comment_strings = {
      start_str = "#",
      end_str = "#",
      mid_str = "#"
    }
  end
end

--- @param s string
--- @return string
local function trim_whitespace(s)
  return string.match(s, "^%s*(.*)%s*")
end

--- @param n integer
--- @return string
local function make_v_boundary(n)
  return comment_strings.start_str .. string.rep(comment_strings.mid_str, n + 1) .. comment_strings.end_str
end


--- @param s string
--- @param l integer
--- @return string
local function comment(s, l)
  return comment_strings.start_str .. " " ..
      s .. string.rep(" ", (l - string.len(s)) - 1)
      .. " " .. comment_strings.end_str
end


--- @param lines string[]
--- @return string[]
local function create_lines(lines)
  local new_lines = {}
  local max_line_length = 0
  for _, s in ipairs(lines) do
    if string.len(trim_whitespace(s)) > max_line_length then
      max_line_length = string.len(trim_whitespace(s))
    end
  end

  max_line_length = max_line_length + 1

  table.insert(new_lines, make_v_boundary(max_line_length))
  table.insert(new_lines, comment("", max_line_length))
  for i, s in ipairs(lines) do
    if s == "" and i == #lines then
      goto continue
    end
    table.insert(new_lines, comment(trim_whitespace(s), max_line_length))
    ::continue::
  end
  table.insert(new_lines, comment("", max_line_length))
  table.insert(new_lines, make_v_boundary(max_line_length))

  return new_lines
end

function M.create_header()
  setup_comment_strings()

  local start_line = 0
  local end_line = 0
  local lines = {}
  if vim.fn.mode() == "v" or vim.fn.mode() == "V" then
    vim.cmd("normal! <cr>")
    start_line = vim.api.nvim_buf_get_mark(0, "<")[1]
    end_line = vim.api.nvim_buf_get_mark(0, ">")[1]
    lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  elseif vim.fn.mode() == "n" then
    local pos = vim.api.nvim_win_get_cursor(0)[1]
    start_line = pos
    end_line = pos
    local line = vim.api.nvim_buf_get_lines(0, pos - 1, pos, false)[1]
    if trim_whitespace(line) == "" then
      return
    end
    lines = { line }
  end

  local new_lines = create_lines(lines)
  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, new_lines)
end

return M
