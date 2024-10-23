---@class Parser
---@field get_import_ranges fun(bufnr: integer): table[]
---@field add_language fun(lang: string, config: table)
---@field lang_config table<string, table>
local parser = require("laundry.parser")

---@class Folding
---@field apply_folds fun(bufnr: integer, ranges: table[])
local folding = require("laundry.folding")

---@class LaundryConfig
---@field auto_fold? boolean # Determins if folding is automatic
---@field min_fold_lines? integer # Minimum amount of imports needed for folding
---@field enabled_filetypes? string[] # Which files will automatically fold
---@field languages? table<string, LanguageConfig> # Language-specific configurations

---@type LaundryConfig
local default_config = {
	auto_fold = true,
	min_fold_lines = 5,
	enabled_filetypes = {
		"typescript",
		"typescriptreact",
		"javascript",
		"javascriptreact",
		"go",
	},
}

---@class Laundry
---@field config LaundryConfig
---@field setup fun(opts?: table)
---@field on_attach fun(bufnr: integer)
---@field fold_imports fun()
---@field add_language fun(lang: string, config: table)
---@field lang_config table<string, table>
---@field get_file_patterns fun(): string[]
---@field get_lang_config fun(filetype: string): table
local M = {}

M.config = default_config

---@param opts? table
function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", default_config, opts or {})

	if opts and opts.languages then
		for lang, config in pairs(opts.languages) do
			M.add_language(lang, config)
		end
	end

	if M.config.auto_fold then
		vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, {
			pattern = M.get_file_patterns(),
			callback = function(args)
				vim.schedule(function()
					local filetype =
						vim.api.nvim_get_option_value("filetype", { buf = args.buf })
					if
						vim.tbl_isempty(M.config.enabled_filetypes)
						or vim.tbl_contains(M.config.enabled_filetypes, filetype)
					then
						if not vim.b[args.buf].laundry_folded then
							M.on_attach(args.buf)
							vim.b[args.buf].laundry_folded = true
						end
					end
				end)
			end,
		})
	end
end

---@param bufnr integer
function M.on_attach(bufnr)
	local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })

	vim.api.nvim_buf_set_option(bufnr, "foldmethod", "manual")
	vim.api.nvim_buf_set_option(bufnr, "foldenable", true)

	local ranges = parser.get_import_ranges(bufnr)

	if not ranges or #ranges == 0 then
		return
	end

	local lang_config = M.get_lang_config(filetype)

	local min_fold_lines = lang_config.min_fold_lines or M.config.min_fold_lines

	local total_import_lines = 0
	for _, range in ipairs(ranges) do
		local start_row, _, end_row, _ = unpack(range)
		total_import_lines = total_import_lines + (end_row - start_row + 1)
	end

	if total_import_lines >= min_fold_lines then
		folding.apply_folds(bufnr, ranges)
	end
end

function M.fold_imports()
	local bufnr = vim.api.nvim_get_current_buf()
	vim.b[bufnr].laundry_folded = false
	M.on_attach(bufnr)
end

M.add_language = parser.add_language
M.lang_config = parser.lang_config

---@return string[]
function M.get_file_patterns()
	local patterns = {}
	for _, config in pairs(M.lang_config) do
		vim.list_extend(patterns, config.file_patterns)
	end
	return patterns
end

---@param filetype string
---@return table
function M.get_lang_config(filetype)
	for lang, config in pairs(M.lang_config) do
		if
			lang == filetype or vim.tbl_contains(config.aliases or {}, filetype)
		then
			return config
		end
	end
	return {}
end

return M
