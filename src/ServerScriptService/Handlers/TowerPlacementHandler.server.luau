--[[
	TowerPlacementHandler - Handles tower placement and removal
	Manages tower costs, placement validation, and game state updates
]]

local SharedServices = require(game.ReplicatedStorage.Shared.SharedServices)
local Players = game:GetService("Players")

-- Placed towers per player
local placedTowers = {}

--[[
	PlaceTower
	Places a tower for player
	
	@param player - Player object
	@param towerId (string) - Tower ID to place
	@param position (Vector3) - Where to place tower
	@return success (boolean), message (string)
]]
local function placeTower(player, towerId: string, position: Vector3)
	local profile = SharedServices.Profile:GetProfile(player.UserId)
	local gameState = SharedServices.GameState:GetGameState(player.UserId)
	
	if not profile or not gameState then
		return false, "Profile or game state not found"
	end
	
	-- Get tower data
	local towerData = SharedServices.Tower:GetTowerData(towerId)
	if not towerData then
		return false, "Tower not found: " .. towerId
	end
	
	-- Check if affordable
	if not SharedServices.Tower:IsTowerAffordable(profile, towerData) then
		return false, "Insufficient money. Need: $" .. towerData.cost
	end
	
	-- Check if can place
	if not gameState.defensesActive then
		return false, "Cannot place towers right now"
	end
	
	-- Check tower slots (apply permanent upgrade bonus)
	local baseLevel = profile.BaseLevel or 1
	local maxSlots = SharedServices.BaseExpansion:GetTowerSlots(baseLevel) + SharedServices.PermanentUpgrades:GetExtraSlots(profile)
	
	if gameState.towersPlaced >= maxSlots then
		return false, "Tower slot limit reached (" .. gameState.towersPlaced .. "/" .. maxSlots .. ")"
	end
	
	-- Deduct cost
	profile.Money = profile.Money - towerData.cost
	
	-- Create tower entry
	local tower = {
		id = towerId,
		ownerId = player.UserId,
		name = towerData.name,
		position = position,
		level = 1,
		damage = towerData.damage,
		range = towerData.range,
		attackSpeed = towerData.attackSpeed,
		incomePerSecond = towerData.incomePerSecond or 0,
		placedTime = tick(),
	}
	
	-- Store tower
	if not placedTowers[player.UserId] then
		placedTowers[player.UserId] = {}
	end
	
	table.insert(placedTowers[player.UserId], tower)
	gameState.towersPlaced = gameState.towersPlaced + 1
	
	-- Update stats
	SharedServices.GameState:AddToSessionStats(player, "towersPlaced", 1)
	
	print("[TowerPlacement] Placed " .. towerData.name .. " for " .. player.Name)
	
	return true, "Tower placed!"
end

--[[
	RemoveTower
	Removes a tower and refunds some cost
	
	@param player - Player object
	@param towerIndex (number) - Index of tower to remove
	@return success (boolean), refundAmount (number)
]]
local function removeTower(player, towerIndex: number)
	if not placedTowers[player.UserId] or not placedTowers[player.UserId][towerIndex] then
		return false, 0
	end
	
	local tower = placedTowers[player.UserId][towerIndex]
	local towerData = SharedServices.Tower:GetTowerData(tower.id)
	
	if not towerData then
		return false, 0
	end
	
	-- Refund 50% of cost
	local refund = math.floor(towerData.cost * 0.5)
	
	local profile = SharedServices.Profile:GetProfile(player.UserId)
	if profile then
		profile.Money = profile.Money + refund
	end
	
	-- Remove tower
	table.remove(placedTowers[player.UserId], towerIndex)
	
	local gameState = SharedServices.GameState:GetGameState(player.UserId)
	if gameState then
		gameState.towersPlaced = math.max(0, gameState.towersPlaced - 1)
	end
	
	print("[TowerPlacement] Removed tower for " .. player.Name .. " | Refund: $" .. refund)
	
	return true, refund
end

--[[
	GetPlacedTowers
	Returns all towers placed by player
	
	@param player - Player object or UserId
	@return table of towers
]]
local function getPlacedTowers(player: Player | number)
	local userId = if typeof(player) == "Instance" then player.UserId else player
	return placedTowers[userId] or {}
end

--[[
	UpgradeTower
	Upgrades tower level and stats
	
	@param player - Player object
	@param towerIndex (number) - Tower index
	@return success (boolean), message (string)
]]
local function upgradeTower(player: Player | number, towerIndex: number)
	local userId = if typeof(player) == "Instance" then player.UserId else player
	local towers = placedTowers[userId]
	
	if not towers or not towers[towerIndex] then
		return false, "Tower not found"
	end
	
	local tower = towers[towerIndex]
	local towerData = SharedServices.Tower:GetTowerData(tower.id)
	
	if not towerData then
		return false, "Tower data not found"
	end
	
	if tower.level >= towerData.maxLevel then
		return false, "Already at max level"
	end
	
	local profile = SharedServices.Profile:GetProfile(userId)
	if not profile then
		return false, "Profile not found"
	end
	
	-- Calculate upgrade cost
	local upgradeCost = SharedServices.Tower:CalculateUpgradeCost(
		towerData.cost,
		tower.level,
		towerData.upgradeCostMultiplier
	)
	
	if profile.Money < upgradeCost then
		return false, "Insufficient money. Need: $" .. upgradeCost
	end
	
	-- Apply upgrade
	profile.Money = profile.Money - upgradeCost
	tower.level = tower.level + 1
	
	-- Update stats
	local upgradedStats = SharedServices.Tower:CalculateUpgradedStats(towerData, tower.level)
	tower.damage = upgradedStats.damage
	tower.range = upgradedStats.range
	tower.attackSpeed = upgradedStats.attackSpeed
	
	print("[TowerPlacement] Upgraded tower to level " .. tower.level .. " for player " .. userId)
	
	return true, "Upgraded to level " .. tower.level
end

-- Expose functions for RemoteFunctions
_G.TowerPlacement = {
	PlaceTower = placeTower,
	RemoveTower = removeTower,
	GetPlacedTowers = getPlacedTowers,
	UpgradeTower = upgradeTower,
}

-- Clean up on player leave
Players.PlayerRemoving:Connect(function(player)
	placedTowers[player.UserId] = nil
end)

print("[TowerPlacement] Tower placement handler loaded!")
