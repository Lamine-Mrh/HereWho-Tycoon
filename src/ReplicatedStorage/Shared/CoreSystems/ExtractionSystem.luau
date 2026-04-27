--[[
	ExtractionSystem - Safe progress extraction and reward calculation
	Manages extraction points where players can safely end runs and get permanent rewards
]]

local ExtractionSystem = {}

-- Extraction configuration
local EXTRACTION_WAVES = { 5, 10, 15, 20 }  -- Waves where extraction is available
local BASE_EXTRACTION_REWARD = 1000  -- Base money reward for extraction

--[[
	CanExtract
	Checks if extraction is available at current wave
	
	@param currentWave (number) - Current wave number
	@return can extract (boolean), next extraction wave (number)
]]
function ExtractionSystem:CanExtract(currentWave: number): (boolean, number)
	for _, wave in ipairs(EXTRACTION_WAVES) do
		if currentWave == wave then
			return true, wave
		end
	end
	
	-- Find next extraction wave
	for _, wave in ipairs(EXTRACTION_WAVES) do
		if currentWave < wave then
			return false, wave
		end
	end
	
	-- If past all waves, extraction is available
	return true, EXTRACTION_WAVES[#EXTRACTION_WAVES]
end

--[[
	CalculateExtractionReward
	Calculates monetary reward for extraction at given wave
	
	@param currentWave (number) - Current wave
	@param moneyEarned (number) - Money earned so far
	@param enemiesDefeated (number) - Enemies defeated so far
	@return extraction reward (number)
]]
function ExtractionSystem:CalculateExtractionReward(currentWave: number, moneyEarned: number, enemiesDefeated: number): number
	-- Calculate based on waves completed, enemies defeated, and money earned
	local waveBonus = (currentWave * 500)  -- 500 per wave
	local enemyBonus = (enemiesDefeated * 10)  -- 10 per enemy
	local moneyKeepPercentage = moneyEarned * 0.5  -- Keep 50% of money earned
	
	local totalReward = math.floor(waveBonus + enemyBonus + moneyKeepPercentage)
	
	return totalReward
end

--[[
	CalculateExperienceGain
	Calculates experience (run progression points) from extraction
	
	@param currentWave (number) - Current wave
	@param difficulty (number) - Difficulty multiplier (1.0+)
	@return experience points (number)
]]
function ExtractionSystem:CalculateExperienceGain(currentWave: number, difficulty: number): number
	difficulty = math.max(1.0, difficulty or 1.0)
	
	-- Base 100 XP per wave
	local baseXP = currentWave * 100
	local difficultyBonus = math.floor(baseXP * (difficulty - 1))
	
	return baseXP + difficultyBonus
end

--[[
	GetExtractionRewardBreakdown
	Detailed breakdown of extraction rewards
	
	@param currentWave (number)
	@param moneyEarned (number)
	@param enemiesDefeated (number)
	@param runDifficulty (number)
	@return table with reward breakdown
]]
function ExtractionSystem:GetExtractionRewardBreakdown(currentWave: number, moneyEarned: number, enemiesDefeated: number, runDifficulty: number)
	local waveBonus = currentWave * 500
	local enemyBonus = enemiesDefeated * 10
	local moneyKeep = math.floor(moneyEarned * 0.5)
	local totalMoney = waveBonus + enemyBonus + moneyKeep
	
	local experience = self:CalculateExperienceGain(currentWave, runDifficulty)
	
	return {
		waveBonus = waveBonus,
		enemyBonus = enemyBonus,
		moneyKept = moneyKeep,
		totalMoney = totalMoney,
		experience = experience,
		progressionTier = self:GetProgressionTier(currentWave),
	}
end

--[[
	GetProgressionTier
	Determines progression tier based on wave reached
	
	@param currentWave (number) - Current wave
	@return tier name (string), tier level (number)
]]
function ExtractionSystem:GetProgressionTier(currentWave: number): (string, number)
	if currentWave < 5 then
		return "Initiate", 1
	elseif currentWave < 10 then
		return "Survivor", 2
	elseif currentWave < 15 then
		return "Veteran", 3
	elseif currentWave < 20 then
		return "Champion", 4
	else
		return "Legend", 5
	end
end

--[[
	GetNextExtractionWave
	Returns the next wave where extraction is available
	
	@param currentWave (number) - Current wave
	@return next extraction wave (number)
]]
function ExtractionSystem:GetNextExtractionWave(currentWave: number): number
	for _, wave in ipairs(EXTRACTION_WAVES) do
		if currentWave < wave then
			return wave
		end
	end
	return currentWave + 5
end

--[[
	GetAllExtractionWaves
	Returns all waves where extraction is available
	
	@return table of extraction waves
]]
function ExtractionSystem:GetAllExtractionWaves()
	return EXTRACTION_WAVES
end

--[[
	ExtractRun
	Finalizes extraction and returns session rewards
	
	@param currentWave (number)
	@param sessionStats (table) - Stats from current run
	@param runDifficulty (number)
	@return extraction data with all rewards
]]
function ExtractionSystem:ExtractRun(currentWave: number, sessionStats: {[any]: any}, runDifficulty: number)
	local rewards = self:GetExtractionRewardBreakdown(
		currentWave,
		sessionStats.moneyEarned or 0,
		sessionStats.enemiesDefeated or 0,
		runDifficulty
	)
	
	rewards.extractedAt = tick()
	rewards.currentWave = currentWave
	
	print("[ExtractionSystem] Run extracted at wave " .. currentWave .. " with " .. rewards.totalMoney .. " reward")
	
	return rewards
end

return ExtractionSystem
