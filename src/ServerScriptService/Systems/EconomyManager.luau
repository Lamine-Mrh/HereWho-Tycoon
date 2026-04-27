--[[
	EconomyManager.luau
	Manages player currency (gold), income, and spending.
	Will be integrated in Phase 2 when towers are added.
	Stub for Phase 1.
]]

local Constants = require(game:GetService("ReplicatedStorage").Shared.Constants)

local EconomyManager = {}

-- Private state
local _gold = Constants.STARTING_GOLD

--[[
	Initialize EconomyManager.
	@return void
]]
function EconomyManager.Init(): void
	_gold = Constants.STARTING_GOLD
end

--[[
	Get current gold.
	@return number
]]
function EconomyManager.GetGold(): number
	return _gold
end

--[[
	Add gold (from kills, waves, etc).
	@param amount number — gold to add
	@return void
]]
function EconomyManager.AddGold(amount: number): void
	_gold += amount
	-- TODO: fire RemoteEvent to clients to update UI
end

--[[
	Spend gold (on towers).
	@param amount number — gold to spend
	@return boolean — true if successful, false if insufficient funds
]]
function EconomyManager.SpendGold(amount: number): boolean
	if _gold >= amount then
		_gold -= amount
		return true
	end
	return false
end

return EconomyManager
