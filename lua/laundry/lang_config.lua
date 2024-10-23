---@class LanguageConfig
---@field file_patterns? string[] # File extensions that match this language
---@field import_node_types? string[] # TreeSitter node types representing import statements
---@field aliases? string[] # Alternative names or file types for this language
---@field min_fold_lines? integer # Minimum number of import lines before folding (optional), if not set defaults to 20 lines of code.

--[[
Note on import_node_types:
These correspond to TreeSitter node types for import statements in each language.
To find the correct node types for a language:
1. Refer to the language's TreeSitter grammar file, usually found in the
   `nvim-treesitter/nvim-treesitter` repository under `parser/{language}/grammar.js`
2. Look for rules defining import statements
3. Use the Neovim `:InspectTree` command to view the parse tree of a file and
   identify the correct node types for imports

Some common node types for imports:
- TypeScript/JavaScript: "import_statement", "import_clause"
- Go: "import_spec", "import_declaration"
- Python: "import_from_statement", "import_statement"
- Rust: "use_declaration"

For more details, consult the TreeSitter documentation for each language.
]]

---@type table<string, LanguageConfig>
return {
	typescript = {
		file_patterns = { "*.ts", "*.tsx" },
		import_node_types = { "import_statement", "import_clause" },
		aliases = { "typescriptreact" },
		min_fold_lines = 5,
	},
	javascript = {
		file_patterns = { "*.js", "*.jsx" },
		import_node_types = { "import_statement", "import_clause" },
		aliases = { "javascriptreact" },
		min_fold_lines = 5,
	},
	go = {
		file_patterns = { "*.go" },
		import_node_types = { "import_spec", "import_declaration" },
		aliases = {},
		min_fold_lines = 5,
	},
}
