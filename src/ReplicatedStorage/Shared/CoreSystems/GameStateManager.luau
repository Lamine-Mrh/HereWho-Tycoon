--[[
	GameStateManager - Manages overall game state and flow
	Handles start, pause, lose, win conditions
]]

local GameStateManager = {}
local RunService = game:GetService("RunService")

if not RunService:IsServer() then
	error("GameStateManager can only be used on the server!")
end

-- Game state constants
GameStateManager.States = {
	MENU = "MENU",
	RUNNING = "RUNNING",
	PAUSED = "PAUSED",
	WAVE_COMPLETE = "WAVE_COMPLETE",
	GAME_OVER = "GAME_OVER",
	BASE_DESTROYED = "BASE_DESTROYED",
}

-- Game state storage per player
local gameStates = {}

--[[
	InitializeGameState
	Sets up game state for a player
	
	@param player - Player object
	@param profile (table) - Player profile
]]
function GameStateManager:InitializeGameState(player, profile)
	gameStates[player.UserId] = {
		state = self.States.MENU,
		baseHealth = 100,
		maxBaseHealth = 100,
		defensesActive = true,
		currentWave = 0,
		currentRound = 1,
		towersPlaced = 0,
		maxTowers = 3,
		mana = 100,
		maxMana = 100,
		gameStartTime = nil,
		sessionStats = {
			moneyEarned = 0,
			enemiesDefeated = 0,
			wavesCompleted = 0,
			towersPlaced = 0,
		},
	}
end

--[[
	GetGameState
	Returns current game state for player
	
	@param player - Player object or UserId
	@return game state
]]
function GameStateManager:GetGameState(player)
	local userId = if typeof(player) == "Instance" then player.UserId else player
	return gameStates[userId]
end

--[[
	SetGameState
	Changes game state
	
	@param player - Player object or UserId
	@param newState (string) - New state
]]
function GameStateManager:SetGameState(player, newState: string)
	local userId = if typeof(player) == "Instance" then player.UserId else player
	local state = gameStates[userId]
	
	if not state then
		warn("Game state not initialized for UserId:", userId)
		return
	end
	
	state.state = newState
	print("[GameState] Player " .. userId .. " state changed to: " .. newState)
end

--[[
	StartGame
	Begins the game session
	
	@param player - Player object or UserId
]]
function GameStateManager:StartGame(player)
	local userId = if typeof(player) == "Instance" then player.UserId else player
	local state = gameStates[userId]
	
	if not state then
		warn("Game state not initialized")
		return
	end
	
	state.state = self.States.RUNNING
	state.gameStartTime = tick()
	state.sessionStats = {
		moneyEarned = 0,
		enemiesDefeated = 0,
		wavesCompleted = 0,
		towersPlaced = 0,
	}
end

--[[
	PauseGame
	Pauses game for player
	
	@param player - Player object or UserId
]]
function GameStateManager:PauseGame(player)
	local userId = if typeof(player) == "Instance" then player.UserId else player
	local state = gameStates[userId]
	
	if state and state.state == self.States.RUNNING then
		state.state = self.States.PAUSED
	end
end

--[[
	ResumeGame
	Resumes paused game
	
	@param player - Player object or UserId
]]
function GameStateManager:ResumeGame(player)
	local userId = if typeof(player) == "Instance" then player.UserId else player
	local state = gameStates[userId]
	
	if state and state.state == self.States.PAUSED then
		state.state = self.States.RUNNING
	end
end

--[[
	DamageBase
	Damages player's base
	
	@param player - Player object or UserId
	@param damage (number) - Damage amount
	@return baseHealth (number)
]]
function GameStateManager:DamageBase(player, damage: number)
	local userId = if typeof(player) == "Instance" then player.UserId else player
	local state = gameStates[userId]
	
	if not state then
		return 0
	end
	
	state.baseHealth = math.max(0, state.baseHealth - damage)
	
	if state.baseHealth <= 0 then
		self:GameOver(player, "BASE_DESTROYED")
	end
	
	return state.baseHealth
end

--[[
	HealBase
	Heals player's base
	
	@param player - Player object or UserId
	@param healing (number) - Healing amount
	@return baseHealth (number)
]]
function GameStateManager:HealBase(player, healing: number)
	local userId = if typeof(player) == "Instance" then player.UserId else player
	local state = gameStates[userId]
	
	if not state then
		return 0
	end
	
	state.baseHealth = math.min(state.maxBaseHealth, state.baseHealth + healing)
	return state.baseHealth
end

--[[
	GameOver
	Ends game for player
	
	@param player - Player object or UserId
	@param reason (string) - Reason for game over
	@return session stats
]]
function GameStateManager:GameOver(player, reason: string)
	local userId = if typeof(player) == "Instance" then player.UserId else player
	local state = gameStates[userId]
	
	if not state then
		return nil
	end
	
	state.state = self.States.GAME_OVER
	state.gameOverReason = reason
	
	local sessionLength = (tick() - (state.gameStartTime or tick()))
	
	local stats = {
		reason = reason,
		sessionLength = sessionLength,
		moneyEarned = state.sessionStats.moneyEarned,
		enemiesDefeated = state.sessionStats.enemiesDefeated,
		wavesCompleted = state.sessionStats.wavesCompleted,
		towersPlaced = state.sessionStats.towersPlaced,
	}
	
	print("[GameState] Game Over for " .. userId .. " - Reason: " .. reason)
	
	return stats
end

--[[
	AddToSessionStats
	Adds data to session statistics
	
	@param player - Player object or UserId
	@param statKey (string) - Stat to increment
	@param amount (number) - Amount to add
]]
function GameStateManager:AddToSessionStats(player, statKey: string, amount: number)
	local userId = if typeof(player) == "Instance" then player.UserId else player
	local state = gameStates[userId]
	
	if state and state.sessionStats[statKey] then
		state.sessionStats[statKey] = state.sessionStats[statKey] + amount
	end
end

--[[
	CanPlaceTower
	Checks if player can place more towers
	
	@param player - Player object or UserId
	@return can place (boolean)
]]
function GameStateManager:CanPlaceTower(player): boolean
	local userId = if typeof(player) == "Instance" then player.UserId else player
	local state = gameStates[userId]
	
	if not state then
		return false
	end
	
	return state.towersPlaced < state.maxTowers
end

return GameStateManager
