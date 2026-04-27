--[[
    EnemySystem - Enemy types and mechanics
    Defines enemy stats, behaviors, and progression
]]

local EnemySystem = {}

-- Enemy database with all enemy types
local ENEMIES = {
    slime = {
        id = "slime",
        name = "Slime",
        health = 10,
        speed = 20,
        reward = 10,
        size = 1.5,
        description = "Basic weak enemy",
    },
    
    goblin = {
        id = "goblin",
        name = "Goblin",
        health = 20,
        speed = 25,
        reward = 25,
        size = 2,
        description = "Small fast enemy",
    },
    
    orc = {
        id = "orc",
        name = "Orc",
        health = 50,
        speed = 15,
        reward = 50,
        size = 3,
        description = "Strong armored enemy",
    },
    
    flying_dragon = {
        id = "flying_dragon",
        name = "Flying Dragon",
        health = 80,
        speed = 30,
        reward = 100,
        size = 4,
        flying = true,
        description = "Fast aerial enemy",
    },
    
    giant_boss = {
        id = "giant_boss",
        name = "Giant Boss",
        health = 200,
        speed = 10,
        reward = 200,
        size = 5,
        boss = true,
        description = "Massive boss enemy",
    },
}

function EnemySystem:GetEnemyData(enemyId: string)
    return ENEMIES[enemyId]
end

function EnemySystem:ListAllEnemies()
    return ENEMIES
end

function EnemySystem:ScaleEnemyStats(baseEnemyData: {[any]: any}, waveNumber: number)
    waveNumber = math.max(1, waveNumber)
    local healthMultiplier = 1 + (waveNumber * 0.2)
    local rewardMultiplier = 1 + (waveNumber * 0.15)
    local speedMultiplier = 1 + (waveNumber * 0.05)
    
    return {
        id = baseEnemyData.id,
        name = baseEnemyData.name,
        health = math.floor(baseEnemyData.health * healthMultiplier),
        speed = baseEnemyData.speed * speedMultiplier,
        reward = math.floor(baseEnemyData.reward * rewardMultiplier),
        size = baseEnemyData.size,
        flying = baseEnemyData.flying,
        boss = baseEnemyData.boss,
        description = baseEnemyData.description,
        scaledWave = waveNumber,
    }
end

function EnemySystem:GenerateWaveEnemies(waveNumber: number)
    waveNumber = math.max(1, waveNumber)
    local enemies = {}
    local enemyCount = 5 + math.floor(waveNumber * 1.5)
    for i = 1, enemyCount do
        local enemyType
        if waveNumber < 3 then
            enemyType = "slime"
        elseif waveNumber < 5 then
            enemyType = math.random() > 0.5 and "slime" or "goblin"
        elseif waveNumber < 10 then
            enemyType = ({"goblin", "orc"})[math.random(1, 2)]
        else
            enemyType = ({"orc", "flying_dragon", "giant_boss"})[math.random(1, 3)]
        end
        local baseData = ENEMIES[enemyType]
        local scaledEnemy = self:ScaleEnemyStats(baseData, waveNumber)
        scaledEnemy.spawnTime = i * 0.5
        table.insert(enemies, scaledEnemy)
    end
    return enemies
end

function EnemySystem:GetEnemyReward(enemyData: {[any]: any}): number
    return enemyData.reward or 10
end

return EnemySystem
