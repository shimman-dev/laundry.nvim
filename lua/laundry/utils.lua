---@class Utils
local M = {}

-- Timer for debouncing function calls
---@type userdata
local debounce_timer = vim.uv.new_timer()

-- Default debounce delay in milliseconds
---@type integer
local debounce_delay = 100

---@generic T: function
---@param fn T
---@return T
--- The debounce function creates a new function that delays invoking `fn`
-- until after `debounce_delay` milliseconds have elapsed since the last time
-- the debounced function was invoked. This is useful for limiting the rate
-- at which a function can fire, especially for performance-intensive operations.
function M.debounce(fn)
	---@type T
	return function(...)
		local args = { ... }
		debounce_timer:stop()
		debounce_timer:start(debounce_delay, 0, function()
			vim.schedule_wrap(fn)(unpack(args))
		end)
	end
end

---@param delay integer
function M.update_debounce_delay(delay)
	debounce_delay = delay
end

return M
