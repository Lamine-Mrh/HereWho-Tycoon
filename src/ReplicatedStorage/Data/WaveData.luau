--[[
	WaveData.luau
	Hand-authored wave compositions. Defines enemy spawns and timing for each wave.
]]

local Types = require(game:GetService("ReplicatedStorage").Shared.Types)

local WaveData = {}

WaveData.WAVES = {
	{
		Id = 1,
		Enemies = {
			{EnemyId = "basicEnemy", Count = 5, SpawnDelay = 0.5},
		},
		Delay = 10,
	} :: Types.Wave,

	{
		Id = 2,
		Enemies = {
			{EnemyId = "basicEnemy", Count = 8, SpawnDelay = 0.4},
		},
		Delay = 10,
	} :: Types.Wave,

	{
		Id = 3,
		Enemies = {
			{EnemyId = "basicEnemy", Count = 6, SpawnDelay = 0.3},
			{EnemyId = "fastEnemy", Count = 3, SpawnDelay = 0.5},
		},
		Delay = 10,
	} :: Types.Wave,
}

--[[
	Get a wave by ID.
	@param waveId number — the wave number
	@return Wave or nil
]]
function WaveData.GetWave(waveId: number): Types.Wave?
	return WaveData.WAVES[waveId]
end

return WaveData
