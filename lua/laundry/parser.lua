-- lua/laundry/parser.lua
local ts = vim.treesitter
local M = {}

-- memoization cache
local cache = setmetatable({}, { __mode = "k" })

local ffi = require("ffi")
ffi.cdef([[
	typedef struct {} TSNode;
	const char *ts_node_type(const TSNode *);
]])
local ts_node_type = ffi.C.ts_node_type

-- import language configs
M.lang_config = require("laundry.lang_config")

local function get_lang_config(filetype)
	return M.lang_config[filetype]
		or M.lang_config[vim.filetype.match({ filename = vim.fn.bufname() })]
end

local function is_import_node(node, lang_config)
	local node_type = ts_node_type(node)
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
		print("laundry.nvim: Unsupported file type")
		return {}
	end

	local parser = ts.get_parser(bufnr, filetype)
	local tree = parser:parse()[1]
	local root = tree:root()

	local ranges = {}
	local index = 0
	for node in root:iter_children() do
		if is_import_node(node, lang_config) then
			index = index + 1
			ranges[index] = { node:range() }
		end
	end

	cache[bufnr] = ranges

	-- incremental parsing
	parser:register_cbs({
		on_changedtree = function(changes)
			-- clear cache on changes, forcing re-parse next time
			cache[bufnr] = nil
		end,
	})

	return ranges
end

return M
