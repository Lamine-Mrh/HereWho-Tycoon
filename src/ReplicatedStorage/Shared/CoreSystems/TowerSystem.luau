--[[
    TowerSystem - Tower mechanics and data
    Handles tower definitions, stats, upgrades, and targeting
]]

local TowerSystem = {}

-- Tower database with all tower types
local TOWERS = {
    basic_archer = {
        id = "basic_archer",
        name = "Basic Archer",
        rarity = "Common",
        cost = 100,
        damage = 10,
        range = 50,
        attackSpeed = 1,
        description = "Fast single-target archer",
        element = "Physical",
        maxLevel = 5,
        upgradeCostMultiplier = 1.5,
    },
    
    ice_wizard = {
        id = "ice_wizard",
        name = "Ice Wizard",
        rarity = "Rare",
        cost = 500,
        damage = 15,
        range = 60,
        attackSpeed = 0.8,
        description = "Slows enemies with ice attacks",
        element = "Ice",
        maxLevel = 5,
        upgradeCostMultiplier = 1.5,
        special = "slow",
    },
    
    cannon = {
        id = "cannon",
        name = "Cannon",
        rarity = "Epic",
        cost = 1500,
        damage = 40,
        range = 70,
        attackSpeed = 0.5,
        description = "AoE splash damage tower",
        element = "Explosive",
        maxLevel = 5,
        upgradeCostMultiplier = 1.5,
        special = "aoe",
        splashRadius = 40,
    },
    
    anime_swordsman = {
        id = "anime_swordsman",
        name = "Anime Swordsman",
        rarity = "Legendary",
        cost = 5000,
        damage = 80,
        range = 55,
        attackSpeed = 1.5,
        description = "Ultra-fast legendary swordsman",
        element = "Physical",
        maxLevel = 5,
        upgradeCostMultiplier = 1.5,
        special = "multihit",
        hits = 3,
    },
    
    god_tower = {
        id = "god_tower",
        name = "God Tower",
        rarity = "Mythic",
        cost = 50000,
        damage = 200,
        range = 100,
        attackSpeed = 2,
        description = "Ultimate tower - destroys everything",
        element = "Divine",
        maxLevel = 5,
        upgradeCostMultiplier = 2,
        special = "piercing",
    },
}

function TowerSystem:GetTowerData(towerId: string)
    return TOWERS[towerId]
end

function TowerSystem:ListAllTowers()
    return TOWERS
end

function TowerSystem:GetTowersByRarity(rarity: string)
    local result = {}
    for id, data in pairs(TOWERS) do
        if data.rarity == rarity then
            table.insert(result, data)
        end
    end
    return result
end

function TowerSystem:CalculateUpgradeCost(baseCost: number, currentLevel: number, multiplier: number): number
    return math.floor(baseCost * (multiplier ^ currentLevel))
end

function TowerSystem:CalculateUpgradedStats(towerData: {[any]: any}, level: number)
    level = math.max(1, level)
    local statMultiplier = 1 + (level * 0.15)
    
    return {
        damage = math.floor(towerData.damage * statMultiplier),
        range = math.floor(towerData.range * statMultiplier * 1.1),
        attackSpeed = towerData.attackSpeed * (1 + (level * 0.05)),
    }
end

function TowerSystem:IsTowerAffordable(profile: {[any]: any}, towerData: {[any]: any}): boolean
    return (profile.Money or 0) >= towerData.cost
end

return TowerSystem
