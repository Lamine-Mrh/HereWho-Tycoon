--[[
	SharedServicesInit - Example initialization script
	Place this in ServerScriptService to initialize all shared services
	
	This is a template that you should customize for your game
]]

local Players = game:GetService("Players")
local SharedServices = require(game.ReplicatedStorage.Shared.SharedServices)
local SharedConfig = require(game.ReplicatedStorage.Shared.Config.SharedConfig)

-- =====================
-- INITIALIZATION
-- =====================

local function initializeServices()
	print("[SharedServices] Initializing services...")
	
	-- === Setup Leaderboards ===
	print("[SharedServices] Setting up leaderboards...")
	for _, lbConfig in ipairs(SharedConfig.LEADERBOARDS) do
		SharedServices.Leaderboard:RegisterLeaderboard(lbConfig.name, lbConfig.sortDescending)
	end
	
	-- === Setup Shops ===
	print("[SharedServices] Setting up shops...")
	for shopName, shopConfig in pairs(SharedConfig.SHOPS) do
		SharedServices.Shop:RegisterShop(shopName, shopConfig)
		
		-- Add items to shop
		for itemId, itemData in pairs(shopConfig.items) do
			SharedServices.Shop:AddItemToShop(shopName, itemId, itemData)
		end
	end
	
	-- === Setup Game Passes ===
	print("[SharedServices] Setting up game passes...")
	for _, pass in ipairs(SharedConfig.GAME_PASSES) do
		if pass.id > 0 then -- Only register if ID is set
			SharedServices.Marketplace:RegisterGamePass(pass.id, pass)
		end
	end
	
	-- === Setup Developer Products ===
	print("[SharedServices] Setting up developer products...")
	for _, product in ipairs(SharedConfig.DEVELOPER_PRODUCTS) do
		if product.id > 0 then -- Only register if ID is set
			SharedServices.Marketplace:RegisterDeveloperProduct(product.id, product)
		end
	end
	
	print("[SharedServices] Services initialized successfully!")
end

-- =====================
-- PLAYER MANAGEMENT
-- =====================

local function onPlayerAdded(player)
	print("[SharedServices] Loading profile for:", player.Name)
	
	-- Load player profile
	local profile = SharedServices.Profile:LoadProfile(player)
	
	-- Optional: Create a leaderstats folder (for basic display)
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
	
	-- Update leaderstats when profile changes
	local function updateLeaderstats()
		moneyValue.Value = profile.Money
		levelValue.Value = profile.Level
		
		-- Update leaderboards
		SharedServices.Leaderboard:UpdateLeaderboardEntry("TopMoney", player.UserId, player.Name, profile.Money)
		SharedServices.Leaderboard:UpdateLeaderboardEntry("TopLevel", player.UserId, player.Name, profile.Level)
	end
	
	-- Hook into profile changes (you'll need to call this when data changes)
	player:SetAttribute("UpdateLeaderstats", updateLeaderstats)
	
	print("[SharedServices] Profile loaded for:", player.Name, "| Money:", profile.Money, "| Level:", profile.Level)
end

local function onPlayerRemoving(player)
	print("[SharedServices] Unloading profile for:", player.Name)
	
	-- Save and unload profile
	SharedServices.Profile:SaveProfile(player)
	SharedServices.Profile:UnloadProfile(player)
	
	print("[SharedServices] Profile saved and unloaded for:", player.Name)
end

-- =====================
-- SETUP EVENTS
-- =====================

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Handle existing players
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

-- Initialize services
initializeServices()

-- =====================
-- SHOP PURCHASE HANDLER (Example)
-- =====================

local function setupShopPurchaseHandler()
	local mainShop = SharedServices.Shop:GetShop("MainShop")
	
	if mainShop and mainShop.PurchasedSignal then
		mainShop.PurchasedSignal:Connect(function(userId, itemId, price)
			local player = Players:FindFirstChild(tostring(userId)) or Players:FindFirstChild(tostring(userId))
			
			-- Find player by UserId
			local targetPlayer
			for _, p in ipairs(Players:GetPlayers()) do
				if p.UserId == userId then
					targetPlayer = p
					break
				end
			end
			
			if targetPlayer then
				print("[Shop] " .. targetPlayer.Name .. " purchased " .. itemId .. " for " .. price)
				-- Handle shop purchase effects here
				-- Example: Give the player the item, play a sound, etc.
			end
		end)
	end
end

setupShopPurchaseHandler()

-- =====================
-- OPTIONAL: Auto-save profiles periodically
-- =====================

local AUTO_SAVE_INTERVAL = 60 -- Save every 60 seconds

task.spawn(function()
	while true do
		task.wait(AUTO_SAVE_INTERVAL)
		
		-- Save all loaded profiles
		for _, player in ipairs(Players:GetPlayers()) do
			SharedServices.Profile:SaveProfile(player)
		end
		
		-- Save leaderboards
		SharedServices.Leaderboard:SaveLeaderboards()
		
		print("[SharedServices] Auto-saved all profiles and leaderboards")
	end
end)

print("[SharedServices] Initialization script loaded!")
