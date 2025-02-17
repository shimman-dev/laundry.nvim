---@type Laundry
local laundry = require("laundry")

-- Manually trigger import folding, respects `min_fold_lines`
vim.api.nvim_create_user_command("LaundryFold", function()
	laundry.fold_imports()
end, {
	desc = "Fold import statements in the current buffer, respecting min_fold_lines",
})

-- Manually trigger import folding, ignores `min_fold_lines`
vim.api.nvim_create_user_command("LaundryForceFold", function()
	laundry.fold_all_imports()
end, {
	desc = "Fold import statements in the current buffer, ignoring min_fold_lines",
})
