--[[
	Constants.luau
	Game-wide constants. All numeric values for balance, timing, and progression
	should live here — never hardcode them in systems.
]]

local Constants = {}

-- Debug mode: set to true during development, false for production
Constants.DEBUG = true

-- Game state
Constants.NEXUS_STARTING_HEALTH = 100
Constants.NEXUS_POSITION = {x = 0, y = 5, z = 0}

-- Wave timing
Constants.WAVE_START_DELAY = 5 -- seconds before first wave
Constants.WAVE_DELAY = 10 -- seconds between waves (default)
Constants.ENEMY_SPAWN_DELAY = 0.5 -- seconds between enemy spawns within a wave

-- Enemy movement
Constants.ENEMY_SPEED_MULTIPLIER = 1.0 -- scales all enemy speeds
Constants.PATH_REACHED_DISTANCE = 2 -- how close to endpoint to count as "reached"

-- Currency & economy
Constants.STARTING_GOLD = 200
Constants.GOLD_PER_KILL = 50
Constants.NEXUS_DAMAGE_PENALTY = 0 -- gold lost per nexus damage (can be 0)

-- Tower costs
Constants.TOWER_COST = 100
Constants.TOWER_UPGRADE_COST = 50

-- Extract milestone
Constants.EXTRACT_MILESTONE_WAVE = 5 -- offer extraction every N waves
Constants.EXTRACT_REWARD_MULTIPLIER = 1.5 -- gold multiplier for extraction

return Constants
