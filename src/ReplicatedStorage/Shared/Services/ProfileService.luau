--[[
	ProfileService - Player profile management
	Handles saving and loading player profiles (money, level, progress, etc.)
--]]

local ProfileService = {}
local DataStoreService = require(script.Parent:WaitForChild("DataStoreService"))
local RunService = game:GetService("RunService")

if not RunService:IsServer() then
	error("ProfileService can only be used on the server!")
end

-- Profile storage
local playerProfiles = {}
local profileDataStore = DataStoreService:GetDataStore("PlayerProfiles")

-- Default profile template
local DEFAULT_PROFILE = {
	Money = 0,
	Level = 1,
	Experience = 0,
	PlayTime = 0,
	JoinDate = tick(),
	LastPlayed = tick(),
	Inventory = {},
	TowerInventory = {},
	Generators = {},
	BaseLevel = 1,
	Mana = 100,
	Settings = {
		MusicVolume = 0.5,
		SoundVolume = 0.7,
		Notifications = true,
	},
	Statistics = {
		TowersPlaced = 0,
		MoneyEarned = 0,
		WavesCompleted = 0,
		EnemiesDefeated = 0,
	},
}

--[[
	LoadProfile
	Loads or creates a player profile
	
	@param player - Player object
	@return profile table
]]
function ProfileService:LoadProfile(player)
	assert(player, "player is required")
	
	-- Check if already loaded
	if playerProfiles[player.UserId] then
		return playerProfiles[player.UserId]
	end
	
	local profileKey = "profile_" .. player.UserId
	local loadedProfile = DataStoreService:LoadPlayerData(profileDataStore, profileKey)
	
	-- Create new profile if doesn't exist
	if not loadedProfile then
		loadedProfile = table.clone(DEFAULT_PROFILE)
		print("Created new profile for", player.Name)
	else
		-- Merge with defaults to handle new fields
		for key, value in pairs(DEFAULT_PROFILE) do
			if loadedProfile[key] == nil then
				loadedProfile[key] = value
			end
		end
	end
	
	-- Store in cache
	playerProfiles[player.UserId] = loadedProfile
	loadedProfile._lastSaved = tick()
	
	return loadedProfile
end

--[[
	SaveProfile
	Saves a player profile to DataStore
	
	@param player - Player object or UserId (number)
	@return success (boolean)
]]
function ProfileService:SaveProfile(player)
	local userId = if typeof(player) == "Instance" then player.UserId else player
	assert(userId, "player or userId is required")
	
	local profile = playerProfiles[userId]
	if not profile then
		warn("Profile not found for UserId:", userId)
		return false
	end
	
	local profileKey = "profile_" .. userId
	profile._lastSaved = tick()
	
	local success = DataStoreService:SavePlayerData(profileDataStore, profileKey, profile)
	
	if success then
		print("Profile saved for UserId:", userId)
	end
	
	return success
end

--[[
	GetProfile
	Retrieves a cached profile
	
	@param player - Player object or UserId (number)
	@return profile table or nil
]]
function ProfileService:GetProfile(player)
	local userId = if typeof(player) == "Instance" then player.UserId else player
	return playerProfiles[userId]
end

--[[
	UnloadProfile
	Unloads a player profile (typically on player leaving)
	
	@param player - Player object or UserId (number)
]]
function ProfileService:UnloadProfile(player)
	local userId = if typeof(player) == "Instance" then player.UserId else player
	-- Save before unloading
	self:SaveProfile(userId)
	playerProfiles[userId] = nil
	print("Profile unloaded for UserId:", userId)
end

--[[
	UpdateProfileField
	Updates a specific field in the profile
	
	@param player - Player object or UserId (number)
	@param field (string) - Field name (can be nested with dots: "Statistics.TowersPlaced")
	@param value - New value
]]
function ProfileService:UpdateProfileField(player, field: string, value: any)
	local userId = if typeof(player) == "Instance" then player.UserId else player
	local profile = playerProfiles[userId]
	
	if not profile then
		warn("Profile not found for UserId:", userId)
		return
	end
	
	-- Handle nested fields
	if string.find(field, "%.") then
		local parts = string.split(field, ".")
		local target = profile
		
		for i = 1, #parts - 1 do
			target[parts[i]] = target[parts[i]] or {}
			target = target[parts[i]]
		end
		
		target[parts[#parts]] = value
	else
		profile[field] = value
	end
end

--[[
	AddMoney
	Adds money to a player's profile
	
	@param player - Player object or UserId (number)
	@param amount (number) - Amount to add
]]
function ProfileService:AddMoney(player, amount: number)
	assert(amount, "amount is required")
	amount = tonumber(amount) or 0
	
	local userId = if typeof(player) == "Instance" then player.UserId else player
	local profile = playerProfiles[userId]
	
	if not profile then
		warn("Profile not found for UserId:", userId)
		return
	end
	
	profile.Money = profile.Money + math.floor(amount)
end

--[[
	AddExperience
	Adds experience to a player's profile
	
	@param player - Player object or UserId (number)
	@param amount (number) - Amount of experience to add
]]
function ProfileService:AddExperience(player, amount: number)
	assert(amount, "amount is required")
	amount = tonumber(amount) or 0
	
	local userId = if typeof(player) == "Instance" then player.UserId else player
	local profile = playerProfiles[userId]
	
	if not profile then
		warn("Profile not found for UserId:", userId)
		return
	end
	
	profile.Experience = profile.Experience + math.floor(amount)
	
	-- Level up logic (adjust formula as needed)
	local expPerLevel = 100
	local newLevel = math.floor(profile.Experience / expPerLevel) + 1
	
	if newLevel > profile.Level then
		profile.Level = newLevel
	end
end

--[[
	GetDefaultProfile
	Returns a copy of the default profile template
	
	@return default profile table
]]
function ProfileService:GetDefaultProfile()
	return table.clone(DEFAULT_PROFILE)
end

return ProfileService
