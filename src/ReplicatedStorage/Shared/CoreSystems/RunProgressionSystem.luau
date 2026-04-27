--[[
	RunProgressionSystem - Between-run progression and run-based levels
	Tracks player progression across runs with levels/tiers that unlock content
]]

local RunProgressionSystem = {}

-- Run progression tiers
local RUN_TIERS = {
	{ tier = 1, name = "Novice", runsCost = 0, rewardsUnlock = { "basic_missions" } },
	{ tier = 2, name = "Apprentice", runsCost = 5, rewardsUnlock = { "tier2_towers" } },
	{ tier = 3, name = "Adept", runsCost = 15, rewardsUnlock = { "advanced_generators" } },
	{ tier = 4, name = "Master", runsCost = 35, rewardsUnlock = { "rare_gacha", "challenge_modes" } },
	{ tier = 5, name = "Grandmaster", runsCost = 75, rewardsUnlock = { "ultimate_content" } },
	{ tier = 6, name = "Legend", runsCost = 150, rewardsUnlock = { "legendary_events" } },
}

--[[
	InitializeRunProgression
	Sets up run progression for a player
	
	@param player - Player object or UserId
]]
function RunProgressionSystem:InitializeRunProgression(player)
	local userId = if typeof(player) == "Instance" then player.UserId else player
	
	-- This would be called when initializing profile
	-- Just returns the initial state structure
	return {
		totalRuns = 0,
		totalExtraction = 0,  -- Times player has extracted
		totalLoss = 0,  -- Times nexus was broken
		currentRunCount = 0,
		currentTier = 1,
		experiencePoints = 0,
		unlockedContent = { "basic_missions" },
	}
end

--[[
	GetCurrentTier
	Gets player's current run tier
	
	@param profile (table) - Player profile
	@return tier number (1-6)
]]
function RunProgressionSystem:GetCurrentTier(profile: {[any]: any}): number
	if not profile.RunProgression then
		return 1
	end
	
	return profile.RunProgression.currentTier or 1
end

--[[
	GetRunProgress
	Gets how close player is to next tier
	
	@param profile (table) - Player profile
	@return current runs completed, runs needed for next tier, percentage
]]
function RunProgressionSystem:GetRunProgress(profile: {[any]: any})
	local currentTier = self:GetCurrentTier(profile)
	local totalRuns = (profile.RunProgression and profile.RunProgression.totalRuns) or 0
	
	if currentTier >= #RUN_TIERS then
		return totalRuns, 0, 100  -- Max tier
	end
	
	local currentTierData = RUN_TIERS[currentTier]
	local nextTierData = RUN_TIERS[currentTier + 1]
	
	local runsSinceLastTier = totalRuns - currentTierData.runsCost
	local runsNeeded = nextTierData.runsCost - currentTierData.runsCost
	local percentage = math.floor((runsSinceLastTier / runsNeeded) * 100)
	
	return totalRuns, runsNeeded, percentage
end

--[[
	AddRunCompletion
	Records a completed run
	
	@param profile (table) - Player profile
	@param wasExtracted (boolean) - Whether player extracted or lost
	@param waveReached (number) - Highest wave reached
	@param sessionRewards (table) - Session rewards
]]
function RunProgressionSystem:AddRunCompletion(profile: {[any]: any}, wasExtracted: boolean, waveReached: number, sessionRewards: {[any]: any})
	if not profile.RunProgression then
		profile.RunProgression = self:InitializeRunProgression(profile)
	end
	
	local prog = profile.RunProgression
	prog.totalRuns = (prog.totalRuns or 0) + 1
	prog.currentRunCount = (prog.currentRunCount or 0) + 1
	
	if wasExtracted then
		prog.totalExtraction = (prog.totalExtraction or 0) + 1
		prog.experiencePoints = (prog.experiencePoints or 0) + (sessionRewards.experience or 0)
	else
		prog.totalLoss = (prog.totalLoss or 0) + 1
	end
	
	-- Check for tier up
	self:CheckTierUp(profile)
end

--[[
	CheckTierUp
	Checks if player has reached next tier
	
	@param profile (table) - Player profile
	@return tier up (boolean), new tier (number)
]]
function RunProgressionSystem:CheckTierUp(profile: {[any]: any})
	if not profile.RunProgression then
		return false, 1
	end
	
	local totalRuns = profile.RunProgression.totalRuns or 0
	local currentTier = profile.RunProgression.currentTier or 1
	
	-- Find appropriate tier
	for tier = #RUN_TIERS, 1, -1 do
		if totalRuns >= RUN_TIERS[tier].runsCost then
			if tier > currentTier then
				profile.RunProgression.currentTier = tier
				self:UnlockContentForTier(profile, tier)
				print("[RunProgression] Player tier up to " .. RUN_TIERS[tier].name .. "!")
				return true, tier
			end
			break
		end
	end
	
	return false, currentTier
end

--[[
	UnlockContentForTier
	Unlocks content for a tier
	
	@param profile (table) - Player profile
	@param tier (number) - Tier number
]]
function RunProgressionSystem:UnlockContentForTier(profile: {[any]: any}, tier: number)
	if not profile.RunProgression then
		profile.RunProgression = self:InitializeRunProgression(profile)
	end
	
	local tierData = RUN_TIERS[tier]
	if not tierData then
		return
	end
	
	if not profile.RunProgression.unlockedContent then
		profile.RunProgression.unlockedContent = {}
	end
	
	for _, content in ipairs(tierData.rewardsUnlock) do
		table.insert(profile.RunProgression.unlockedContent, content)
	end
end

--[[
	IsContentUnlocked
	Checks if player has unlocked specific content
	
	@param profile (table) - Player profile
	@param contentId (string) - Content identifier
	@return is unlocked (boolean)
]]
function RunProgressionSystem:IsContentUnlocked(profile: {[any]: any}, contentId: string): boolean
	if not profile.RunProgression or not profile.RunProgression.unlockedContent then
		return contentId == "basic_missions"
	end
	
	for _, content in ipairs(profile.RunProgression.unlockedContent) do
		if content == contentId then
			return true
		end
	end
	
	return false
end

--[[
	GetTierInfo
	Gets information about a specific tier
	
	@param tier (number) - Tier number (1-6)
	@return tier data table
]]
function RunProgressionSystem:GetTierInfo(tier: number)
	if tier < 1 or tier > #RUN_TIERS then
		return nil
	end
	
	return RUN_TIERS[tier]
end

--[[
	GetAllTiers
	Returns all tier information
	
	@return table of all tiers
]]
function RunProgressionSystem:GetAllTiers()
	return RUN_TIERS
end

--[[
	GetDifficultyMultiplier
	Gets difficulty multiplier based on run tier
	This makes later runs progressively harder
	
	@param profile (table) - Player profile
	@return difficulty multiplier (1.0+)
]]
function RunProgressionSystem:GetDifficultyMultiplier(profile: {[any]: any}): number
	local tier = self:GetCurrentTier(profile)
	-- Each tier increases difficulty by 15%
	return 1.0 + ((tier - 1) * 0.15)
end

--[[
	GetProgressionStats
	Gets full progression statistics for player
	
	@param profile (table) - Player profile
	@return stats table
]]
function RunProgressionSystem:GetProgressionStats(profile: {[any]: any})
	if not profile.RunProgression then
		return {
			totalRuns = 0,
			totalExtractions = 0,
			totalLosses = 0,
			tier = 1,
			tierName = "Novice",
			experiencePoints = 0,
			unlockedCount = 1,
		}
	end
	
	local prog = profile.RunProgression
	local tierData = RUN_TIERS[prog.currentTier]
	
	return {
		totalRuns = prog.totalRuns or 0,
		totalExtractions = prog.totalExtraction or 0,
		totalLosses = prog.totalLoss or 0,
		tier = prog.currentTier or 1,
		tierName = tierData.name,
		experiencePoints = prog.experiencePoints or 0,
		unlockedCount = #(prog.unlockedContent or { "basic_missions" }),
	}
end

return RunProgressionSystem
