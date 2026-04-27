--[[
    BaseExpansionSystem - Base unlocking and expansion
    Handles tower slots, walls, floors, and base growth
]]

local BaseExpansionSystem = {}

-- Base expansion levels
local BASE_LEVELS = {
    {
        level = 1,
        name = "Starter Base",
        towerSlots = 3,
        maxWalls = 2,
        cost = 0,
        unlockAt = 0,
        description = "Your first base",
        floors = 1,
    },
    {
        level = 2,
        name = "Small Fortress",
        towerSlots = 5,
        maxWalls = 3,
        cost = 1000,
        unlockAt = 500,
        description = "Expanded base with more towers",
        floors = 2,
    },
    {
        level = 3,
        name = "Medium Stronghold",
        towerSlots = 8,
        maxWalls = 5,
        cost = 5000,
        unlockAt = 5000,
        description = "Significant base expansion",
        floors = 2,
    },
    {
        level = 4,
        name = "Large Citadel",
        towerSlots = 12,
        maxWalls = 8,
        cost = 25000,
        unlockAt = 50000,
        description = "Major fortress",
        floors = 3,
    },
    {
        level = 5,
        name = "Massive Empire",
        towerSlots = 20,
        maxWalls = 15,
        cost = 100000,
        unlockAt = 500000,
        description = "Ultimate base",
        floors = 5,
    },
}

function BaseExpansionSystem:GetBaseLevel(level: number)
    return BASE_LEVELS[level]
end

function BaseExpansionSystem:GetNextBaseLevel(currentLevel: number)
    return BASE_LEVELS[currentLevel + 1]
end

function BaseExpansionSystem:CanUpgradeBase(profile: {[any]: any}, currentLevel: number)
    local nextLevel = self:GetNextBaseLevel(currentLevel)
    
    if not nextLevel then
        return false, "Already at max level"
    end
    
    if (profile.Money or 0) < nextLevel.cost then
        return false, "Insufficient money. Need: $" .. nextLevel.cost
    end
    
    return true, "Can upgrade"
end

function BaseExpansionSystem:UpgradeBase(profile: {[any]: any}, currentLevel: number)
    local canUpgrade, reason = self:CanUpgradeBase(profile, currentLevel)
    
    if not canUpgrade then
        return false, reason, currentLevel
    end
    
    local nextLevel = self:GetNextBaseLevel(currentLevel)
    profile.Money = profile.Money - nextLevel.cost
    profile.BaseLevel = (profile.BaseLevel or 1) + 1
    
    return true, "Base upgraded to " .. nextLevel.name, nextLevel.level
end

function BaseExpansionSystem:GetTowerSlots(baseLevel: number): number
    local level = self:GetBaseLevel(baseLevel)
    return level and level.towerSlots or 3
end

function BaseExpansionSystem:GetMaxWalls(baseLevel: number): number
    local level = self:GetBaseLevel(baseLevel)
    return level and level.maxWalls or 2
end

function BaseExpansionSystem:GetFloorCount(baseLevel: number): number
    local level = self:GetBaseLevel(baseLevel)
    return level and level.floors or 1
end

function BaseExpansionSystem:CanPlaceTower(profile: {[any]: any}, towersPlaced: number): boolean
    local baseLevel = profile.BaseLevel or 1
    local maxSlots = self:GetTowerSlots(baseLevel)
    return towersPlaced < maxSlots
end

function BaseExpansionSystem:ListAllBaseLevels()
    return BASE_LEVELS
end

return BaseExpansionSystem
