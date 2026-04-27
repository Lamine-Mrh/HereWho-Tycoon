--[[
	IncomeHandler - Manages passive income generation
	Applies income from generators and towers with permanent upgrade multipliers
]]

local SharedServices = require(game.ReplicatedStorage.Shared.SharedServices)
local Players = game:GetService("Players")

-- Income tracking
local INCOME_UPDATE_INTERVAL = 1 -- Update income every 1 second
local placedTowers = _G.TowerPlacement and _G.TowerPlacement.GetPlacedTowers or function() return {} end

--[[
	UpdatePlayerIncome
	Calculates and applies income for player with permanent upgrade multipliers
	
	@param player - Player object
	@param deltaTime (number) - Time elapsed in seconds
]]
local function updatePlayerIncome(player, deltaTime: number)
	local profile = SharedServices.Profile:GetProfile(player.UserId)
	if not profile then
		return
	end
	
	-- Get placed towers
	local towers = placedTowers(player)
	
	-- Calculate base income
	local baseIncome = SharedServices.Income:GetTotalIncome(profile, towers)
	
	-- Apply permanent upgrade multiplier
	local upgradeMultiplier = SharedServices.PermanentUpgrades:GetGeneratorMultiplier(profile)
	local finalIncome = baseIncome * upgradeMultiplier
	
	-- Apply income
	if finalIncome > 0 then
		SharedServices.Income:ApplyIncome(profile, finalIncome, deltaTime)
	end
	
	-- Update leaderstats display
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local moneyValue = leaderstats:FindFirstChild("Money")
		if moneyValue then
			moneyValue.Value = math.floor(profile.Money)
		end
	end
end

-- Main income loop
task.spawn(function()
	while true do
		local startTime = tick()
		task.wait(INCOME_UPDATE_INTERVAL)
		local deltaTime = tick() - startTime
		
		-- Update income for all players
		for _, player in ipairs(Players:GetPlayers()) do
			updatePlayerIncome(player, deltaTime)
		end
	end
end)

-- Expose for global access
_G.IncomeHandler = {
	UpdatePlayerIncome = updatePlayerIncome,
}

print("[IncomeHandler] Income handler loaded! Updating every " .. INCOME_UPDATE_INTERVAL .. " seconds")
