# laundry.nvim 🧺

When you need to fold a lengthy stack of imports in your preferred language. 👔

## Requirements

- [Neovim >= 0.9.0](https://neovim.io/)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

## Features

- Automatically folds import statements in your code
- Language-specific fold configurations
- Currently supports TypeScript, JavaScript, and Go (wow three whole languages? Visit the
[CONTRIBUTING.md](./CONTRIBUTING.md) to learn how to add additional languages)
- Configurable minimum fold thresholds

## 📦 Installation

<details>
<summary>lazy.nvim</summary>

```lua
{
    "shimman-dev/laundry.nvim",
	priority = 1000,
    requires = { 'nvim-treesitter/nvim-treesitter' },
	event = { "BufReadPost", "BufNewFile" },
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
	---@module 'laundry'
	---@type LaundryConfig
    opts = {
        auto_fold = true, -- default value is false, need to opt-in for plugin
    }
}
```
</details>

<details>
<summary>packer.nvim</summary>

```lua
use {
    'shimman-dev/laundry.nvim',
    requires = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
        require('laundry').setup({
            auto_fold = true, -- default value is false, need to opt-in for plugin
        })
    end
}
```
</details>

## Commands

- `:LaundryFold` - Manually fold import statements in the current buffer,
respects `min_fold_lines`
- `:LaundryFoldAll` - Manually fold import statements in the current buffer,
ignores `min_fold_lines`

## Notes

- If `min_fold_lines` is not set in either the global config or language-specific config, no folding will occur
- Language-specific settings take precedence over global settings unless overridden by user configuration

## Configuration

Default Options (lazy.nvim):

```lua
{
    "shimman-dev/laundry.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    opts = {
		-- NOTE: not initially set to true, most opt-in the plugin
        -- Whether to automatically fold imports when opening files
        auto_fold = false,

        -- Global minimum number of import lines before folding
        -- If not set, will use language-specific settings
        -- min_fold_lines = 25,

        -- Filetypes that will be folded (if `auto_fold` is true)
        enabled_filetypes = {
            "typescript",
            "typescriptreact",
            "javascript",
            "javascriptreact",
            "go",
        },

        -- Language-specific configurations
        languages = {
            -- Override settings for TypeScript
            typescript = {
                min_fold_lines = 10,  -- Only fold if 10+ lines of imports
            },
        },
    }
}
```

### Adding Support for Additional Languages

Example showing how to add Python support:

```lua
require('laundry').setup({
    auto_fold = true,
    enabled_filetypes = { "python" },  -- Enable for Python
    languages = {
        python = {
            -- Patterns determine which files this config applies to
            file_patterns = { "*.py" },

            -- These are the TreeSitter node types that represent imports
            -- For Python they are:
            -- - import_statement: for "import foo"
            -- - import_from_statement: for "from foo import bar"
            import_node_types = { 
                "import_statement",
                "import_from_statement"
            },

            -- Most languages don't need aliases, but some like
            -- TypeScript/JavaScript might have multiple file extensions
            aliases = {},

            -- Only fold when there are at least 4 import lines
            min_fold_lines = 10,
        }
    }
})
```

To find the correct `TreeSitter` node types for other languages:
1. Open a file of your target language
2. Place your cursor on an import statement
3. Run `:InspectTree` to see the syntax tree
4. Look for the node type that encompasses the import statement

<details>
<summary>Examples of Different Configurations</summary>

1. Minimal setup (uses defaults):
```lua
require('laundry').setup()
```

2. Auto-fold with custom threshold:
```lua
require('laundry').setup({
    auto_fold = true,
    min_fold_lines = 3,
})
```

3. Language-specific thresholds:
```lua
require('laundry').setup({
    auto_fold = true,
    languages = {
        typescript = { min_fold_lines = 10 },
        javascript = { min_fold_lines = 8 },
        python = { min_fold_lines = 5 },
    }
})
```

4. Manual folding only (no auto-fold):
```lua
require('laundry').setup({
    auto_fold = false,
    min_fold_lines = 1,  -- Fold any number of imports when using :LaundryFold
})
```
</details>

## Todo

- [ ] whimmsy up the `README.md`
- [ ] create an art icon
- [ ] create a `CONTRIBUTING.md`
- [ ] create a benchmark tests (1k, 10k, 100k, 1000k imports)
- [ ] create a basic unit test suite
- [ ] make a video explaining why this was done
