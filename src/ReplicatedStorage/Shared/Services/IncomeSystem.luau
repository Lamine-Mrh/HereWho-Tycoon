--[[
	IncomeSystem - Passive income and money generation
	Handles towers generating money, generator upgrades
]]

local IncomeSystem = {}
local ProfileService = require(script.Parent:WaitForChild("ProfileService"))

-- Generator data
local GENERATORS = {
	{
		id = "basic_generator",
		name = "Basic Generator",
		cost = 50,
		incomePerSecond = 5,
		maxLevel = 10,
	},
	{
		id = "advanced_generator",
		name = "Advanced Generator",
		cost = 500,
		incomePerSecond = 50,
		maxLevel = 10,
	},
	{
		id = "elite_generator",
		name = "Elite Generator",
		cost = 5000,
		incomePerSecond = 500,
		maxLevel = 10,
	},
}

--[[
	GetGeneratorData
	Returns generator data
	
	@param generatorId (string) - Generator ID
	@return generator data or nil
]]
function IncomeSystem:GetGeneratorData(generatorId: string)
	for _, gen in ipairs(GENERATORS) do
		if gen.id == generatorId then
			return gen
		end
	end
	return nil
end

--[[
	CalculateTowerIncome
	Calculates total income from all towers
	
	@param placedTowers (table) - Table of placed towers
	@return total income per second
]]
function IncomeSystem:CalculateTowerIncome(placedTowers: {[any]: any}): number
	local totalIncome = 0
	
	for _, tower in ipairs(placedTowers) do
		if tower.incomePerSecond then
			totalIncome = totalIncome + tower.incomePerSecond
		end
	end
	
	return totalIncome
end

--[[
	CalculateGeneratorIncome
	Calculates income from generators with upgrades
	
	@param generators (table) - Player generators {id: level}
	@return total income per second
]]
function IncomeSystem:CalculateGeneratorIncome(generators: {[any]: any}): number
	local totalIncome = 0
	
	if not generators then
		return totalIncome
	end
	
	for genId, level in pairs(generators) do
		local genData = self:GetGeneratorData(genId)
		if genData then
			-- Income scales with level (5% per level)
			local levelMultiplier = 1 + (level * 0.05)
			totalIncome = totalIncome + (genData.incomePerSecond * levelMultiplier)
		end
	end
	
	return totalIncome
end

--[[
	ApplyIncome
	Applies passive income to player profile
	
	@param profile (table) - Player profile
	@param incomePerSecond (number) - Income amount
	@param deltaTime (number) - Time elapsed in seconds
]]
function IncomeSystem:ApplyIncome(profile: {[any]: any}, incomePerSecond: number, deltaTime: number)
	if not profile then
		return
	end
	
	local incomeGained = incomePerSecond * deltaTime
	profile.Money = (profile.Money or 0) + incomeGained
end

--[[
	UpgradeGenerator
	Upgrades a generator
	
	@param profile (table) - Player profile
	@param generatorId (string) - Generator ID
	@return success (boolean), message (string)
]]
function IncomeSystem:UpgradeGenerator(profile: {[any]: any}, generatorId: string)
	local genData = self:GetGeneratorData(generatorId)
	
	if not genData then
		return false, "Generator not found"
	end
	
	if not profile.Generators then
		profile.Generators = {}
	end
	
	local currentLevel = profile.Generators[generatorId] or 0
	
	if currentLevel >= genData.maxLevel then
		return false, "Already at max level"
	end
	
	-- Calculate upgrade cost
	local upgradeCost = genData.cost * ((currentLevel + 1) ^ 1.15)
	
	if (profile.Money or 0) < upgradeCost then
		return false, "Insufficient money. Need: $" .. math.floor(upgradeCost)
	end
	
	profile.Money = profile.Money - upgradeCost
	profile.Generators[generatorId] = currentLevel + 1
	
	return true, "Generator upgraded to level " .. (currentLevel + 1)
end

--[[
	BuyGenerator
	Purchases a new generator
	
	@param profile (table) - Player profile
	@param generatorId (string) - Generator ID
	@return success (boolean), message (string)
]]
function IncomeSystem:BuyGenerator(profile: {[any]: any}, generatorId: string)
	local genData = self:GetGeneratorData(generatorId)
	
	if not genData then
		return false, "Generator not found"
	end
	
	if (profile.Money or 0) < genData.cost then
		return false, "Insufficient money. Need: $" .. genData.cost
	end
	
	if not profile.Generators then
		profile.Generators = {}
	end
	
	-- Check if already owned
	if profile.Generators[generatorId] then
		return false, "Already own this generator. Upgrade it instead."
	end
	
	profile.Money = profile.Money - genData.cost
	profile.Generators[generatorId] = 1
	
	return true, "Generator purchased!"
end

--[[
	GetTotalIncome
	Calculates total passive income including everything
	
	@param profile (table) - Player profile
	@param towers (table) - Placed towers
	@return total income per second
]]
function IncomeSystem:GetTotalIncome(profile: {[any]: any}, towers: {[any]: any}): number
	local generatorIncome = self:CalculateGeneratorIncome(profile.Generators or {})
	local towerIncome = self:CalculateTowerIncome(towers or {})
	
	return generatorIncome + towerIncome
end

return IncomeSystem
