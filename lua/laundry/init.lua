-- lua/laundry/init.lua
local uv = vim.uv
local parser = require("laundry.parser")
local folding = require("laundry.folding")

local M = {}

-- Default configuration
local default_config = {
	auto_fold = true,
	fold_delay = 100,
	max_fold_lines = 100,
	enabled_filetypes = {
		"typescript",
		"typescriptreact",
		"javascript",
		"javascriptreact",
	},
}

M.config = default_config

M.setup = function(opts)
	M.config = vim.tbl_deep_extend("force", default_config, opts or {})

	require("laundry.utils").update_debounce_delay(M.config.fold_delay)

	if opts and opts.languages then
		for lang, config in pairs(opts.languages) do
			M.add_language(lang, config)
		end
	end

	if M.config.auto_fold then
		local patterns = {}
		for lang, config in pairs(M.lang_config) do
			if
				vim.tbl_isempty(M.config.enabled_filetypes)
				or vim.tbl_contains(M.config.enabled_filetypes, lang)
			then
				vim.list_extend(patterns, config.file_patterns)
			end
		end

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
			pattern = patterns,
			callback = function(args)
				local filetype =
					vim.api.nvim_get_option_value("filetype", { buf = args.buf })
				if
					vim.tbl_isempty(M.config.enabled_filetypes)
					or vim.tbl_contains(M.config.enabled_filetypes, filetype)
				then
					M.on_attach(args.buf)
				end
			end,
		})
	end
end

M.on_attach = function(bufnr)
	local thread = uv.new_thread(function(data)
		local ranges = require("laundry.parser").get_import_ranges(data.bufnr)
		uv.async_send(data.async, ranges)
	end)

	if not thread then
		vim.api.nvim_err_writeln(
			"Failed to create thread. Falling back to synchronous execution."
		)
		local ranges = parser.get_import_ranges(bufnr)
		folding.apply_folds(bufnr, ranges, M.config.max_fold_lines)
		return
	end

	local async = uv.new_async(function(ranges)
		vim.schedule(function()
			folding.apply_folds(bufnr, ranges, M.config.max_fold_lines)
		end)
		async:close()
	end)

	if not async then
		vim.api.nvim_err_writeln(
			"Failed to create async handle. Falling back to synchronous execution."
		)
		local ranges = parser.get_import_ranges(bufnr)
		folding.apply_folds(bufnr, ranges, M.config.max_fold_lines)
		return
	end

	local ok, err = pcall(function()
		thread:start({ bufnr = bufnr, async = async })
	end)

	if not ok then
		vim.api.nvim_err_writeln(
			"Failed to start thread: "
				.. tostring(err)
				.. ". Falling back to synchronous execution."
		)
		local ranges = parser.get_import_ranges(bufnr)
		folding.apply_folds(bufnr, ranges, M.config.max_fold_lines)
	end
end

M.add_language = parser.add_language
M.lang_config = parser.lang_config

return M
