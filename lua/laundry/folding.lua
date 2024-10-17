-- lua/laundry/folding.lua
local M = {}

M.apply_folds = function(bufnr, ranges, max_fold_lines)
	if vim.tbl_isempty(ranges) then
		return
	end

	vim.api.nvim_set_option_value(
		"foldmethod",
		"manual",
		{ scope = "local", buf = bufnr }
	)
	vim.api.nvim_buf_clear_namespace(bufnr, -1, 0, -1)

	local folded_lines = 0
	for _, range in ipairs(ranges) do
		local start_row, _, end_row, _ = unpack(range)
		local fold_size = end_row - start_row + 1

		if folded_lines + fold_size > max_fold_lines then
			break
		end

		vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, {})
		vim.api.nvim_buf_add_highlight(bufnr, -1, "Folded", start_row, 0, -1)
		folded_lines = folded_lines + fold_size
	end
end

return M
