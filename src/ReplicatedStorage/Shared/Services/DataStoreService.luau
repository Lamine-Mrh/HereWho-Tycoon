--[[
	DataStoreService - Wrapper around Roblox DataStore API
	Provides simplified methods for saving and loading player data
--]]

local DataStoreService = {}
local RunService = game:GetService("RunService")
local RobloxDataStoreService = game:GetService("DataStoreService")

-- Cache for player data
local playerDataCache = {}

-- Wait for server
if not RunService:IsServer() then
	error("DataStoreService can only be used on the server!")
end

--[[
	GetDataStore
	Creates or gets a named DataStore
	
	@param storeName (string) - Name of the DataStore
	@return DataStore object
]]
function DataStoreService:GetDataStore(storeName: string)
	assert(storeName, "storeName is required")
	local success, dataStore = pcall(function()
		return RobloxDataStoreService:GetDataStore(storeName)
	end)
	
	if not success then
		warn("Failed to get DataStore '" .. storeName .. "':", dataStore)
		return nil
	end
	
	return dataStore
end

--[[
	LoadPlayerData
	Attempts to load player data with retry logic
	
	@param dataStore - DataStore object
	@param key (string) - The data key
	@param maxRetries (number) - Max attempts to load data
	@return data or nil
]]
function DataStoreService:LoadPlayerData(dataStore, key: string, maxRetries: number?)
	maxRetries = maxRetries or 3
	assert(key, "key is required")
	
	for attempt = 1, maxRetries do
		local success, data = pcall(function()
			return dataStore:GetAsync(key)
		end)
		
		if success then
			return data
		end
		
		if attempt < maxRetries then
			task.wait(1)
		end
	end
	
	warn("Failed to load data for key:", key, "after", maxRetries, "attempts")
	return nil
end

--[[
	SavePlayerData
	Attempts to save player data with retry logic
	
	@param dataStore - DataStore object
	@param key (string) - The data key
	@param data - The data to save
	@param maxRetries (number) - Max attempts to save data
	@return success (boolean)
]]
function DataStoreService:SavePlayerData(dataStore, key: string, data: any, maxRetries: number?): boolean
	maxRetries = maxRetries or 3
	assert(key, "key is required")
	
	for attempt = 1, maxRetries do
		local success = pcall(function()
			dataStore:SetAsync(key, data)
		end)
		
		if success then
			return true
		end
		
		if attempt < maxRetries then
			task.wait(1)
		end
	end
	
	warn("Failed to save data for key:", key, "after", maxRetries, "attempts")
	return false
end

--[[
	IncrementValue
	Increments a value in the DataStore
	
	@param dataStore - DataStore object
	@param key (string) - The data key
	@param amount (number) - Amount to increment
	@return new value or nil
]]
function DataStoreService:IncrementValue(dataStore, key: string, amount: number)
	assert(key, "key is required")
	amount = amount or 1
	
	local success, newValue = pcall(function()
		return dataStore:IncrementAsync(key, amount)
	end)
	
	if success then
		return newValue
	end
	
	warn("Failed to increment value for key:", key)
	return nil
end

--[[
	RemoveKey
	Removes a key from the DataStore
	
	@param dataStore - DataStore object
	@param key (string) - The data key
	@return success (boolean)
]]
function DataStoreService:RemoveKey(dataStore, key: string): boolean
	assert(key, "key is required")
	
	local success = pcall(function()
		dataStore:RemoveAsync(key)
	end)
	
	return success
end

return DataStoreService
