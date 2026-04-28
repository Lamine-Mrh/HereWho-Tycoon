--[[
	RemoteFunctionsSetup - Server-side setup for client-server communication
	Creates RemoteFunctions and RemoteEvents for all game actions
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedServices = require(ReplicatedStorage.Shared.SharedServices)
local Players = game:GetService("Players")

print("[RemoteFunctions] Setting up client-server communication...")

-- =====================
-- UTILITY FUNCTION
-- =====================

local function createRemoteFunction(name: string, callback)
	local remoteFunction = Instance.new("RemoteFunction")
	remoteFunction.Name = name
	remoteFunction.Parent = ReplicatedStorage
	
	function remoteFunction.OnServerInvoke(player, ...)
		return callback(player, ...)
	end
	
	print("[RemoteFunctions] Created RemoteFunction: " .. name)
	return remoteFunction
end

local function createRemoteEvent(name: string, callback)
	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = name
	remoteEvent.Parent = ReplicatedStorage
	
	remoteEvent.OnServerEvent:Connect(function(player, ...)
		callback(player, ...)
	end)
	
	print("[RemoteFunctions] Created RemoteEvent: " .. name)
	return remoteEvent
end

-- =====================
-- TOWER FUNCTIONS
-- =====================

createRemoteFunction("PlaceTowerRemote", function(player, towerId, position)
	if _G.TowerPlacement then
		return _G.TowerPlacement.PlaceTower(player, towerId, position)
	end
	return false, "Tower system not ready"
end)

createRemoteFunction("RemoveTowerRemote", function(player, towerIndex)
	if _G.TowerPlacement then
		local success, refund = _G.TowerPlacement.RemoveTower(player, towerIndex)
		return success, refund
	end
	return false, 0
end)

createRemoteFunction("UpgradeTowerRemote", function(player, towerIndex)
	if _G.TowerPlacement then
		return _G.TowerPlacement.UpgradeTower(player, towerIndex)
	end
	return false, "Tower system not ready"
end)

createRemoteFunction("GetPlacedTowersRemote", function(player)
	if _G.TowerPlacement then
		return _G.TowerPlacement.GetPlacedTowers(player)
	end
	return {}
end)

-- =====================
-- WAVE FUNCTIONS
-- =====================

createRemoteFunction("StartWaveRemote", function(player, waveNumber)
	if _G.WaveHandler then
		_G.WaveHandler.StartWave(waveNumber)
		return true, "Wave started"
	end
	return false, "Wave system not ready"
end)

createRemoteFunction("CompleteWaveRemote", function(player)
	if _G.WaveHandler then
		return _G.WaveHandler.CompleteWave()
	end
	return nil
end)

createRemoteFunction("SkipWaveRemote", function(player)
	if _G.WaveHandler then
		return _G.WaveHandler.SkipWave()
	end
	return false
end)

-- =====================
-- SPELL FUNCTIONS
-- =====================

createRemoteFunction("CastSpellRemote", function(player, spellId)
	if _G.SpellHandler then
		return _G.SpellHandler.CastSpell(player, spellId)
	end
	return false, "Spell system not ready"
end)

createRemoteFunction("GetSpellCooldownRemote", function(player, spellId)
	if _G.SpellHandler then
		return _G.SpellHandler.GetSpellCooldown(player, spellId)
	end
	return 0
end)

createRemoteFunction("GetPlayerManaRemote", function(player)
	if _G.SpellHandler then
		return _G.SpellHandler.GetPlayerMana(player)
	end
	return 100
end)

-- =====================
-- INCOME FUNCTIONS
-- =====================

createRemoteFunction("GetTotalIncomeRemote", function(player)
	local profile = SharedServices.Profile:GetProfile(player.UserId)
	local towers = _G.TowerPlacement and _G.TowerPlacement.GetPlacedTowers(player) or {}
	
	if profile then
		return SharedServices.Income:GetTotalIncome(profile, towers)
	end
	return 0
end)

createRemoteFunction("BuyGeneratorRemote", function(player, generatorId)
	local profile = SharedServices.Profile:GetProfile(player.UserId)
	if profile then
		return SharedServices.Income:BuyGenerator(profile, generatorId)
	end
	return false, "Profile not found"
end)

createRemoteFunction("UpgradeGeneratorRemote", function(player, generatorId)
	local profile = SharedServices.Profile:GetProfile(player.UserId)
	if profile then
		return SharedServices.Income:UpgradeGenerator(profile, generatorId)
	end
	return false, "Profile not found"
end)

-- =====================
-- GACHA FUNCTIONS
-- =====================

createRemoteFunction("RollOnceRemote", function(player)
	local result = SharedServices.Gacha:RollOnce()
	if result then
		SharedServices.Gacha:AddRollToInventory(player, result)
		return result
	end
	return nil
end)

createRemoteFunction("RollMultipleRemote", function(player, amount)
	amount = math.min(amount, 100) -- Limit to 100 rolls per call
	local results = SharedServices.Gacha:RollMultiple(amount)
	
	for _, result in ipairs(results) do
		SharedServices.Gacha:AddRollToInventory(player, result)
	end
	
	return results
end)

createRemoteFunction("GetTowerInventoryRemote", function(player)
	return SharedServices.Gacha:GetTowerInventory(player)
end)

-- =====================
-- BASE EXPANSION FUNCTIONS
-- =====================

createRemoteFunction("UpgradeBaseRemote", function(player)
	local profile = SharedServices.Profile:GetProfile(player.UserId)
	if profile then
		local currentLevel = profile.BaseLevel or 1
		return SharedServices.BaseExpansion:UpgradeBase(profile, currentLevel)
	end
	return false, "Profile not found"
end)

createRemoteFunction("GetBaseInfoRemote", function(player)
	local profile = SharedServices.Profile:GetProfile(player.UserId)
	if not profile then
		return nil
	end
	
	local baseLevel = profile.BaseLevel or 1
	local currentLevelData = SharedServices.BaseExpansion:GetBaseLevel(baseLevel)
	local nextLevelData = SharedServices.BaseExpansion:GetNextBaseLevel(baseLevel)
	
	return {
		currentLevel = baseLevel,
		currentLevelData = currentLevelData,
		nextLevelData = nextLevelData,
	}
end)

-- =====================
-- PROFILE FUNCTIONS
-- =====================

createRemoteFunction("GetPlayerStatsRemote", function(player)
	local profile = SharedServices.Profile:GetProfile(player.UserId)
	if profile then
		return {
			Money = profile.Money,
			Level = profile.Level,
			Experience = profile.Experience,
			PlayTime = profile.PlayTime,
			BaseLevel = profile.BaseLevel or 1,
		}
	end
	return nil
end)

createRemoteFunction("GetLeaderboardRemote", function(player, leaderboardName, limit)
	limit = limit or 10
	return SharedServices.Leaderboard:GetLeaderboard(leaderboardName, limit)
end)

-- =====================
-- GAME STATE FUNCTIONS
-- =====================

createRemoteFunction("GetGameStateRemote", function(player)
	return SharedServices.GameState:GetGameState(player.UserId)
end)

createRemoteFunction("StartGameRemote", function(player)
	SharedServices.GameState:StartGame(player.UserId)
	return true
end)

createRemoteFunction("PauseGameRemote", function(player)
	SharedServices.GameState:PauseGame(player.UserId)
	return true
end)

createRemoteFunction("ResumeGameRemote", function(player)
	SharedServices.GameState:ResumeGame(player.UserId)
	return true
end)

print("[RemoteFunctions] All RemoteFunctions created and ready!")

