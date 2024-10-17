-- lua/laundry/lang_config.lua
return {
	typescript = {
		file_patterns = { "*.ts", "*.tsx" },
		import_node_types = { "import_statement", "import_clause" },
	},
	javascript = {
		file_patterns = { "*.js", "*.jsx" },
		import_node_types = { "import_statement", "import_clause" },
	},
	go = {
		file_patterns = { "*.go" },
		import_node_types = { "import_spec", "import_declaration" },
	},
}
