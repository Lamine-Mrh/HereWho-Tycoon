--[[
	Main.server.luau
	Server entry point. Initializes all game systems and wires them together.
	This is the root of the entire server-side game logic.
]]

local WaveManager = require(script.Parent.Systems.WaveManager)
local EnemyManager = require(script.Parent.Systems.EnemyManager)
local TowerManager = require(script.Parent.Systems.TowerManager)
local EconomyManager = require(script.Parent.Systems.EconomyManager)
local NexusManager = require(script.Parent.Systems.NexusManager)

--[[
	Initialize all systems and establish their connections.
]]
local function _initSystems(): void
	-- Order matters: systems with dependencies must be initialized after their dependencies
	NexusManager.Init()
	EnemyManager.Init(NexusManager)
	WaveManager.Init(EnemyManager)
	TowerManager.Init()
	EconomyManager.Init()

	print("[Main] All systems initialized successfully")
end

--[[
	Start the game loop.
]]
local function _startGameLoop(): void
	print("[Main] Game loop started")

	-- Connect to wave complete event
	WaveManager.OnWaveComplete(function()
		print("[Main] Wave complete - all enemies eliminated!")
	end)

	-- Wait 3 seconds then start Wave 1
	task.wait(3)
	print("[Main] Starting Wave 1...")
	WaveManager.StartNextWave()
end

-- Initialize and start
_initSystems()
_startGameLoop()

-- Make systems accessible for debugging
_G.GameSystems = {
	WaveManager = WaveManager,
	EnemyManager = EnemyManager,
	TowerManager = TowerManager,
	EconomyManager = EconomyManager,
	NexusManager = NexusManager,
}
