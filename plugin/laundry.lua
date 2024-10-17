-- plugin/laundry.lua
local laundry = require("laundry")

vim.api.nvim_create_user_command("LaundryFold", function()
	laundry.on_attach(0) -- 0 represents the current buffer
end, {})
