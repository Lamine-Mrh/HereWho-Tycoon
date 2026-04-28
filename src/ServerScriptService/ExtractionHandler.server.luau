--[[
	ExtractionHandler.server.luau - Manages extraction mechanic and run transitions
	Orchestrates progression between runs with extraction system
]]

local game = game
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Get shared services
local SharedServices = require(game:GetService("ServerScriptService"):WaitForChild("SharedServices"))
local Extraction = SharedServices.Extraction
local Nexus = SharedServices.Nexus
local RunProgression = SharedServices.RunProgression
local PermanentUpgrades = SharedServices.PermanentUpgrades
local GameState = SharedServices.GameState
local Profile = SharedServices.Profile
local Wave = SharedServices.Wave

-- Signal for extraction readiness
local ExtractionReadySignal = Instance.new("RemoteEvent")
ExtractionReadySignal.Name = "ExtractionReady"
ExtractionReadySignal.Parent = game:GetService("ReplicatedStorage"):WaitForChild("Shared")

-- Signal for extraction request
local ExtractionRequestSignal = Instance.new("RemoteEvent")
ExtractionRequestSignal.Name = "ExtractionRequest"
ExtractionRequestSignal.Parent = game:GetService("ReplicatedStorage"):WaitForChild("Shared")

-- Signal for run restart
local RunRestartSignal = Instance.new("RemoteEvent")
RunRestartSignal.Name = "RunRestart"
RunRestartSignal.Parent = game:GetService("ReplicatedStorage"):WaitForChild("Shared")

--[[
	CheckExtractionAvailable
	Checks if extraction is available and notifies clients
]]
local function CheckExtractionAvailable()
	for _, player in pairs(Players:GetPlayers()) do
		local userId = player.UserId
		local profile = Profile:GetProfile(userId)
		local gameState = GameState:GetGameState(userId)
		
		if profile and gameState and gameState.state == GameState.States.RUNNING then
			local currentWave = gameState.currentWave or 0
			local canExtract, nextWave = Extraction:CanExtract(currentWave)
			
			if canExtract then
				ExtractionReadySignal:FireClient(player, {
					canExtract = true,
					currentWave = currentWave,
					nextWave = nextWave,
				})
			end
		end
	end
end

--[[
	HandleExtraction
	Processes player extraction and saves progress
]]
local function HandleExtraction(player, extractData)
	local userId = player.UserId
	local profile = Profile:GetProfile(userId)
	local gameState = GameState:GetGameState(userId)
	
	if not profile or not gameState then
		return
	end
	
	local currentWave = gameState.currentWave or 0
	local runDifficulty = RunProgression:GetDifficultyMultiplier(profile)
	
	-- Calculate extraction rewards
	local extractionRewards = Extraction:ExtractRun(
		currentWave,
		gameState.sessionStats or {},
		runDifficulty
	)
	
	-- Apply monetary reward
	profile.Money = (profile.Money or 0) + extractionRewards.totalMoney
	
	-- Record in progression
	RunProgression:AddRunCompletion(profile, true, currentWave, extractionRewards)
	
	-- Check for tier up
	local tierUp, newTier = RunProgression:CheckTierUp(profile)
	if tierUp then
		print("[ExtractionHandler] Player " .. userId .. " reached tier " .. newTier)
	end
	
	-- Reset for next run
	RestartRun(player, profile, true)
	
	-- Notify client of extraction success
	RunRestartSignal:FireClient(player, {
		type = "extraction",
		rewards = extractionRewards,
		tierUp = tierUp,
		newTier = newTier,
	})
	
	print("[ExtractionHandler] Player " .. userId .. " extracted at wave " .. currentWave)
end

--[[
	HandleNexusDestruction
	Processes nexus destruction and run failure
]]
local function HandleNexusDestruction(player)
	local userId = player.UserId
	local profile = Profile:GetProfile(userId)
	local gameState = GameState:GetGameState(userId)
	
	if not profile or not gameState then
		return
	end
	
	local currentWave = gameState.currentWave or 0
	
	-- Record loss in progression
	RunProgression:AddRunCompletion(profile, false, currentWave, {})
	
	-- No rewards for loss, but still advance run count
	-- This is important for difficulty scaling
	
	-- Reset for next run
	RestartRun(player, profile, false)
	
	-- Notify client of loss
	RunRestartSignal:FireClient(player, {
		type = "loss",
		waveReached = currentWave,
		message = "Your Nexus was destroyed!",
	})
	
	print("[ExtractionHandler] Player " .. userId .. " lost nexus at wave " .. currentWave)
end

--[[
	RestartRun
	Resets game state for next run with permanent upgrades applied
]]
function RestartRun(player, profile, fromExtraction)
	local userId = player.UserId
	
	-- Reset nexus to full health
	Nexus:ResetNexus(userId)
	
	-- Initialize nexus with permanent upgrade bonuses
	local baseHealth = 100
	local healthBonus = PermanentUpgrades:GetNexusHealthBonus(profile)
	local maxNexusHealth = baseHealth + healthBonus
	
	Nexus:InitializeNexus(userId, maxNexusHealth)
	
	-- Reset game state
	GameState:SetGameState(userId, GameState.States.MENU)
	gameState = GameState:GetGameState(userId)
	
	-- Apply permanent upgrade bonuses to game state
	gameState.maxTowers = 3 + PermanentUpgrades:GetExtraSlots(profile)
	gameState.maxMana = 100 + PermanentUpgrades:GetManaBonus(profile)
	gameState.mana = gameState.maxMana
	
	-- Clear session stats
	gameState.sessionStats = {
		moneyEarned = 0,
		enemiesDefeated = 0,
		wavesCompleted = 0,
		towersPlaced = 0,
	}
	
	-- Get difficulty multiplier for this run
	local difficultyMultiplier = RunProgression:GetDifficultyMultiplier(profile)
	gameState.difficultyMultiplier = difficultyMultiplier
	
	print("[ExtractionHandler] Run reset for player " .. userId .. " - Difficulty: " .. string.format("%.1f", difficultyMultiplier))
end

--[[
	Initialize - Setup listeners
]]
local function Initialize()
	print("[ExtractionHandler] Starting...")
	
	-- Listen for extraction requests from clients
	ExtractionRequestSignal.OnServerEvent:Connect(function(player, extractData)
		HandleExtraction(player, extractData)
	end)
	
	-- Periodically check for extraction availability
	while true do
		wait(1)
		CheckExtractionAvailable()
	end
end

-- Startup
Initialize()

return {
	ExtractionReady = ExtractionReadySignal,
	ExtractionRequest = ExtractionRequestSignal,
	RunRestart = RunRestartSignal,
	HandleExtraction = HandleExtraction,
	HandleNexusDestruction = HandleNexusDestruction,
	RestartRun = RestartRun,
}
