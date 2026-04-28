--[[
	NexusSystem - Core structure defense and health management
	Manages the nexus (central defensive structure) that breaks when health reaches 0
]]

local NexusSystem = {}

-- Nexus data per player
local nexusData = {}

--[[
	InitializeNexus
	Sets up nexus for a player
	
	@param player - Player object or UserId
	@param baseHealth (number) - Initial health value (default 100)
]]
function NexusSystem:InitializeNexus(player, baseHealth: number?)
	local userId = if typeof(player) == "Instance" then player.UserId else player
	baseHealth = baseHealth or 100
	
	nexusData[userId] = {
		health = baseHealth,
		maxHealth = baseHealth,
		isActive = true,
		damageTaken = 0,
		totalDamageResisted = 0,
		createdAt = tick(),
	}
end

--[[
	GetNexusHealth
	Returns current nexus health
	
	@param player - Player object or UserId
	@return current health
]]
function NexusSystem:GetNexusHealth(player): number
	local userId = if typeof(player) == "Instance" then player.UserId else player
	local nexus = nexusData[userId]
	return nexus and nexus.health or 0
end

--[[
	GetMaxHealth
	Returns max nexus health
	
	@param player - Player object or UserId
	@return max health
]]
function NexusSystem:GetMaxHealth(player): number
	local userId = if typeof(player) == "Instance" then player.UserId else player
	local nexus = nexusData[userId]
	return nexus and nexus.maxHealth or 100
end

--[[
	GetHealthPercent
	Returns health as percentage (0-100)
	
	@param player - Player object or UserId
	@return percentage (0-100)
]]
function NexusSystem:GetHealthPercent(player): number
	local userId = if typeof(player) == "Instance" then player.UserId else player
	local nexus = nexusData[userId]
	if not nexus then
		return 0
	end
	return math.floor((nexus.health / nexus.maxHealth) * 100)
end

--[[
	IsNexusAlive
	Checks if nexus is still active
	
	@param player - Player object or UserId
	@return is alive (boolean)
]]
function NexusSystem:IsNexusAlive(player): boolean
	local userId = if typeof(player) == "Instance" then player.UserId else player
	local nexus = nexusData[userId]
	return nexus and nexus.isActive or false
end

--[[
	DamageNexus
	Damages the nexus
	
	@param player - Player object or UserId
	@param damage (number) - Damage amount
	@return new health, isBroken (boolean)
]]
function NexusSystem:DamageNexus(player, damage: number)
	local userId = if typeof(player) == "Instance" then player.UserId else player
	local nexus = nexusData[userId]
	
	if not nexus or not nexus.isActive then
		return 0, false
	end
	
	nexus.health = math.max(0, nexus.health - damage)
	nexus.damageTaken = nexus.damageTaken + damage
	
	local isBroken = false
	if nexus.health <= 0 then
		nexus.isActive = false
		isBroken = true
		print("[NexusSystem] Nexus destroyed for player " .. userId)
	end
	
	return nexus.health, isBroken
end

--[[
	HealNexus
	Heals the nexus
	
	@param player - Player object or UserId
	@param healing (number) - Healing amount
	@return new health
]]
function NexusSystem:HealNexus(player, healing: number)
	local userId = if typeof(player) == "Instance" then player.UserId else player
	local nexus = nexusData[userId]
	
	if not nexus then
		return 0
	end
	
	nexus.health = math.min(nexus.maxHealth, nexus.health + healing)
	return nexus.health
end

--[[
	UpgradeNexusHealth
	Permanently increases nexus max health
	
	@param player - Player object or UserId
	@param amount (number) - Amount to increase
]]
function NexusSystem:UpgradeNexusHealth(player, amount: number)
	local userId = if typeof(player) == "Instance" then player.UserId else player
	local nexus = nexusData[userId]
	
	if not nexus then
		return
	end
	
	nexus.maxHealth = nexus.maxHealth + amount
	nexus.health = math.min(nexus.health + amount, nexus.maxHealth)
	print("[NexusSystem] Nexus health upgraded to " .. nexus.maxHealth .. " for player " .. userId)
end

--[[
	ResetNexus
	Resets nexus to full health (for next run)
	
	@param player - Player object or UserId
]]
function NexusSystem:ResetNexus(player)
	local userId = if typeof(player) == "Instance" then player.UserId else player
	local nexus = nexusData[userId]
	
	if not nexus then
		return
	end
	
	nexus.health = nexus.maxHealth
	nexus.isActive = true
	nexus.damageTaken = 0
end

--[[
	GetNexusStats
	Returns full nexus statistics
	
	@param player - Player object or UserId
	@return nexus stats table
]]
function NexusSystem:GetNexusStats(player)
	local userId = if typeof(player) == "Instance" then player.UserId else player
	local nexus = nexusData[userId]
	
	if not nexus then
		return nil
	end
	
	return {
		health = nexus.health,
		maxHealth = nexus.maxHealth,
		healthPercent = self:GetHealthPercent(player),
		isActive = nexus.isActive,
		damageTaken = nexus.damageTaken,
		totalDamageResisted = nexus.totalDamageResisted,
	}
end

return NexusSystem
