--[[
	WaveManager.luau
	Manages wave progression, timing, and triggering.
	Owns: current wave number, wave start/end state.
	Tells EnemyManager to spawn enemies for each wave.
]]

local Constants = require(game:GetService("ReplicatedStorage").Shared.Constants)
local Types = require(game:GetService("ReplicatedStorage").Shared.Types)
local WaveData = require(game:GetService("ReplicatedStorage").Data.WaveData)
local Debug = require(game:GetService("ServerScriptService").Modules.Debug)

local WaveManager = {}

-- Private state
local _currentWave = 0
local _isWaveActive = false
local _EnemyManager: any = nil -- Injected by Main.server.luau
local _waveCompleteEvent = Instance.new("BindableEvent")

--[[
	Initialize WaveManager with a reference to EnemyManager.
	@param enemyManager — the EnemyManager module instance
]]
function WaveManager.Init(enemyManager: any): void
	_EnemyManager = enemyManager
	_currentWave = 0
	_isWaveActive = false
end

--[[
	(Private) Monitor wave completion by checking enemy count.
	Polls every 0.1 seconds until all enemies are defeated, then fires the wave complete event.

	@return void
]]
local function _monitorWaveCompletion(): void
	while _isWaveActive do
		task.wait(0.1)
		if _EnemyManager.GetEnemyCount() == 0 then
			_isWaveActive = false
			Debug.PrintTag("WAVE", "Wave", _currentWave, "complete - all enemies defeated")
			_waveCompleteEvent:Fire()
			break
		end
	end
end

--[[
	Start the next wave. Tells EnemyManager to spawn enemies from wave data.
	Each wave composition spawns with configured delays between enemies.

	@return void
]]
function WaveManager.StartNextWave(): void
	_currentWave += 1
	local wave = WaveData.GetWave(_currentWave)

	if not wave then
		-- No more waves defined
		return
	end

	_isWaveActive = true
	Debug.PrintTag("WAVE", "Wave", _currentWave, "starting - spawning", #wave.Enemies, "enemy groups")

	-- Spawn all enemy groups for this wave
	for _, composition in ipairs(wave.Enemies) do
		_EnemyManager.SpawnEnemyGroup(composition.EnemyId, composition.Count, composition.SpawnDelay)
	end

	-- Monitor wave completion
	task.spawn(function()
		_monitorWaveCompletion()
	end)
end

--[[
	End the current wave. Called when all enemies are dead.
	@return void
]]
function WaveManager.EndWave(): void
	_isWaveActive = false
end

--[[
	Connect to wave complete event.
	@param callback function — called when wave ends
	@return RBXScriptConnection
]]
function WaveManager.OnWaveComplete(callback: (any) -> ()): any
	return _waveCompleteEvent.Event:Connect(callback)
end

--[[
	Get the current wave number.
	@return number
]]
function WaveManager.GetCurrentWave(): number
	return _currentWave
end

--[[
	Check if a wave is currently active.
	@return boolean
]]
function WaveManager.IsWaveActive(): boolean
	return _isWaveActive
end

return WaveManager
