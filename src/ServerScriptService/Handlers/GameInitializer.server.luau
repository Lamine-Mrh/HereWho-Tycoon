--[[
	GameInitializer - Main game initialization on server startup
	Sets up all systems, leaderboards, shops, and game configuration
]]

local Players = game:GetService("Players")
local SharedServices = require(game.ReplicatedStorage.Shared.SharedServices)
local SharedConfig = require(game.ReplicatedStorage.Shared.Config.SharedConfig)

print("[GameInitializer] Starting game initialization...")

-- =====================
-- SETUP SYSTEMS
-- =====================

local function initializeSystems()
	print("[GameInitializer] Initializing game systems...")
	
	-- Initialize leaderboards
	for _, lbConfig in ipairs(SharedConfig.LEADERBOARDS) do
		SharedServices.Leaderboard:RegisterLeaderboard(lbConfig.name, lbConfig.sortDescending)
	end
	
	-- Initialize shops
	for shopName, shopConfig in pairs(SharedConfig.SHOPS) do
		SharedServices.Shop:RegisterShop(shopName, shopConfig)
		for itemId, itemData in pairs(shopConfig.items) do
			SharedServices.Shop:AddItemToShop(shopName, itemId, itemData)
		end
	end
	
	-- Initialize game passes
	for _, pass in ipairs(SharedConfig.GAME_PASSES) do
		if pass.id > 0 then
			SharedServices.Marketplace:RegisterGamePass(pass.id, pass)
		end
	end
	
	-- Initialize developer products
	for _, product in ipairs(SharedConfig.DEVELOPER_PRODUCTS) do
		if product.id > 0 then
			SharedServices.Marketplace:RegisterDeveloperProduct(product.id, product)
		end
	end
	
	print("[GameInitializer] Systems initialized!")
end

-- =====================
-- PLAYER SETUP
-- =====================

local function onPlayerAdded(player)
	print("[GameInitializer] Loading game data for " .. player.Name)
	
	-- Load profile
	local profile = SharedServices.Profile:LoadProfile(player)
	
	-- Initialize game state
	SharedServices.GameState:InitializeGameState(player, profile)
	
	-- Initialize run progression if not exists
	if not profile.RunProgression then
		profile.RunProgression = SharedServices.RunProgression:InitializeRunProgression(player)
	end
	
	-- Initialize permanent upgrades if not exists
	if not profile.PermanentUpgrades then
		profile.PermanentUpgrades = {}
	end
	
	-- Create leaderstats for display
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	local moneyValue = Instance.new("IntValue")
	moneyValue.Name = "Money"
	moneyValue.Value = profile.Money
	moneyValue.Parent = leaderstats
	
	local levelValue = Instance.new("IntValue")
	levelValue.Name = "Level"
	levelValue.Value = profile.Level
	levelValue.Parent = leaderstats
	
	print("[GameInitializer] Loaded " .. player.Name .. " | Money: $" .. profile.Money .. " | Level: " .. profile.Level)
end

local function onPlayerRemoving(player)
	print("[GameInitializer] Saving data for " .. player.Name)
	
	-- Save profile
	SharedServices.Profile:SaveProfile(player)
	
	-- Update leaderboards
	local profile = SharedServices.Profile:GetProfile(player.UserId)
	if profile then
		SharedServices.Leaderboard:UpdateLeaderboardEntry("TopMoney", player.UserId, player.Name, profile.Money)
		SharedServices.Leaderboard:UpdateLeaderboardEntry("TopLevel", player.UserId, player.Name, profile.Level)
	end
	
	print("[GameInitializer] Data saved for " .. player.Name)
end

-- =====================
-- EVENTS
-- =====================

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Handle existing players
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

-- =====================
-- AUTO-SAVE & MAINTENANCE
-- =====================

local AUTO_SAVE_INTERVAL = 60 -- Save every 60 seconds

task.spawn(function()
	while true do
		task.wait(AUTO_SAVE_INTERVAL)
		
		-- Save all profiles
		for _, player in ipairs(Players:GetPlayers()) do
			SharedServices.Profile:SaveProfile(player)
		end
		
		-- Save leaderboards
		SharedServices.Leaderboard:SaveLeaderboards()
		
		print("[GameInitializer] Auto-saved all data")
	end
end)

-- =====================
-- STARTUP
-- =====================

initializeSystems()

print("[GameInitializer] Game fully initialized! Ready for players.")
