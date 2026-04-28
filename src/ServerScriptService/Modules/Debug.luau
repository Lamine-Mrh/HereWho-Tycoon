--[[
	Debug.luau

	Utility for conditional debug logging. Respects Constants.DEBUG flag.
	When DEBUG is true, prints appear in output. When false, prints are silenced.
	Use this to log events without polluting production console.

	@requires Constants — DEBUG flag controls whether prints appear
]]

local Constants = require(game:GetService("ReplicatedStorage").Shared.Constants)

local Debug = {}

--[[
	Print a debug message if Constants.DEBUG is enabled.
	Prepends [DEBUG] tag for easy filtering. Safe to call with any number of args.

	@param ... any — values to print (same as print())
	@return void
]]
function Debug.Print(...): void
	if Constants.DEBUG then
		print("[DEBUG]", ...)
	end
end

--[[
	Print a tagged debug message (e.g., [WAVE], [ENEMY], [ECONOMY]).
	Useful for tracking specific systems during development.

	@param tag string — label for the message (e.g., "WAVE", "ENEMY", "ECONOMY")
	@param ... any — values to print
	@return void
]]
function Debug.PrintTag(tag: string, ...): void
	if Constants.DEBUG then
		print("[" .. tag .. "]", ...)
	end
end

return Debug
