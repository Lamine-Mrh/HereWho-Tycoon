--[[
	SharedServices - Main initialization module
	Imports and exposes all shared services for use throughout the game
--]]

local SharedServices = {}
local servicesFolder = script:WaitForChild("Services")
local coreSystemsFolder = script:WaitForChild("CoreSystems")

-- Import original services
SharedServices.DataStore = require(servicesFolder:WaitForChild("DataStoreService"))
SharedServices.Profile = require(servicesFolder:WaitForChild("ProfileService"))
SharedServices.Leaderboard = require(servicesFolder:WaitForChild("LeaderboardService"))
SharedServices.Shop = require(servicesFolder:WaitForChild("ShopService"))
SharedServices.Donation = require(servicesFolder:WaitForChild("DonationService"))
SharedServices.Marketplace = require(servicesFolder:WaitForChild("MarketplaceService"))

-- Import core game systems from CoreSystems folder
SharedServices.Tower = require(coreSystemsFolder:WaitForChild("TowerSystem"))
SharedServices.Enemy = require(coreSystemsFolder:WaitForChild("EnemySystem"))
SharedServices.Wave = require(coreSystemsFolder:WaitForChild("WaveSystem"))
SharedServices.Gacha = require(coreSystemsFolder:WaitForChild("GachaSystem"))
SharedServices.Spell = require(coreSystemsFolder:WaitForChild("SpellSystem"))
SharedServices.BaseExpansion = require(coreSystemsFolder:WaitForChild("BaseExpansionSystem"))
SharedServices.Income = require(coreSystemsFolder:WaitForChild("IncomeSystem"))
SharedServices.GameState = require(coreSystemsFolder:WaitForChild("GameStateManager"))

-- Import progression systems
SharedServices.Nexus = require(coreSystemsFolder:WaitForChild("NexusSystem"))
SharedServices.Extraction = require(coreSystemsFolder:WaitForChild("ExtractionSystem"))
SharedServices.PermanentUpgrades = require(coreSystemsFolder:WaitForChild("PermanentUpgradesSystem"))
SharedServices.RunProgression = require(coreSystemsFolder:WaitForChild("RunProgressionSystem"))

return SharedServices
