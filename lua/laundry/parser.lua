---@class TSNode
---@field type fun(): string
---@field range fun(): integer, integer, integer, integer

---@class TSTree
---@field root fun(): TSNode

---@class TSParser
---@field parse fun(): TSTree[]
---@field register_cbs fun(callbacks: table)

local treesitter = vim.treesitter

---@class Parser
local M = {}

-- Memoization cache with weak keys to allow garbage collection of unused buffers
---@type table<integer, table>
local cache = setmetatable({}, { __mode = "k" })

---@type table<string, LanguageConfig>
M.lang_config = require("laundry.lang_config")

---@param filetype string
---@return LanguageConfig|nil
local function get_lang_config(filetype)
	for lang, config in pairs(M.lang_config) do
		if
			lang == filetype or vim.tbl_contains(config.aliases or {}, filetype)
		then
			return config
		end
	end

	-- If no direct match, try to derive the filetype
	local derived_filetype = vim.filetype.match({ filename = vim.fn.bufname() })
	for lang, config in pairs(M.lang_config) do
		if
			lang == derived_filetype
			or vim.tbl_contains(config.aliases or {}, derived_filetype)
		then
			return config
		end
	end

	return nil
end

---@param filetype string
---@return string
local function get_parser_lang(filetype)
	for lang, config in pairs(M.lang_config) do
		if
			lang == filetype or vim.tbl_contains(config.aliases or {}, filetype)
		then
			return lang
		end
	end
	return filetype
end

---@param node TSNode
---@param lang_config LanguageConfig
---@return boolean
local function is_import_node(node, lang_config)
	local node_type = node:type()
	for _, import_type in ipairs(lang_config.import_node_types) do
		if node_type == import_type then
			return true
		end
	end
	return false
end

M.get_import_ranges = function(bufnr)
	if cache[bufnr] then
		return cache[bufnr]
	end

	local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
	local lang_config = get_lang_config(filetype)

	if not lang_config then
		return {}
	end

	local parser_lang = get_parser_lang(filetype)
	local parser = treesitter.get_parser(bufnr, parser_lang)

	if not parser then
		return {}
	end

	local tree = parser:parse()[1]
	local root = tree:root()

	local ranges = {}
	local index = 0

	-- Changed this part to be more explicit about finding import nodes
	for node in root:iter_children() do
		-- Only get ranges for actual import nodes
		if is_import_node(node, lang_config) then
			index = index + 1
			ranges[index] = { node:range() }
		end
	end

	cache[bufnr] = ranges

	parser:register_cbs({
		on_changedtree = function(changes)
			cache[bufnr] = nil
		end,
	})

	return ranges
end

---@param lang string
---@param config LanguageConfig
function M.add_language(lang, config)
	M.lang_config[lang] = config
end

return M
