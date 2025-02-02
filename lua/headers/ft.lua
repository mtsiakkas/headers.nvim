local M = {}

local c_like = {
  start_str = "/*",
  end_str = "*/",
  mid_str = "-",
}

local bash_like = {
  start_str = "#",
  end_str = "#",
  mid_str = "#",
}

M.filetypes = {
  lua = {
    start_str = "--",
    end_str = "--",
    mid_str = "-",
  },
  html = {
    start_str = "<!--",
    end_str = "-->",
    mid_str = "-",
  },
  sh = bash_like,
  python = bash_like,
  sql = c_like,
  go = c_like,
  typescript = c_like,
  javascript = c_like,
  vue = c_like,
}

return M
