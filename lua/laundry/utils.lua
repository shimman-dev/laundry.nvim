-- lua/laundry/utils.lua
local M = {}

local debounce_timer = vim.uv.new_timer()
local debounce_delay = 100

M.debounce = function(fn)
	return function(...)
		local args = { ... }
		debounce_timer:stop()
		debounce_timer:start(debounce_delay, 0, function()
			vim.schedule_wrap(fn)(unpack(args))
		end)
	end
end

M.update_debounce_delay = function(delay)
	debounce_delay = delay
end

return M
