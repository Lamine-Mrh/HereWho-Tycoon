--[[
	WaveHandler - Manages wave spawning and progression
	Coordinates with enemy system and game state
]]

local SharedServices = require(game.ReplicatedStorage.Shared.SharedServices)

-- Configuration
local SPAWN_INTERVAL = 2 -- Time between enemy spawns in seconds
local WAVE_COMPLETION_WAIT = 5 -- Wait after wave completes before allowing next

-- Store wave data per server (simplified for single-server demo)
local gameData = {
	waveInProgress = false,
	enemiesInWave = {},
}

--[[
	StartWave
	Begins spawning enemies for current wave
	
	@param waveNumber (number) - Wave number to spawn
]]
local function startWave(waveNumber: number)
	if gameData.waveInProgress then
		warn("[WaveHandler] Wave already in progress!")
		return
	end
	
	gameData.waveInProgress = true
	
	print("[WaveHandler] Starting wave", waveNumber)
	
	-- Get enemies for this wave from EnemySystem
	local enemies = SharedServices.Enemy:GenerateWaveEnemies(waveNumber)
	gameData.enemiesInWave = enemies
	
	-- Spawn enemies with staggered intervals
	task.spawn(function()
		for i, enemy in ipairs(enemies) do
			task.wait(enemy.spawnTime or (i * SPAWN_INTERVAL))
			
			-- Notify game that enemy spawned
			SharedServices.Wave:OnEnemySpawned()
			
			print("[WaveHandler] Spawned enemy: " .. enemy.name .. " (HP: " .. enemy.health .. ")")
			-- TODO: Create visual enemy in game world
		end
		
		-- All enemies spawned, wait for completion
		print("[WaveHandler] All wave enemies spawned. Waiting for completion...")
	end)
end

--[[
	CompleteWave
	Ends the current wave
	
	@return completion data
]]
local function completeWave()
	gameData.waveInProgress = false
	
	-- End wave through WaveSystem
	local result = SharedServices.Wave:EndWave()
	
	print("[WaveHandler] Wave completed! Reward: $" .. (result.totalReward or 0))
	
	return result
end

--[[
	SkipWave
	Allows player to skip current wave
]]
local function skipWave()
	if not gameData.waveInProgress then
		return false
	end
	
	SharedServices.Wave:SkipWave()
	gameData.waveInProgress = false
	gameData.enemiesInWave = {}
	
	return true
end

-- Expose functions for remote calls
_G.WaveHandler = {
	StartWave = startWave,
	CompleteWave = completeWave,
	SkipWave = skipWave,
}

print("[WaveHandler] Wave handler loaded and ready!")
