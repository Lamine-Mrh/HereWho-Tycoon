--[[
	PermanentUpgradesSystem - Cross-run persistent progression
	Manages upgrades that carry across runs and make subsequent runs easier
]]

local PermanentUpgradesSystem = {}

-- Upgrade categories and tiers
local GENERATOR_MULTIPLIERS = {
	{ level = 1, cost = 5000, multiplier = 1.1 },  -- 10% more income
	{ level = 2, cost = 15000, multiplier = 1.2 },
	{ level = 3, cost = 50000, multiplier = 1.35 },
	{ level = 4, cost = 150000, multiplier = 1.5 },
	{ level = 5, cost = 500000, multiplier = 1.75 },
}

local TOWER_SLOT_UPGRADES = {
	{ level = 1, cost = 3000, slots = 1 },
	{ level = 2, cost = 10000, slots = 1 },
	{ level = 3, cost = 35000, slots = 2 },
	{ level = 4, cost = 100000, slots = 2 },
	{ level = 5, cost = 300000, slots = 3 },
}

local GACHA_RATE_UPGRADES = {
	{ level = 1, cost = 8000, mythicBonus = 0.005 },  -- +0.5% mythic rate
	{ level = 2, cost = 25000, mythicBonus = 0.01 },
	{ level = 3, cost = 75000, mythicBonus = 0.015 },
	{ level = 4, cost = 200000, mythicBonus = 0.02 },
	{ level = 5, cost = 750000, mythicBonus = 0.03 },
}

local NEXUS_HEALTH_UPGRADES = {
	{ level = 1, cost = 10000, healthBonus = 50 },
	{ level = 2, cost = 40000, healthBonus = 75 },
	{ level = 3, cost = 120000, healthBonus = 100 },
	{ level = 4, cost = 350000, healthBonus = 150 },
	{ level = 5, cost = 1000000, healthBonus = 200 },
}

local SPELL_CAPACITY_UPGRADES = {
	{ level = 1, cost = 4000, manaBonus = 10 },
	{ level = 2, cost = 12000, manaBonus = 15 },
	{ level = 3, cost = 40000, manaBonus = 20 },
	{ level = 4, cost = 120000, manaBonus = 30 },
	{ level = 5, cost = 400000, manaBonus = 50 },
}

--[[
	GetUpgradeCategory
	Returns upgrade data for a category
	
	@param category (string) - Upgrade category (generator, tower_slots, gacha, nexus, spell)
	@return upgrade tier table
]]
function PermanentUpgradesSystem:GetUpgradeCategory(category: string)
	if category == "generator" then
		return GENERATOR_MULTIPLIERS
	elseif category == "tower_slots" then
		return TOWER_SLOT_UPGRADES
	elseif category == "gacha" then
		return GACHA_RATE_UPGRADES
	elseif category == "nexus" then
		return NEXUS_HEALTH_UPGRADES
	elseif category == "spell" then
		return SPELL_CAPACITY_UPGRADES
	end
	return nil
end

--[[
	CanAffordUpgrade
	Checks if player can afford an upgrade
	
	@param profile (table) - Player profile
	@param category (string) - Upgrade category
	@param level (number) - Upgrade level
	@return can afford (boolean), cost (number)
]]
function PermanentUpgradesSystem:CanAffordUpgrade(profile: {[any]: any}, category: string, level: number)
	local upgrades = self:GetUpgradeCategory(category)
	if not upgrades or not upgrades[level] then
		return false, 0
	end
	
	local cost = upgrades[level].cost
	return (profile.Money or 0) >= cost, cost
end

--[[
	PurchaseUpgrade
	Purchases a permanent upgrade
	
	@param profile (table) - Player profile
	@param category (string) - Upgrade category
	@param level (number) - Upgrade level to purchase
	@return success (boolean), message (string)
]]
function PermanentUpgradesSystem:PurchaseUpgrade(profile: {[any]: any}, category: string, level: number)
	if not profile.PermanentUpgrades then
		profile.PermanentUpgrades = {}
	end
	
	if not profile.PermanentUpgrades[category] then
		profile.PermanentUpgrades[category] = 0
	end
	
	-- Check if already purchased
	if profile.PermanentUpgrades[category] >= level then
		return false, "Already purchased this upgrade"
	end
	
	local canAfford, cost = self:CanAffordUpgrade(profile, category, level)
	if not canAfford then
		return false, "Cannot afford upgrade. Cost: $" .. cost
	end
	
	profile.Money = profile.Money - cost
	profile.PermanentUpgrades[category] = level
	
	return true, "Upgrade purchased! New level: " .. level
end

--[[
	GetGeneratorMultiplier
	Gets current generator income multiplier from upgrades
	
	@param profile (table) - Player profile
	@return multiplier (1.0+)
]]
function PermanentUpgradesSystem:GetGeneratorMultiplier(profile: {[any]: any}): number
	if not profile.PermanentUpgrades or not profile.PermanentUpgrades.generator then
		return 1.0
	end
	
	local level = profile.PermanentUpgrades.generator
	if level > 0 and GENERATOR_MULTIPLIERS[level] then
		return GENERATOR_MULTIPLIERS[level].multiplier
	end
	
	return 1.0
end

--[[
	GetExtraSlots
	Gets additional tower slots from upgrades
	
	@param profile (table) - Player profile
	@return extra slots (number)
]]
function PermanentUpgradesSystem:GetExtraSlots(profile: {[any]: any}): number
	if not profile.PermanentUpgrades or not profile.PermanentUpgrades.tower_slots then
		return 0
	end
	
	local level = profile.PermanentUpgrades.tower_slots
	local totalSlots = 0
	
	for i = 1, level do
		if TOWER_SLOT_UPGRADES[i] then
			totalSlots = totalSlots + TOWER_SLOT_UPGRADES[i].slots
		end
	end
	
	return totalSlots
end

--[[
	GetGachaBonusRate
	Gets gacha rate bonus from upgrades
	
	@param profile (table) - Player profile
	@return bonus rate (0.0+)
]]
function PermanentUpgradesSystem:GetGachaBonusRate(profile: {[any]: any}): number
	if not profile.PermanentUpgrades or not profile.PermanentUpgrades.gacha then
		return 0
	end
	
	local level = profile.PermanentUpgrades.gacha
	if level > 0 and GACHA_RATE_UPGRADES[level] then
		return GACHA_RATE_UPGRADES[level].mythicBonus
	end
	
	return 0
end

--[[
	GetNexusHealthBonus
	Gets nexus health bonus from upgrades
	
	@param profile (table) - Player profile
	@return health bonus (number)
]]
function PermanentUpgradesSystem:GetNexusHealthBonus(profile: {[any]: any}): number
	if not profile.PermanentUpgrades or not profile.PermanentUpgrades.nexus then
		return 0
	end
	
	local level = profile.PermanentUpgrades.nexus
	local totalHealth = 0
	
	for i = 1, level do
		if NEXUS_HEALTH_UPGRADES[i] then
			totalHealth = totalHealth + NEXUS_HEALTH_UPGRADES[i].healthBonus
		end
	end
	
	return totalHealth
end

--[[
	GetManaBonus
	Gets max mana bonus from upgrades
	
	@param profile (table) - Player profile
	@return mana bonus (number)
]]
function PermanentUpgradesSystem:GetManaBonus(profile: {[any]: any}): number
	if not profile.PermanentUpgrades or not profile.PermanentUpgrades.spell then
		return 0
	end
	
	local level = profile.PermanentUpgrades.spell
	local totalMana = 0
	
	for i = 1, level do
		if SPELL_CAPACITY_UPGRADES[i] then
			totalMana = totalMana + SPELL_CAPACITY_UPGRADES[i].manaBonus
		end
	end
	
	return totalMana
end

--[[
	GetAllUpgrades
	Returns all available upgrades for display
	
	@return table with all upgrade categories
]]
function PermanentUpgradesSystem:GetAllUpgrades()
	return {
		generator = GENERATOR_MULTIPLIERS,
		tower_slots = TOWER_SLOT_UPGRADES,
		gacha = GACHA_RATE_UPGRADES,
		nexus = NEXUS_HEALTH_UPGRADES,
		spell = SPELL_CAPACITY_UPGRADES,
	}
end

--[[
	GetUpgradeProgress
	Gets progress for all upgrades
	
	@param profile (table) - Player profile
	@return table with all upgrade progress
]]
function PermanentUpgradesSystem:GetUpgradeProgress(profile: {[any]: any})
	local upgrades = profile.PermanentUpgrades or {}
	
	return {
		generator = upgrades.generator or 0,
		tower_slots = upgrades.tower_slots or 0,
		gacha = upgrades.gacha or 0,
		nexus = upgrades.nexus or 0,
		spell = upgrades.spell or 0,
	}
end

return PermanentUpgradesSystem
