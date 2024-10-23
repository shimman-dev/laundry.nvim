-- Create a buffer with many imports
local function setup_test_buffer(num_imports)
	vim.cmd("new")
	local buf = vim.api.nvim_get_current_buf()
	local lines = {}

	-- Create import lines
	for i = 1, num_imports do
		table.insert(
			lines,
			string.format('import { Component%d } from "module-%d";', i, i)
		)
	end

	-- Add some regular code after imports
	table.insert(lines, "")
	table.insert(lines, "function test() {")
	table.insert(lines, "  // Some code")
	table.insert(lines, "}")

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].filetype = "typescript"
	return buf
end

-- Run benchmark
local function run_benchmark(num_imports)
	local laundry = require("laundry")
	laundry.setup({
		auto_fold = true,
		-- Ensure we fold everything
		min_fold_lines = 0,
	})

	local buf = setup_test_buffer(num_imports)

	-- Measure time for folding
	local start_time = vim.loop.hrtime()
	laundry.fold_imports()
	local end_time = vim.loop.hrtime()

	local duration_ms = (end_time - start_time) / 1e6
	print(
		string.format("Folding %d imports took %.2f ms", num_imports, duration_ms)
	)

	vim.cmd("bdelete!")
	return duration_ms
end

-- Test with increasing numbers of imports (1k, 10k, 100k, 1000k)
local test_sizes = { 1000, 10000, 100000, 1000000 }
print("Starting benchmark...")

for _, size in ipairs(test_sizes) do
	-- Clean up before each test
	collectgarbage("collect")
	run_benchmark(size)
end
