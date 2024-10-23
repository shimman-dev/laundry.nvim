---@type Laundry
local laundry = require("laundry")

-- Create a user command to manually trigger import folding
vim.api.nvim_create_user_command("LaundryFold", function()
	laundry.fold_imports()
end, {
	desc = "Fold import statements in the current buffer",
})
