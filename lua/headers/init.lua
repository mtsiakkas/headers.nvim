local ft = require('headers.ft')

local M = {}

M.opts = {
  center = false,
  fixed_width = 0,
  trim = true
}

function M.setup(opts)
  opts = opts or { keymaps = true }

  M.opts.fixed_width = opts.fixed_width or 0
  M.opts.center = opts.center
  M.opts.trim = opts.trim

  if opts.keymaps then
    vim.keymap.set("n", "<leader>gH", function() M.new_header() end,
      { desc = "Show new header window" })
    vim.keymap.set("n", "<leader>gh", function() M.create_header() end,
      { desc = "Create comment header from current line" })
    vim.keymap.set("v", "<leader>gh", function() M.create_header() end,
      { desc = "Create comment header from block selection" })
  end
end

------------------------------------------------------------
--                                                        --
-- Trim whitespace from string                            --
--                                                        --
------------------------------------------------------------
--- @param s string
--- @return string
local function trim_whitespace(s)
  return string.match(s, "^%s*(.*)%s*")
end

------------------------------------------------------------
--                                                        --
-- Load comment delimiters based on detected syntax       --
--                                                        --
------------------------------------------------------------
--- @return table
local function load_str()
  local pos = vim.api.nvim_win_get_cursor(0)

  local filetype = vim.bo.filetype
  if ft.filetypes[filetype] == nil then
    return {}
  end

  local line = pos[1]
  local col = 0
  local e = ""
  while line > 0 and e == "" do
    local cline = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
    if cline ~= "" then
      for i = 1, #cline do
        if string.sub(cline, i, i) ~= " " then
          col = i
        end
      end
      e = vim.fn.synIDattr(vim.fn.synID(line, col, 1), 'name')
    end
    line = line - 1
  end

  local fopts = {}
  for f, s in pairs(ft.filetypes) do
    if string.lower(string.sub(e, 1, #f)) == f then
      fopts = s
      break
    end
  end

  return fopts
end

------------------------------------------------------------
--                                                        --
-- Create commented line from input                       --
--                                                        --
------------------------------------------------------------
--- @param s string
--- @param l integer
--- @param str table
--- @return string
local function comment(s, l, str)
  local pad = 1
  if M.opts.center then
    pad = (l - #s + ((l - #s) % 2)) / 2
  end
  return str.start_str ..
      string.rep(" ", pad) ..
      s ..
      string.rep(" ", l - pad - #s + 1)
      .. str.end_str
end

------------------------------------------------------------
--                                                        --
-- Create header lines from input string table            --
--                                                        --
------------------------------------------------------------
--- @param lines string[]
--- @return string[]
local function create_lines(lines)
  local str = load_str()
  if str == {} then return {} end
  local new_lines = {}
  local max_line_length = 0
  for _, s in ipairs(lines) do
    if #trim_whitespace(s) > max_line_length then
      max_line_length = #trim_whitespace(s)
    end
  end

  if M.opts.fixed_width > 0 then
    if not M.opts.trim then
      max_line_length = math.max(max_line_length, M.opts.fixed_width)
    else
      max_line_length = M.opts.fixed_width
    end
  end

  max_line_length = max_line_length - 1 - #str.start_str - #str.end_str

  table.insert(new_lines,
    str.start_str .. string.rep(str.mid_str, max_line_length + 1) .. str.end_str
  )
  table.insert(new_lines, comment("", max_line_length, str))
  for i, s in ipairs(lines) do
    if s == "" and i == #lines then
      goto continue
    end
    local ss = trim_whitespace(s)
    if M.opts.trim and #ss > max_line_length then
      ss = string.sub(ss, 1, max_line_length - 4) .. "..."
    end
    table.insert(new_lines, comment(ss, max_line_length, str))
    ::continue::
  end
  table.insert(new_lines, comment("", max_line_length, str))
  table.insert(new_lines,
    str.start_str .. string.rep(str.mid_str, max_line_length + 1) .. str.end_str
  )

  return new_lines
end

------------------------------------------------------------
--                                                        --
-- Create new header from buffer text                     --
--                                                        --
------------------------------------------------------------
function M.create_header()
  if next(load_str()) == nil then
    return
  end
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

------------------------------------------------------------
--                                                        --
-- Create new header from user input                      --
--                                                        --
------------------------------------------------------------
function M.new_header()
  if next(load_str()) == nil then
    return
  end
  local input = vim.fn.input("Header: ")
  if trim_whitespace(input) == "" then
    return
  end
  local output = create_lines({ input })
  local pos = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, pos - 1, pos - 1, false, output)
end

return M
