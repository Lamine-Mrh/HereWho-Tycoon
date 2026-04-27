--[[
	DonationService - Donation and gifting system
	Handles player-to-player donations and guild/team donations
--]]

local DonationService = {}
local ProfileService = require(script.Parent:WaitForChild("ProfileService"))
local DataStoreService = require(script.Parent:WaitForChild("DataStoreService"))
local RunService = game:GetService("RunService")

if not RunService:IsServer() then
	error("DonationService can only be used on the server!")
end

local donationDataStore = DataStoreService:GetDataStore("Donations")
local donations = {}

--[[
	DonateToPlayer
	Sends a donation from one player to another
	
	@param fromUserId (number) - Sender's UserId
	@param toUserId (number) - Recipient's UserId
	@param amount (number) - Amount to donate
	@param currency (string) - Currency type (default: "Money")
	@return success (boolean), message (string)
]]
function DonationService:DonateToPlayer(fromUserId: number, toUserId: number, amount: number, currency: string?)
	assert(fromUserId, "fromUserId is required")
	assert(toUserId, "toUserId is required")
	assert(amount, "amount is required")
	
	currency = currency or "Money"
	amount = tonumber(amount) or 0
	
	if amount <= 0 then
		return false, "Donation amount must be positive"
	end
	
	if fromUserId == toUserId then
		return false, "Cannot donate to yourself"
	end
	
	local fromProfile = ProfileService:GetProfile(fromUserId)
	local toProfile = ProfileService:GetProfile(toUserId)
	
	if not fromProfile then
		return false, "Sender profile not found"
	end
	
	if not toProfile then
		return false, "Recipient profile not found"
	end
	
	-- Check if sender has enough currency
	if (fromProfile[currency] or 0) < amount then
		return false, "Insufficient " .. currency
	end
	
	-- Process donation
	fromProfile[currency] = fromProfile[currency] - math.floor(amount)
	toProfile[currency] = (toProfile[currency] or 0) + math.floor(amount)
	
	-- Record donation
	local donationRecord = {
		from = fromUserId,
		to = toUserId,
		amount = math.floor(amount),
		currency = currency,
		timestamp = tick(),
	}
	
	table.insert(donations, donationRecord)
	
	-- Save record
	local donationKey = "donations_" .. toUserId
	local donationHistory = DataStoreService:LoadPlayerData(donationDataStore, donationKey) or {}
	table.insert(donationHistory, donationRecord)
	DataStoreService:SavePlayerData(donationDataStore, donationKey, donationHistory)
	
	return true, "Donation sent successfully"
end

--[[
	GetDonationHistory
	Retrieves donation history for a player
	
	@param userId (number) - Player's UserId
	@param limit (number) - Max records to return (default: 10)
	@return table of donation records
]]
function DonationService:GetDonationHistory(userId: number, limit: number?)
	assert(userId, "userId is required")
	
	limit = limit or 10
	local donationKey = "donations_" .. userId
	local donationHistory = DataStoreService:LoadPlayerData(donationDataStore, donationKey) or {}
	
	-- Return limited results (newest first)
	local result = {}
	for i = math.max(1, #donationHistory - limit + 1), #donationHistory do
		if donationHistory[i] then
			table.insert(result, 1, donationHistory[i])
		end
	end
	
	return result
end

--[[
	GetTotalDonationsReceived
	Gets total donations received by a player
	
	@param userId (number) - Player's UserId
	@return total (number)
]]
function DonationService:GetTotalDonationsReceived(userId: number): number
	assert(userId, "userId is required")
	
	local donationKey = "donations_" .. userId
	local donationHistory = DataStoreService:LoadPlayerData(donationDataStore, donationKey) or {}
	
	local total = 0
	for _, donation in ipairs(donationHistory) do
		total = total + donation.amount
	end
	
	return total
end

--[[
	ClearDonationHistory
	Clears donation history for a player
	
	@param userId (number) - Player's UserId
	@return success (boolean)
]]
function DonationService:ClearDonationHistory(userId: number): boolean
	assert(userId, "userId is required")
	
	local donationKey = "donations_" .. userId
	return DataStoreService:RemoveKey(donationDataStore, donationKey)
end

return DonationService
