--[[
	PROGRESSION_SYSTEMS_GUIDE.luau
	Comprehensive guide to the new progression system with extraction, nexus, and permanent upgrades
]]

--[[
================================================================================
PROGRESSION ARCHITECTURE OVERVIEW
================================================================================

The game now has a sophisticated multi-layered progression system:

1. SESSION PROGRESSION (Per Run)
   - Waves completed
   - Enemies defeated
   - Money earned
   - Towers placed
   - Resets after extraction or nexus destruction

2. RUN PROGRESSION (Across Runs)
   - Total runs completed
   - Total extractions (successful endings)
   - Total losses (nexus destroyed)
   - Run tier level (Novice → Legend)
   - Unlocked content based on tier
   - Difficulty scaling per tier

3. PERMANENT PROGRESSION (Cross-Save)
   - Permanent upgrades (generators, tower slots, gacha rates, nexus health, mana)
   - Permanent unlocks
   - Carries across all runs indefinitely

================================================================================
EXTRACTION MECHANIC
================================================================================

GOAL: Players decide each 5-10 waves whether to extract (safe) or continue (risky)

EXTRACTION POINTS:
  Wave 5  - After first full round
  Wave 10 - Mid-game checkpoint
  Wave 15 - Advanced challenge
  Wave 20 - Expert challenge
  Wave 25+ - Always available

EXTRACTION REWARDS:
  1. MONEY: 
     - Wave bonus: 500 × waveNumber
     - Enemy bonus: 10 × enemiesDefeated
     - Money keepPercentage: 50% of moneyEarned
     - Total = waveBonus + enemyBonus + moneyKeepPercentage

  2. EXPERIENCE:
     - Base: 100 XP per wave
     - Difficulty bonus: (100 × waveNumber) × (difficulty - 1)
     - Used for run tier progression

  3. PROGRESSION TIER:
     - Initiate: Waves 1-4
     - Survivor: Waves 5-9
     - Veteran: Waves 10-14
     - Champion: Waves 15-19
     - Legend: Waves 20+

MECHANICS:
  1. At extraction point, UI shows rewards
  2. Player chooses:
     a) EXTRACT: Gets rewards, run ends, money added to profile, tier check, run resets
     b) CONTINUE: Risk losing everything if nexus breaks, but get higher extraction rewards later

FAILURE STATE:
  - If nexus breaks before extraction: 0 rewards, lose session money
  - Run still counts toward run count (for difficulty scaling)
  - But no extraction achievement

================================================================================
NEXUS SYSTEM
================================================================================

The NEXUS is the central structure player must defend.

PROPERTIES:
  - Health: Current HP (decreases when enemies reach it)
  - Max Health: Starting 100 + permanent upgrades (nexus_health upgrades add 50-200 HP)
  - Is Active: True while game running, False if destroyed
  - Damage Tracking: Records total damage taken per run

BREAKING RULES:
  - When health reaches 0: Nexus breaks, game is lost
  - No extraction bonus, session money lost
  - Run is still recorded (counts toward next run's difficulty)

METHODS:
  Nexus:InitializeNexus(player, baseHealth)      - Start run with health
  Nexus:GetNexusHealth(player)                    - Current HP
  Nexus:GetMaxHealth(player)                      - Max HP
  Nexus:GetHealthPercent(player)                  - 0-100 percentage
  Nexus:IsNexusAlive(player)                      - Still alive?
  Nexus:DamageNexus(player, damage)               - Deal damage
  Nexus:HealNexus(player, healing)                - Heal (via spells)
  Nexus:UpgradeNexusHealth(player, amount)        - Permanent increase
  Nexus:ResetNexus(player)                        - Full reset for next run

================================================================================
PERMANENT UPGRADES SYSTEM
================================================================================

Players spend extracted money on permanent upgrades between runs.

UPGRADE CATEGORIES:

1. GENERATOR MULTIPLIERS (5 levels)
   Level 1: $5,000 → +10% income
   Level 2: $15,000 → +20% total income
   Level 3: $50,000 → +35% total income
   Level 4: $150,000 → +50% total income
   Level 5: $500,000 → +75% total income
   Effect: All generators produce more money per second

2. TOWER SLOTS (5 levels, each adds more slots)
   Level 1: $3,000 → +1 slot
   Level 2: $10,000 → +1 slot
   Level 3: $35,000 → +2 slots
   Level 4: $100,000 → +2 slots
   Level 5: $300,000 → +3 slots
   Effect: Can place more towers per run (max 20 with all upgrades)

3. GACHA RATE (5 levels, increases mythic rate)
   Level 1: $8,000 → +0.5% mythic rate
   Level 2: $25,000 → +1.0% mythic rate
   Level 3: $75,000 → +1.5% mythic rate
   Level 4: $200,000 → +2.0% mythic rate
   Level 5: $750,000 → +3.0% mythic rate
   Effect: Better rarity rates when rolling

4. NEXUS HEALTH (5 levels)
   Level 1: $10,000 → +50 max health
   Level 2: $40,000 → +75 max health
   Level 3: $120,000 → +100 max health
   Level 4: $350,000 → +150 max health
   Level 5: $1,000,000 → +200 max health
   Effect: Nexus starts with more health each run

5. SPELL CAPACITY (5 levels)
   Level 1: $4,000 → +10 max mana
   Level 2: $12,000 → +15 max mana
   Level 3: $40,000 → +20 max mana
   Level 4: $120,000 → +30 max mana
   Level 5: $400,000 → +50 max mana
   Effect: Can cast more spells before running out of mana

BALANCE NOTES:
  - Early upgrades (generator, nexus health) make game easier and more playable
  - Mid upgrades (tower slots, spell) add strategic depth
  - Late upgrades (gacha) are luxury/collection focused
  - No single upgrade is mandatory (all viable paths)
  - Cost scaling encourages specialization choices

================================================================================
RUN PROGRESSION SYSTEM
================================================================================

Tracks long-term progression through "run tiers" that unlock content.

RUN TIERS (1-6):

Tier 1 - NOVICE
  Requirement: 0 runs
  Content Unlocks: Basic missions
  Difficulty: 1.0x
  Feeling: Tutorial/introduction phase

Tier 2 - APPRENTICE
  Requirement: 5 total runs
  Content Unlocks: Tier 2 towers
  Difficulty: 1.15x
  Feeling: First mastery milestone

Tier 3 - ADEPT
  Requirement: 15 total runs
  Content Unlocks: Advanced generators
  Difficulty: 1.30x
  Feeling: Intermediate player

Tier 4 - MASTER
  Requirement: 35 total runs
  Content Unlocks: Rare gacha, challenge modes
  Difficulty: 1.45x
  Feeling: Competitive phase

Tier 5 - GRANDMASTER
  Requirement: 75 total runs
  Content Unlocks: Ultimate content
  Difficulty: 1.60x
  Feeling: Veteran player

Tier 6 - LEGEND
  Requirement: 150 total runs
  Content Unlocks: Legendary events
  Difficulty: 1.75x
  Feeling: Elite endgame

MECHANICS:
  - Runs count regardless of extraction or loss
  - Difficulty scales with tier (enemies 15% harder per tier)
  - Tiers are permanent milestones (no downgrading)
  - Unlocks are cumulative (Tier 3 has all Tier 1-3 content)

PROGRESSION TRACKING:
  profile.RunProgression = {
    totalRuns: number,          -- All runs ever
    totalExtraction: number,    -- Times player extracted
    totalLoss: number,          -- Times nexus broke
    currentRunCount: number,    -- Runs in current session
    currentTier: number,        -- 1-6
    experiencePoints: number,   -- From extractions
    unlockedContent: {string}   -- Content IDs unlocked
  }

================================================================================
GAME FLOW WITH PROGRESSION
================================================================================

1. FIRST LOAD
   → Initialize profile with RunProgression
   → currentTier = 1, totalRuns = 0, unlockedContent = {"basic_missions"}

2. START NEW RUN
   → Get difficulty multiplier from RunProgression:GetDifficultyMultiplier()
   → Initialize Nexus with baseHealth + permanent upgrade bonuses
   → Set game state with maxTowers + extraSlots, maxMana + manaBonus
   → Start wave 1

3. DURING RUN
   → Every wave, check if extraction is available
   → If available, notify client with ExtractionReady signal
   → Player continues or extracts

4. EXTRACTION (Player Chooses Extract)
   → Calculate rewards via Extraction:CalculateExtractionReward()
   → Add money to profile
   → Call RunProgression:AddRunCompletion(profile, true, wave, rewards)
   → Check for tier up via RunProgression:CheckTierUp()
   → Reset game state and nexus for next run

5. FAILURE (Nexus Destroyed)
   → Immediately trigger game over
   → Call RunProgression:AddRunCompletion(profile, false, wave, {})
   → No rewards, but run still counts for difficulty
   → Reset for next run

6. PERMANENT UPGRADE SHOP
   → Player spends extracted money on upgrades
   → Each purchase calls PermanentUpgrades:PurchaseUpgrade()
   → Effects apply to next run automatically

7. NEXT RUN
   → Difficulty increases based on tier
   → New nexus health from upgrades
   → New tower slots available
   → Better gacha rates
   → Cycle continues...

================================================================================
INTEGRATION WITH EXISTING SYSTEMS
================================================================================

GAMESTATE INTEGRATION:
  - On InitializeGameState(), set difficultyMultiplier
  - On DamageBase(), check if health <= 0, then trigger nexus destruction
  - Store currentWave to track extraction points

WAVE SYSTEM INTEGRATION:
  - After each wave completes, check if extraction available
  - If yes, notify client

INCOME SYSTEM INTEGRATION:
  - Generators scaled by PermanentUpgrades:GetGeneratorMultiplier()
  - formulas: income × permanentUpgradeMultiplier

GACHA SYSTEM INTEGRATION:
  - Rarity rates adjusted by PermanentUpgrades:GetGachaBonusRate()
  - Mythic rate += GetGachaBonusRate() value

SPELL SYSTEM INTEGRATION:
  - Max mana = 100 + PermanentUpgrades:GetManaBonus()
  - Applied on each run reset

TOWER SYSTEM INTEGRATION:
  - Max tower slots = baseSlots + PermanentUpgrades:GetExtraSlots()
  - Checked in placement validation

================================================================================
DATA STRUCTURE EXAMPLES
================================================================================

PROFILE.RunProgression:
{
  totalRuns: 47,
  totalExtraction: 23,        -- 23 successful extractions
  totalLoss: 24,              -- 24 nexus destructions
  currentRunCount: 1,         -- First run in this session
  currentTier: 4,             -- MASTER
  experiencePoints: 12500,
  unlockedContent: {
    "basic_missions",
    "tier2_towers",
    "advanced_generators",
    "rare_gacha",
    "challenge_modes"
  }
}

PROFILE.PermanentUpgrades:
{
  generator: 3,               -- Level 3 = +35% income
  tower_slots: 2,             -- Level 2 = +2 total extra slots
  gacha: 1,                   -- Level 1 = +0.5% mythic
  nexus: 4,                   -- Level 4 = +150 max health
  spell: 2,                   -- Level 2 = +15 max mana
}

NEXUSDATA[UserId]:
{
  health: 200,                -- Current health
  maxHealth: 250,             -- Base 100 + 150 from upgrades
  isActive: true,
  damageTaken: 50,
  createdAt: 1234567890
}

EXTRACTION_REWARD_BREAKDOWN:
{
  waveBonus: 5000,            -- 10 waves × 500
  enemyBonus: 750,            -- 75 enemies × 10
  moneyKept: 25000,           -- 50% of $50k earned
  totalMoney: 30750,          -- waveBonus + enemyBonus + moneyKept
  experience: 2500,           -- 100 × 10 waves + difficulty bonus
  progressionTier: "Champion"  -- Waves 15-19 range
}

================================================================================
BALANCE TUNING PARAMETERS
================================================================================

EXTRACTION WAVES: { 5, 10, 15, 20 }
  - Recommended: Keep at 5-wave intervals
  - Could expand to 25, 30 for infinite scaling

EXTRACTION MONEY FORMULAS:
  waveBonus = currentWave × 500              -- Increase for more money
  enemyBonus = enemiesDefeated × 10
  moneyKeep = moneyEarned × 0.50             -- Lower % to encourage spending
  
EXPERIENCE CALCULATION:
  baseXP = currentWave × 100                 -- Increase for faster tier progression
  difficultyBonus = baseXP × (difficulty - 1)

RUN TIER THRESHOLDS:
  Tier 1: 0    - Easy start
  Tier 2: 5    - Gentle progression
  Tier 3: 15   - Early grind begins
  Tier 4: 35   - Noticeable grind
  Tier 5: 75   - Major milestone
  Tier 6: 150  - Hardcore goal

DIFFICULTY MULTIPLIER:
  1.0 + ((tier - 1) × 0.15)   -- 15% per tier
  Could adjust to 0.10 (easier) or 0.20 (harder)

PERMANENT UPGRADE COSTS:
  All tiered 3-5x per level
  Recommended: Lower early costs, higher late costs
  Could use different formulas per upgrade type

================================================================================
CLIENT COMMUNICATION SIGNALS
================================================================================

ExtractionReady Event (Server → Client):
{
  canExtract: boolean,
  currentWave: number,
  nextWave: number,
}

ExtractionRequest Event (Client → Server):
{
  extractData: table
}

RunRestart Event (Server → Client):
{
  type: "extraction" | "loss",
  rewards: table,             -- If extraction
  tierUp: boolean,            -- If tier advanced
  newTier: number,            -- If tier advanced
  waveReached: number,        -- If loss
  message: string,            -- UI message
}

================================================================================
FUTURE EXPANSION IDEAS
================================================================================

1. SPECIAL EVENTS
   - Limited-time extraction multipliers
   - Double XP weekends
   - Exclusive tier-locked towers

2. PRESTIGE SYSTEM
   - At Tier 6, option to "prestige" back to Tier 1
   - Unlock special cosmetics/rewards
   - Permanent power carries over

3. LADDER SYSTEM
   - Leaderboards by tier
   - Seasonal resets
   - Rewards for top players

4. MASTERY SYSTEM
   - Per-tower mastery levels
   - Unlock enhanced versions of towers
   - Gacha becomes tower collector game

5. CHALLENGE MODES
   - Daily challenges (extract by wave 10)
   - Survival mode (infinite waves)
   - Hardcore mode (1 life, no extraction)

================================================================================
]]

return {
	description = "Progression Systems Documentation",
	systems = {
		"ExtractionSystem",
		"NexusSystem",
		"PermanentUpgradesSystem",
		"RunProgressionSystem",
	},
	integrations = {
		"GameStateManager",
		"WaveSystem",
		"IncomeSystem",
		"GachaSystem",
		"SpellSystem",
		"TowerSystem",
	},
	extracted_total_cost = 3750000,  -- Total cost to max all permanent upgrades
}
