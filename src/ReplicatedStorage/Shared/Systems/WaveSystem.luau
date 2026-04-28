--[[
    WaveSystem - Wave management and difficulty scaling
    Handles wave progression, spawning, and rewards
]]

local WaveSystem = {}

local waveState = {
    currentWave = 0,
    currentRound = 1,
    enemiesSpawned = 0,
    enemiesDefeated = 0,
    isWaveActive = false,
    waveReward = 0,
}

function WaveSystem:StartWave(waveNumber: number)
    waveNumber = math.max(1, waveNumber)
    waveState.currentWave = waveNumber
    waveState.isWaveActive = true
    waveState.enemiesSpawned = 0
    waveState.enemiesDefeated = 0
    waveState.waveReward = self:CalculateWaveReward(waveNumber)
    print("[WaveSystem] Wave", waveNumber, "started! Reward: $" .. waveState.waveReward)
    return waveState
end

function WaveSystem:EndWave()
    if not waveState.isWaveActive then
        return nil
    end
    waveState.isWaveActive = false
    local completionBonus = 0
    if waveState.enemiesDefeated == waveState.enemiesSpawned then
        completionBonus = math.floor(waveState.waveReward * 0.25)
    end
    local result = {
        waveNumber = waveState.currentWave,
        baseReward = waveState.waveReward,
        completionBonus = completionBonus,
        totalReward = waveState.waveReward + completionBonus,
        enemiesDefeated = waveState.enemiesDefeated,
        enemiesSpawned = waveState.enemiesSpawned,
    }
    print("[WaveSystem] Wave completed! Reward: $" .. result.totalReward)
    return result
end

function WaveSystem:CalculateWaveReward(waveNumber: number): number
    waveNumber = math.max(1, waveNumber)
    local baseReward = 100
    local rewardGrowth = 1.25
    return math.floor(baseReward * (rewardGrowth ^ (waveNumber - 1)))
end

function WaveSystem:OnEnemyDefeated(enemyReward: number)
    waveState.enemiesDefeated = waveState.enemiesDefeated + 1
    return enemyReward
end

function WaveSystem:OnEnemySpawned()
    waveState.enemiesSpawned = waveState.enemiesSpawned + 1
end

function WaveSystem:SkipWave(): boolean
    if not waveState.isWaveActive then
        return false
    end
    waveState.isWaveActive = false
    waveState.currentWave = waveState.currentWave + 1
    print("[WaveSystem] Wave skipped!")
    return true
end

function WaveSystem:GetWaveState()
    return {
        currentWave = waveState.currentWave,
        currentRound = waveState.currentRound,
        isWaveActive = waveState.isWaveActive,
        enemiesSpawned = waveState.enemiesSpawned,
        enemiesDefeated = waveState.enemiesDefeated,
        waveReward = waveState.waveReward,
    }
end

function WaveSystem:StartNextRound()
    waveState.currentRound = waveState.currentRound + 1
    waveState.currentWave = 1
    print("[WaveSystem] Round", waveState.currentRound, "started!")
end

function WaveSystem:GetDifficultyMultiplier(): number
    return 1 + ((waveState.currentRound - 1) * 0.15)
end

return WaveSystem
