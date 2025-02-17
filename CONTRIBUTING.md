# Contributing

Thank you for your willingness to contribute to 'laundry.nvim'. Our lives are
comically short and we appreciate the moments you are willing to sacrifice to help

You can make contributions in the following ways:

- **Mention it** somehow deliberate sharing works. Crazy how humans need to do
this.
- **Participate in [discussions](https://github.com/shimman-dev/laundry.nvim/discussions)**.

All comments that question our existence or our purpose, or those that which are politeful, existential, and respectful are always welcome! Thanks for reading this! Remember that not all existential thoughts or musings will last forever, those that do make such comments and are unable to 

## Commit messages

- Try to make commit message as concise as possible while giving enough information about nature of a change. Think about whether it will be easy to understand in one year time when browsing through commit history.

- Single commit should change either zero or one module, or affect all modules (i.e. enforcing some universal rule but not necessarily change files). Changes for two or more modules should be split in several module-specific commits.

- Use [Conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) style:
    - Messages should have the following structure:

        ```
        <type>[optional scope][!]: <description>
        <empty line>
        [optional body]
        <empty line>
        [optional footer(s)]
        ```

    - `<type>` is **mandatory** and can be one of:
        - `ci` - change in how automation (GitHub actions, dual distribution scripts, etc.) is done.
        - `docs` - change in user facing documentation (help, README, CONTRIBUTING, etc.).
        - `feat` - adding new user facing feature.
        - `fix` - resolving user facing issue.
        - `refactor` - change in code or documentation that should not affect users.
        - `style` - change in convention of how something should be done (formatting, wording, etc.) and its effects.
        - `test` - change in tests.
      For temporary commits which later should be squashed (when working on PR, for example), use `fixup` type.
    - `[optional scope]`, if present, should be done in parenthesis `()`. If commit changes single module (as it usually should), using scope with module name is **mandatory**. If commit enforces something for all modules, use `ALL` scope.
    - Breaking change, if present, should be expressed with `!` before `:`.
    - `<description>` is a change overview in imperative, present tense ("change" not "changed" nor "changes"). Should result into first line under 72 characters. Should start with not capitalized word and NOT end with sentence ending punctuation (i.e. one of `.,?!;`).
    - `[optional body]`, if present, should contain details and motivation about the change in plain language. Should be formatted to have maximum 80 characters in line.
    - `[optional footer(s)]`, if present, should be instruction(s) to Git. Use "Resolve #xxx" on separate line if this commit resolves issue or PR.

Examples:

```
refact: do not source 'vim.treesitter' on `require()`
```

```
feat(lang): adding support for `python`
```


## Testing

When when adding a new language to support, please include a sample code snippet in
the PR of the relevant language example file of code containing 25 import
statements with a simple function after the imports. You can do this in the PR
message body using the appropriate markdown notation. Here's an example of doing
such a thing using typescript:

```typescript
import _ from 'lodash';
import { v4 as uuidv4 } from 'uuid';
import moment from 'moment';
import axios from 'axios';
import chalk from 'chalk';
import React from 'react';
import ReactDOM from 'react-dom';
import { useState, useEffect } from 'react';
import { BrowserRouter, Route, Routes } from 'react-router-dom';
import { Provider } from 'react-redux';
import { createStore, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';
import { configureStore } from '@reduxjs/toolkit';
import { useSelector, useDispatch } from 'react-redux';
import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import mongoose from 'mongoose';
import * as d3 from 'd3';

const telephone = (name: string) => {
	const greeting = `Ahoy-hoy! Is this ${name}`;
	return greeting;
}
```

## Formatting

This project uses [StyLua](https://github.com/JohnnyMorganz/StyLua) version 0.19.0 for formatting Lua code. Before making changes to code, please:

- [Install StyLua](https://github.com/JohnnyMorganz/StyLua#installation). NOTE: use `v0.19.0`.
- Format with it. Currently there are two ways to do this:
    - Manually run `stylua .` from the root directory of this project.

## Adding Support for Additional Languages

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

            -- Only fold when there are >=10 import lines
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

Feel free to add missing programming languages in a PR.

Refer to the section in the `README.md` named `Current Language Support` for the
current language support.


