local header = require('headers')

vim.api.nvim_create_user_command(
  "CreateHeader",
  function()
    header.create_header()
  end,
  { desc = "Create header from selection or current line" }
)

vim.api.nvim_create_user_command(
  "NewHeader",
  function()
    header.new_header()
  end,
  { desc = "Create header from user input" }
)
