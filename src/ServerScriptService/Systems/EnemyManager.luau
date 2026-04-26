--[[
	EnemyManager.luau

	Manages enemy spawning, movement, and lifecycle. Spawns enemies from wave data,
	moves them along the waypoint path, detects when they reach the end, and reports damage
	to the Nexus. Tracks all active enemies and their health.

	Owns: all enemy instances, their health, current position, path progress, and alive status.

	@requires Constants — game-wide constants (ENEMY_SPEED_MULTIPLIER)
	@requires Types — shared type definitions (Enemy, EnemyConfig)
	@requires EnemyData — enemy configuration stats (health, speed, size)
]]

local Constants = require(game:GetService("ReplicatedStorage").Shared.Constants)
local Types = require(game:GetService("ReplicatedStorage").Shared.Types)
local EnemyData = require(game:GetService("ReplicatedStorage").Data.EnemyData)
local Debug = require(game:GetService("ServerScriptService").Modules.Debug)

local EnemyManager = {}

-- Private state
local _enemies: {Types.Enemy} = {} -- Active enemies
local _enemyCounter = 0 -- For unique IDs
local _NexusManager: any = nil -- Injected by Main.server.luau
local _movementTasks: {thread} = {} -- Movement coroutines for cleanup

--[[
	Initialize the EnemyManager. Must be called once at startup before spawning enemies.

	@param nexusManager any — reference to NexusManager module (used to report damage when enemies reach end)
	@return void
]]
function EnemyManager.Init(nexusManager: any): void
	_NexusManager = nexusManager
	_enemies = {}
	_enemyCounter = 0
end

--[[
	(Private) Called when an enemy completes the waypoint path and reaches the Nexus.
	Marks the enemy as dead, applies damage to the Nexus, and removes the enemy from tracking.

	@param enemy Types.Enemy — the enemy that reached the end
	@return void
]]
local function _onEnemyReachedEnd(enemy: Types.Enemy): void
	if not enemy.IsAlive then
		return
	end

	Debug.PrintTag("ENEMY", enemy.Id, "reached end, dealing 1 damage to Nexus")

	enemy.IsAlive = false
	_NexusManager.TakeDamage(1) -- 1 damage per enemy reaching the nexus

	-- Remove enemy
	enemy.Model:Destroy()
	table.remove(_enemies, table.find(_enemies, enemy) or -1)
end

--[[
	(Private) Animates an enemy moving from waypoint to waypoint along the path.
	Smoothly interpolates position between waypoints using Lerp. Detects path completion
	and calls _onEnemyReachedEnd when the last waypoint is reached.

	@param enemy Types.Enemy — the enemy to move
	@return void
]]
local function _moveEnemyAlongPath(enemy: Types.Enemy): void
	local mapFolder = workspace:FindFirstChild("Map")
	if not mapFolder then
		warn("workspace.Map not found")
		_onEnemyReachedEnd(enemy)
		return
	end

	local pathFolder = mapFolder:FindFirstChild("Path")
	if not pathFolder then
		warn("workspace.Map.Path not found")
		_onEnemyReachedEnd(enemy)
		return
	end

	local waypoints: {Instance} = {}

	-- Collect all waypoints
	for _, child in ipairs(pathFolder:GetChildren()) do
		if child:IsA("BasePart") and child.Name:match("^Waypoint%d+$") then
			table.insert(waypoints, child)
		end
	end

	-- Sort waypoints by number
	table.sort(waypoints, function(a, b)
		local numA = tonumber(a.Name:match("%d+"))
		local numB = tonumber(b.Name:match("%d+"))
		return numA < numB
	end)

	if #waypoints == 0 then
		warn("No waypoints found in workspace.Map.Path")
		_onEnemyReachedEnd(enemy)
		return
	end

	-- Move through each waypoint
	for _, waypoint in ipairs(waypoints) do
		if not enemy.IsAlive then
			return
		end

		local startPos = enemy.Model.Position
		local endPos = waypoint.Position
		local distance = (endPos - startPos).Magnitude
		local speed = enemy.Config.Speed * Constants.ENEMY_SPEED_MULTIPLIER
		local duration = distance / speed

		local elapsed = 0
		local timestep = 0.016 -- ~60 FPS

		while elapsed < duration and enemy.IsAlive do
			elapsed += timestep
			local t = math.min(elapsed / duration, 1)
			enemy.Model.Position = startPos:Lerp(endPos, t)
			task.wait(timestep)
		end

		-- Snap to exact position
		enemy.Model.Position = endPos
	end

	-- Reached the end
	if enemy.IsAlive then
		_onEnemyReachedEnd(enemy)
	end
end

--[[
	(Private) Creates and spawns a single enemy in the world. Creates a visual sphere Part,
	initializes the enemy data structure, adds it to tracking, and starts the movement coroutine
	along the waypoint path. Logs warnings if required map/path/waypoint structures are missing.

	@param enemyTypeId string — unique identifier for the enemy config (e.g., "goblin", "orc")
	@return void
]]
local function _spawnSingleEnemy(enemyTypeId: string): void
	_enemyCounter += 1
	local enemyId = "enemy_" .. _enemyCounter
	local config = EnemyData.GetEnemyConfig(enemyTypeId)

	if not config then
		warn("Enemy config not found:", enemyTypeId)
		return
	end

	Debug.PrintTag("ENEMY", "Spawning", enemyId, "type=" .. enemyTypeId, "health=" .. config.Health)

	-- Get first waypoint position
	local mapFolder = workspace:FindFirstChild("Map")
	if not mapFolder then
		warn("workspace.Map not found")
		return
	end

	local pathFolder = mapFolder:FindFirstChild("Path")
	if not pathFolder then
		warn("workspace.Map.Path not found")
		return
	end

	local firstWaypoint = pathFolder:FindFirstChild("Waypoint1")
	if not firstWaypoint then
		warn("Waypoint1 not found")
		return
	end

	-- Create red enemy Part
	local model = Instance.new("Part")
	model.Name = enemyId
	model.Shape = Enum.PartType.Ball
	model.Color = Color3.fromRGB(255, 0, 0)
	model.Size = Vector3.new(config.Size, config.Size, config.Size)
	model.CanCollide = false
	model.TopSurface = Enum.SurfaceType.Smooth
	model.BottomSurface = Enum.SurfaceType.Smooth
	model.Position = firstWaypoint.Position
	model.Parent = workspace

	local enemy: Types.Enemy = {
		Id = enemyId,
		Model = model,
		Config = config,
		CurrentHealth = config.Health,
		PathIndex = 0,
		IsAlive = true,
	}

	table.insert(_enemies, enemy)

	-- Start movement coroutine
	local movementThread = task.spawn(function()
		_moveEnemyAlongPath(enemy)
	end)

	table.insert(_movementTasks, movementThread)
end

--[[
	(Private) Kills an enemy. Marks as dead, removes from world, and removes from tracking.
	Called when an enemy's health drops to or below 0. Gold reward TODO pending EconomyManager integration.

	@param enemy Types.Enemy — the enemy to kill
	@return void
]]
local function _killEnemy(enemy: Types.Enemy): void
	if not enemy.IsAlive then
		return
	end

	enemy.IsAlive = false
	enemy.Model:Destroy()
	table.remove(_enemies, table.find(_enemies, enemy) or -1)

	-- TODO: award gold via EconomyManager
end

--[[
	Spawn a group of enemies of the same type with delays between spawns.
	Called by WaveManager to spawn all enemies for a wave composition.

	@param enemyTypeId string — unique identifier for the enemy config (e.g., "goblin", "orc")
	@param count number — total number of enemies to spawn in this group
	@param spawnDelay number — seconds to wait between spawning each individual enemy
	@return void
]]
function EnemyManager.SpawnEnemyGroup(enemyTypeId: string, count: number, spawnDelay: number): void
	for i = 1, count do
		task.wait(spawnDelay)
		_spawnSingleEnemy(enemyTypeId)
	end
end

--[[
	Apply damage to an enemy by ID. Reduces health and kills enemy if health <= 0.
	Called by towers, traps, and other damage sources. Safe to call with non-existent IDs (no-op).

	@param enemyId string — unique identifier of the target enemy
	@param damage number — amount of health to subtract (positive value)
	@return void
]]
function EnemyManager.DamageEnemy(enemyId: string, damage: number): void
	for _, enemy in ipairs(_enemies) do
		if enemy.Id == enemyId then
			Debug.PrintTag("ENEMY", enemyId, "took", damage, "damage (health: " .. enemy.CurrentHealth .. " -> " .. (enemy.CurrentHealth - damage) .. ")")
			enemy.CurrentHealth -= damage
			if enemy.CurrentHealth <= 0 then
				Debug.PrintTag("ENEMY", enemyId, "killed")
				_killEnemy(enemy)
			end
			return
		end
	end
end

--[[
	Get all active enemies currently in the world.
	Returns a reference to the internal enemies list (do not modify directly).

	@return {Types.Enemy} — table of all currently alive enemies
]]
function EnemyManager.GetEnemies(): {Types.Enemy}
	return _enemies
end

--[[
	Get the current number of alive enemies in the world.
	Used by WaveManager to detect when a wave is complete (count == 0).

	@return number — count of currently alive enemies
]]
function EnemyManager.GetEnemyCount(): number
	return #_enemies
end

--[[
	Stop all enemy movement and destroy all enemies. Called when restarting waves or quitting the game.
	Cancels all movement threads and removes all enemy instances from the world.

	@return void
]]
function EnemyManager.Cleanup(): void
	for _, thread in ipairs(_movementTasks) do
		task.cancel(thread)
	end

	for _, enemy in ipairs(_enemies) do
		if enemy.Model and enemy.Model.Parent then
			enemy.Model:Destroy()
		end
	end

	_enemies = {}
	_movementTasks = {}
end

return EnemyManager
