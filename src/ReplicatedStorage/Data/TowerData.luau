--[[
	TowerData.luau
	Tower configurations and stats. Will be implemented in Phase 2.
	Stub for Phase 1.
]]

local Types = require(game:GetService("ReplicatedStorage").Shared.Types)

local TowerData = {}

TowerData.TOWER_CONFIGS = {
	-- Towers will be added in Phase 2
}

--[[
	Get a tower config by ID.
	@param id string — the tower type ID
	@return TowerConfig or nil
]]
function TowerData.GetTowerConfig(id: string): Types.TowerConfig?
	return TowerData.TOWER_CONFIGS[id]
end

return TowerData
