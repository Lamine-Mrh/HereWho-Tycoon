--[[
	PROGRESSION_IMPLEMENTATION_CHECKLIST.luau
	Step-by-step guide to integrate progression systems into existing codebase
]]

--[[
================================================================================
QUICK START: PROGRESSION INTEGRATION
================================================================================

The progression systems are now complete and ready to integrate.
Follow this checklist to connect them to your existing game logic.

================================================================================
STEP 1: SERVER INITIALIZATION (GameInitializer.server.luau)
================================================================================

ADD THIS CODE after SharedServices loads:

-- Initialize Nexus for player
local Nexus = SharedServices.Nexus
local RunProgression = SharedServices.RunProgression
local PermanentUpgrades = SharedServices.PermanentUpgrades

Players.PlayerAdded:Connect(function(player)
	local profile = Profile:GetProfile(player.UserId)
	
	-- Initialize run progression if not exists
	if not profile.RunProgression then
		profile.RunProgression = RunProgression:InitializeRunProgression(player)
	end
	
	-- Initialize permanent upgrades table if not exists
	if not profile.PermanentUpgrades then
		profile.PermanentUpgrades = {}
	end
	
	-- When player starts a run, initialize nexus
	-- (See Step 3 for when to do this)
end)

================================================================================
STEP 2: GAME STATE UPDATES (GameStateManager modifications)
================================================================================

UPDATE InitializeGameState to include difficulty:

function GameStateManager:InitializeGameState(player, profile)
	local RunProgression = require(script.Parent.Parent.RunProgression)
	
	gameStates[player.UserId] = {
		state = self.States.MENU,
		baseHealth = 100,
		maxBaseHealth = 100,
		-- ... existing fields ...
		
		-- NEW: Add difficulty multiplier
		difficultyMultiplier = RunProgression:GetDifficultyMultiplier(profile),
	}
end

UPDATE DamageBase to trigger nexus destruction:

function GameStateManager:DamageBase(player, damage: number)
	local userId = if typeof(player) == "Instance" then player.UserId else player
	local state = gameStates[userId]
	
	if not state then
		return 0
	end
	
	state.baseHealth = math.max(0, state.baseHealth - damage)
	
	if state.baseHealth <= 0 then
		-- NEW: Call nexus destruction handler
		local ExtractionHandler = require(game:GetService("ServerScriptService"):WaitForChild("ExtractionHandler"))
		ExtractionHandler.HandleNexusDestruction(player)
		
		self:GameOver(player, "BASE_DESTROYED")
	end
	
	return state.baseHealth
end

================================================================================
STEP 3: STARTING A RUN (WaveHandler or new StartRunHandler)
================================================================================

When player clicks "Start Game", initialize progression systems:

local Nexus = SharedServices.Nexus
local RunProgression = SharedServices.RunProgression
local PermanentUpgrades = SharedServices.PermanentUpgrades
local GameState = SharedServices.GameState

function StartNewRun(player)
	local userId = player.UserId
	local profile = Profile:GetProfile(userId)
	local gameState = GameState:GetGameState(userId)
	
	if not profile or not gameState then
		return
	end
	
	-- Calculate difficulty for this run
	local difficultyMultiplier = RunProgression:GetDifficultyMultiplier(profile)
	gameState.difficultyMultiplier = difficultyMultiplier
	
	-- Initialize nexus with permanent upgrade bonuses
	local baseHealth = 100
	local healthBonus = PermanentUpgrades:GetNexusHealthBonus(profile)
	local maxNexusHealth = baseHealth + healthBonus
	
	Nexus:InitializeNexus(userId, maxNexusHealth)
	
	-- Update max towers and mana with bonuses
	gameState.maxTowers = 3 + PermanentUpgrades:GetExtraSlots(profile)
	gameState.maxMana = 100 + PermanentUpgrades:GetManaBonus(profile)
	gameState.mana = gameState.maxMana
	
	-- Reset stats
	gameState.sessionStats = {
		moneyEarned = 0,
		enemiesDefeated = 0,
		wavesCompleted = 0,
		towersPlaced = 0,
	}
	
	GameState:StartGame(player)
	
	print("[StartRun] Started for " .. userId .. " with difficulty " .. string.format("%.2f", difficultyMultiplier) .. "x")
end

================================================================================
STEP 4: WAVE COMPLETION CHECK (WaveHandler modifications)
================================================================================

After each wave completes, check if extraction is available:

local Extraction = SharedServices.Extraction
local ExtractionReadySignal = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("ExtractionReady")

function OnWaveComplete(player, waveNumber)
	-- ... existing wave completion logic ...
	
	-- NEW: Check if extraction is available
	local canExtract, nextWave = Extraction:CanExtract(waveNumber)
	
	if canExtract then
		ExtractionReadySignal:FireClient(player, {
			canExtract = true,
			currentWave = waveNumber,
			nextWave = nextWave,
		})
	end
end

================================================================================
STEP 5: HANDLE EXTRACTION REQUEST (Listening in a handler)
================================================================================

Add this to ExtractionHandler or appropriate listener:

local ExtractionRequestSignal = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("ExtractionRequest")

ExtractionRequestSignal.OnServerEvent:Connect(function(player, extractData)
	local ExtractionHandler = require(game:GetService("ServerScriptService"):WaitForChild("ExtractionHandler"))
	ExtractionHandler.HandleExtraction(player, extractData)
end)

================================================================================
STEP 6: APPLY SCALING TO ENEMIES (EnemySystem modifications)
================================================================================

When generating wave enemies, apply difficulty multiplier:

function WaveHandler:StartWave(waveNumber)
	local gameState = GameState:GetGameState(player)
	local difficultyMultiplier = gameState.difficultyMultiplier or 1.0
	
	-- Generate enemies
	local baseEnemies = Enemy:GenerateWaveEnemies(waveNumber)
	
	-- Apply difficulty scaling to health
	for _, enemy in ipairs(baseEnemies) do
		enemy.health = math.floor(enemy.health * difficultyMultiplier)
		enemy.reward = math.floor(enemy.reward * difficultyMultiplier)
	end
	
	-- ... spawn enemies ...
end

================================================================================
STEP 7: APPLY BONUSES TO GENERATORS (IncomeSystem modifications)
================================================================================

When calculating generator income:

function IncomeHandler:OnIncomeLoop(player)
	local profile = Profile:GetProfile(player.UserId)
	local Income = SharedServices.Income
	local PermanentUpgrades = SharedServices.PermanentUpgrades
	
	-- Calculate base income
	local baseIncome = Income:CalculateGeneratorIncome(profile.Generators)
	
	-- Apply permanent upgrade multiplier
	local upgradeMultiplier = PermanentUpgrades:GetGeneratorMultiplier(profile)
	local finalIncome = baseIncome * upgradeMultiplier
	
	Income:ApplyIncome(profile, finalIncome, 1)  -- 1 second
end

================================================================================
STEP 8: APPLY BONUSES TO GACHA (GachaSystem modifications)
================================================================================

When rolling for rarity:

function GachaSystem:RollOnce(profile)
	local rand = math.random()
	local baseBonusRate = require(script.Parent.Parent.PermanentUpgrades):GetGachaBonusRate(profile)
	
	-- Adjust Mythic rate by bonus
	local adjustedRate = math.min(0.10, RARITIES.Mythic.rate + baseBonusRate)
	
	-- ... rest of rolling logic ...
end

================================================================================
STEP 9: CLIENT-SIDE EXTRACTION UI
================================================================================

Create a client LocalScript that listens for extraction:

local ExtractionReadySignal = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("ExtractionReady")
local ExtractionRequestSignal = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("ExtractionRequest")
local RunRestartSignal = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("RunRestart")

ExtractionReadySignal.OnClientEvent:Connect(function(data)
	if data.canExtract then
		-- Show extraction UI
		print("Extraction available at wave " .. data.currentWave)
		
		-- Show buttons: EXTRACT or CONTINUE
		-- On Extract button:
		ExtractionRequestSignal:FireServer({})
	end
end)

RunRestartSignal.OnClientEvent:Connect(function(data)
	if data.type == "extraction" then
		-- Show rewards
		print("Extracted! Got $" .. data.rewards.totalMoney)
		
		if data.tierUp then
			print("Tier up to " .. data.newTier .. "!")
		end
	elseif data.type == "loss" then
		-- Show loss screen
		print("Nexus destroyed at wave " .. data.waveReached)
	end
	
	-- Reset UI for next run
	-- Auto-start next run or show menu
end)

================================================================================
STEP 10: PERMANENT UPGRADES SHOP
================================================================================

Create shop UI that allows purchasing permanent upgrades:

local PermanentUpgrades = SharedServices.PermanentUpgrades
local profile = ProfileService:GetProfile(userId)

-- Display all upgrades
local allUpgrades = PermanentUpgrades:GetAllUpgrades()
local currentProgress = PermanentUpgrades:GetUpgradeProgress(profile)

-- For each category
for category, tiers in pairs(allUpgrades) do
	for level, data in ipairs(tiers) do
		local purchased = currentProgress[category] >= level
		local canAfford = not purchased and PermanentUpgrades:CanAffordUpgrade(profile, category, level)
		
		-- Display upgrade card
		-- On purchase button:
		local success, message = PermanentUpgrades:PurchaseUpgrade(profile, category, level)
		if success then
			print("Upgrade purchased!")
		else
			print("Cannot afford: " .. message)
		end
	end
end

================================================================================
INTEGRATION CHECKLIST
================================================================================

□ GameInitializer.server.luau
  □ Initialize RunProgression for new players
  □ Initialize PermanentUpgrades table

□ GameStateManager.luau
  □ Add difficultyMultiplier field
  □ Update InitializeGameState to calculate difficulty
  □ Update DamageBase to call HandleNexusDestruction

□ Game Start Flow (WaveHandler or new StartRunHandler)
  □ Call Nexus:InitializeNexus() with bonus health
  □ Set maxTowers and maxMana with bonuses
  □ Set gameState.difficultyMultiplier

□ WaveHandler.server.luau
  □ Check extraction availability after wave completion
  □ Fire ExtractionReadySignal to client

□ IncomeHandler.server.luau (or income loop)
  □ Apply permanent upgrade generator multiplier

□ EnemySystem.luau or WaveHandler
  □ Apply difficultyMultiplier to enemy health/rewards

□ GachaSystem.luau
  □ Apply GetGachaBonusRate() to Mythic rate

□ ExtractionHandler.server.luau
  □ Create/update ExtractionHandler.server.luau ✓ DONE

□ Client LocalScripts
  □ Listen for ExtractionReadySignal
  □ Show extraction UI
  □ Handle RunRestartSignal

□ Permanent Upgrades Shop UI
  □ Display all available upgrades
  □ Handle purchase requests

□ Documentation
  □ Add PROGRESSION_SYSTEMS_GUIDE.luau ✓ DONE
  □ Add PROGRESSION_IMPLEMENTATION_CHECKLIST.luau ✓ DONE

================================================================================
BALANCE TUNING GUIDE
================================================================================

If extraction/difficulty feels wrong, adjust these values:

EXTRACTION_WAVES (ExtractionSystem.luau):
  Currently: { 5, 10, 15, 20 }
  More waves = longer runs before extraction
  Fewer waves = more frequent extraction points

EXTRACTION REWARD FORMULAS (ExtractionSystem.luau):
  waveBonus = currentWave × 500        ← Adjust for more/less money
  moneyKeepPercentage = 0.50            ← 50% kept, adjust for hoarding
  baseXP = currentWave × 100            ← 100 per wave

DIFFICULTY SCALING (RunProgressionSystem.luau):
  difficultyPerTier = 0.15              ← 15% per tier, make 0.10 or 0.20
  
PERMANENT UPGRADE COSTS:
  Adjust the cost tables in PermanentUpgradesSystem.luau
  Make early upgrades cheaper to encourage spending
  Make late upgrades more expensive for prestige feel

RUN TIER THRESHOLDS (RunProgressionSystem.luau):
  Tier 2: 5 runs    ← Make 10 for slower progression
  Tier 3: 15 runs
  Tier 4: 35 runs   ← Make 50 for harder grind
  Tier 5: 75 runs
  Tier 6: 150 runs

================================================================================
TESTING CHECKLIST
================================================================================

□ New player progression initializes correctly
□ Extraction available at waves 5, 10, 15, 20
□ Extraction rewards calculated correctly
□ Nexus initializes with upgrade bonuses
□ Game difficulty scales with tier
□ Permanent upgrades apply effects
□ Generator multiplier working
□ Extra tower slots available
□ Gacha rates boosted
□ Nexus health bonus applied
□ Mana bonus applied
□ Run count increments on extract
□ Run count increments on loss
□ Tier up triggers at correct thresholds
□ Content unlocks on tier up
□ Extraction money added to profile
□ Loss results in 0 rewards
□ Next run starts with correct difficulty

================================================================================
COMPLETION STATUS
================================================================================

COMPLETED:
✓ NexusSystem.luau
✓ ExtractionSystem.luau
✓ PermanentUpgradesSystem.luau
✓ RunProgressionSystem.luau
✓ ExtractionHandler.server.luau
✓ SharedServices.luau updated with all systems
✓ All 8 core systems migrated to CoreSystems/
✓ PROGRESSION_SYSTEMS_GUIDE.luau
✓ PROGRESSION_IMPLEMENTATION_CHECKLIST.luau

NEXT STEPS:
1. Implement all integration checklist items
2. Create client-side extraction UI
3. Create permanent upgrades shop UI
4. Test progression flow end-to-end
5. Balance difficulty and rewards
6. Create visual feedback for progression
7. Add sounds/effects for extraction/tier up

================================================================================
]]

return {
	description = "Progression Systems Implementation Checklist",
	completionTarget = "All steps in order",
	estimatedIntegrationTime = "4-6 hours",
	estimatedUITime = "6-8 hours",
}
