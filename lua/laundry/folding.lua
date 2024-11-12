---@class Folding
local M = {}

---@param bufnr integer
---@param start_line integer
---@param end_line integer
local function create_fold(bufnr, start_line, end_line)
	vim.api.nvim_command(
		string.format("%d,%dfold", start_line + 1, end_line + 1)
	)
end

---@param bufnr integer
---@param ranges table[] # Each range is a table of 4 integers: {start_row, start_col, end_row, end_col}
function M.apply_folds(bufnr, ranges)
	if not ranges or vim.tbl_isempty(ranges) then
		return
	end

	-- NOTE: using `nvim_set_option_value()` does not yield the same behavior
	-- will need to investigate why
	vim.api.nvim_buf_set_option(bufnr, "foldmethod", "manual")
	vim.api.nvim_command("normal! zE")

	---@type integer|nil
	local current_fold_start = nil

	for i, range in ipairs(ranges) do
		local start_row, _, end_row, _ = unpack(range)

		if not current_fold_start then
			current_fold_start = start_row
		elseif start_row > end_row + 1 then
			create_fold(bufnr, current_fold_start, end_row)
			current_fold_start = start_row
		end

		if i == #ranges then
			create_fold(bufnr, current_fold_start, end_row)
		end
	end
end

return M
