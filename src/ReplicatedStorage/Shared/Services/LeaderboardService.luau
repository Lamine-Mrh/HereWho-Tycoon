--[[
	LeaderboardService - Leaderboard management
	Handles tracking and retrieving leaderboard data
--]]

local LeaderboardService = {}
local DataStoreService = require(script.Parent:WaitForChild("DataStoreService"))
local RunService = game:GetService("RunService")

if not RunService:IsServer() then
	error("LeaderboardService can only be used on the server!")
end

local leaderboardDataStore = DataStoreService:GetDataStore("Leaderboards")
local leaderboards = {}

--[[
	RegisterLeaderboard
	Registers a new leaderboard type
	
	@param name (string) - Leaderboard name (e.g., "TopMoney", "TopLevel")
	@param sortDescending (boolean) - Whether to sort in descending order
]]
function LeaderboardService:RegisterLeaderboard(name: string, sortDescending: boolean?)
	assert(name, "name is required")
	
	if leaderboards[name] then
		warn("Leaderboard", name, "already registered")
		return
	end
	
	leaderboards[name] = {
		entries = {},
		sortDescending = if sortDescending == nil then true else sortDescending,
		lastUpdated = tick(),
	}
	
	print("Registered leaderboard:", name)
end

--[[
	UpdateLeaderboardEntry
	Updates a player's entry in a leaderboard
	
	@param leaderboardName (string) - Name of the leaderboard
	@param userId (number) - Player's UserId
	@param playerName (string) - Player's name
	@param score (number) - Score value
]]
function LeaderboardService:UpdateLeaderboardEntry(
	leaderboardName: string,
	userId: number,
	playerName: string,
	score: number
)
	assert(leaderboardName, "leaderboardName is required")
	assert(userId, "userId is required")
	assert(playerName, "playerName is required")
	assert(tonumber(score), "score must be a number")
	
	local leaderboard = leaderboards[leaderboardName]
	if not leaderboard then
		warn("Leaderboard not found:", leaderboardName)
		return
	end
	
	-- Remove old entry if exists
	for i, entry in ipairs(leaderboard.entries) do
		if entry.userId == userId then
			table.remove(leaderboard.entries, i)
			break
		end
	end
	
	-- Add new entry
	table.insert(leaderboard.entries, {
		userId = userId,
		playerName = playerName,
		score = score,
		timestamp = tick(),
	})
	
	-- Sort leaderboard
	table.sort(leaderboard.entries, function(a, b)
		if leaderboard.sortDescending then
			return a.score > b.score
		else
			return a.score < b.score
		end
	end)
	
	leaderboard.lastUpdated = tick()
end

--[[
	GetLeaderboard
	Gets a leaderboard with optional limit
	
	@param leaderboardName (string) - Name of the leaderboard
	@param limit (number) - Max entries to return (default: 10)
	@return table of entries
]]
function LeaderboardService:GetLeaderboard(leaderboardName: string, limit: number?)
	assert(leaderboardName, "leaderboardName is required")
	
	limit = limit or 10
	local leaderboard = leaderboards[leaderboardName]
	
	if not leaderboard then
		warn("Leaderboard not found:", leaderboardName)
		return {}
	end
	
	local result = {}
	for i = 1, math.min(limit, #leaderboard.entries) do
		local entry = leaderboard.entries[i]
		table.insert(result, {
			rank = i,
			userId = entry.userId,
			playerName = entry.playerName,
			score = entry.score,
		})
	end
	
	return result
end

--[[
	GetPlayerRank
	Gets a player's rank in a leaderboard
	
	@param leaderboardName (string) - Name of the leaderboard
	@param userId (number) - Player's UserId
	@return rank (number) or nil if not on leaderboard
]]
function LeaderboardService:GetPlayerRank(leaderboardName: string, userId: number)
	assert(leaderboardName, "leaderboardName is required")
	assert(userId, "userId is required")
	
	local leaderboard = leaderboards[leaderboardName]
	if not leaderboard then
		return nil
	end
	
	for i, entry in ipairs(leaderboard.entries) do
		if entry.userId == userId then
			return i
		end
	end
	
	return nil
end

--[[
	SaveLeaderboards
	Saves all leaderboards to DataStore
	
	@return success (boolean)
]]
function LeaderboardService:SaveLeaderboards()
	local success = DataStoreService:SavePlayerData(leaderboardDataStore, "allLeaderboards", leaderboards)
	
	if success then
		print("Leaderboards saved")
	end
	
	return success
end

--[[
	LoadLeaderboards
	Loads all leaderboards from DataStore
	
	@return success (boolean)
]]
function LeaderboardService:LoadLeaderboards()
	local loadedLeaderboards = DataStoreService:LoadPlayerData(leaderboardDataStore, "allLeaderboards")
	
	if loadedLeaderboards then
		leaderboards = loadedLeaderboards
		print("Leaderboards loaded")
		return true
	end
	
	return false
end

return LeaderboardService
