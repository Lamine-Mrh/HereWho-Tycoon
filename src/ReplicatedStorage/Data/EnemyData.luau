--[[
	EnemyData.luau
	Enemy configurations and stats. Phase 1 includes basic enemies;
	more types will be added in later phases.
]]

local Types = require(game:GetService("ReplicatedStorage").Shared.Types)

local EnemyData = {}

EnemyData.ENEMY_CONFIGS = {
	["basicEnemy"] = {
		Id = "basicEnemy",
		Health = 10,
		Speed = 15, -- studs per second
		Reward = 50,
		Size = 1,
	} :: Types.EnemyConfig,

	["fastEnemy"] = {
		Id = "fastEnemy",
		Health = 5,
		Speed = 25,
		Reward = 75,
		Size = 0.8,
	} :: Types.EnemyConfig,

	["tankEnemy"] = {
		Id = "tankEnemy",
		Health = 30,
		Speed = 10,
		Reward = 100,
		Size = 1.5,
	} :: Types.EnemyConfig,
}

--[[
	Get an enemy config by ID.
	@param id string — the enemy type ID
	@return EnemyConfig or nil
]]
function EnemyData.GetEnemyConfig(id: string): Types.EnemyConfig?
	return EnemyData.ENEMY_CONFIGS[id]
end

return EnemyData
