--[[
	ClientServicesExample - Example client-side integration
	Shows how to use SharedServices from the client side
	
	Note: Most services are server-only, so use RemoteEvents/RemoteFunctions for client access
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Note: SharedServices cannot be required directly on the client
-- Instead, create RemoteEvents/RemoteFunctions in ServerScriptService to communicate
-- This is just an example of how you would structure the calls

-- =====================
-- CLIENT-SIDE SERVICES
-- =====================

local ClientServices = {}

--[[
	Note: These functions should call RemoteFunctions on the server
	The server then uses SharedServices to handle the actual logic
]]

function ClientServices:GetPlayerStats()
	-- Example: would call a RemoteFunction to get player stats from server
	local stats = player:FindFirstChild("leaderstats")
	if stats then
		return {
			Money = stats:FindFirstChild("Money") and stats.Money.Value or 0,
			Level = stats:FindFirstChild("Level") and stats.Level.Value or 1,
		}
	end
	return { Money = 0, Level = 1 }
end

function ClientServices:PurchaseItem(shopName: string, itemId: string)
	-- This should call a RemoteFunction on the server
	-- RemoteFunction should call SharedServices.Shop:PurchaseItem()
	local RemoteFunction = ReplicatedStorage:FindFirstChild("PurchaseItemRemote")
	if RemoteFunction then
		return RemoteFunction:InvokeServer(shopName, itemId)
	end
end

function ClientServices:SendDonation(recipientUserId: number, amount: number)
	-- This should call a RemoteFunction on the server
	-- RemoteFunction should call SharedServices.Donation:DonateToPlayer()
	local RemoteFunction = ReplicatedStorage:FindFirstChild("DonateToPlayerRemote")
	if RemoteFunction then
		return RemoteFunction:InvokeServer(recipientUserId, amount)
	end
end

function ClientServices:GetLeaderboard(leaderboardName: string, limit: number?)
	-- This should call a RemoteFunction on the server
	-- RemoteFunction should call SharedServices.Leaderboard:GetLeaderboard()
	local RemoteFunction = ReplicatedStorage:FindFirstChild("GetLeaderboardRemote")
	if RemoteFunction then
		return RemoteFunction:InvokeServer(leaderboardName, limit or 10)
	end
end

-- =====================
-- EXAMPLE USAGE
-- =====================

local function exampleGetStats()
	print("=== Player Stats ===")
	local stats = ClientServices:GetPlayerStats()
	print("Money:", stats.Money)
	print("Level:", stats.Level)
end

local function examplePurchaseItem()
	print("=== Attempting to purchase item ===")
	local success, message = ClientServices:PurchaseItem("MainShop", "tower_basic")
	print("Success:", success)
	print("Message:", message)
end

local function exampleGetLeaderboard()
	print("=== Top 10 Richest Players ===")
	local lb = ClientServices:GetLeaderboard("TopMoney", 10)
	for rank, entry in ipairs(lb) do
		print(rank .. ". " .. entry.playerName .. " - $" .. entry.score)
	end
end

-- =====================
-- REMOTE FUNCTION SETUP
-- =====================

--[[
	These RemoteFunctions should be created in ServerScriptService
	and handled there to call SharedServices
	
	Example RemoteFunction handler:
	
	local RemoteFunction = Instance.new("RemoteFunction")
	RemoteFunction.Name = "PurchaseItemRemote"
	RemoteFunction.Parent = game.ReplicatedStorage
	
	function RemoteFunction.OnServerInvoke(player, shopName, itemId)
		local SharedServices = require(game.ReplicatedStorage.Shared.SharedServices)
		return SharedServices.Shop:PurchaseItem(player, shopName, itemId)
	end
]]

-- Un-comment below to test (after setting up RemoteFunctions on server)
-- exampleGetStats()
-- exampleGetLeaderboard()

print("[Client] Services example loaded!")

return ClientServices
