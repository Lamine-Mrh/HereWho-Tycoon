--[[
    GachaSystem - Character rolling and rare item unlocks
    Handles gacha mechanics with rarity rates and crafting
]]

local GachaSystem = {}
local ProfileService = require(script.Parent.Parent.Services:WaitForChild("ProfileService"))

local RARITIES = {
    Common = { rate = 0.60, color = Color3.fromRGB(200, 200, 200) },
    Rare = { rate = 0.25, color = Color3.fromRGB(0, 112, 192) },
    Epic = { rate = 0.10, color = Color3.fromRGB(160, 32, 240) },
    Legendary = { rate = 0.04, color = Color3.fromRGB(255, 128, 0) },
    Mythic = { rate = 0.01, color = Color3.fromRGB(255, 215, 0) },
}

local GACHA_POOL = {
    { id = "basic_archer", rarity = "Common", weight = 1 },
    { id = "slime_thrower", rarity = "Common", weight = 1 },
    { id = "ice_wizard", rarity = "Rare", weight = 1 },
    { id = "fire_mage", rarity = "Rare", weight = 1 },
    { id = "cannon", rarity = "Epic", weight = 1 },
    { id = "demon_summoner", rarity = "Epic", weight = 1 },
    { id = "anime_swordsman", rarity = "Legendary", weight = 1 },
    { id = "god_priest", rarity = "Legendary", weight = 1 },
    { id = "god_tower", rarity = "Mythic", weight = 1 },
    { id = "ultimate_being", rarity = "Mythic", weight = 1 },
}

function GachaSystem:RollOnce()
    local rand = math.random()
    local rarity = self:GetRarityFromRate(rand)
    local itemsOfRarity = {}
    for _, item in ipairs(GACHA_POOL) do
        if item.rarity == rarity then
            table.insert(itemsOfRarity, item)
        end
    end
    if #itemsOfRarity == 0 then
        return nil
    end
    local result = itemsOfRarity[math.random(1, #itemsOfRarity)]
    return { id = result.id, rarity = result.rarity, color = RARITIES[result.rarity].color }
end

function GachaSystem:RollMultiple(amount: number)
    local results = {}
    for i = 1, amount do
        table.insert(results, self:RollOnce())
    end
    return results
end

function GachaSystem:GetRarityFromRate(rate: number)
    if rate <= RARITIES.Mythic.rate then
        return "Mythic"
    elseif rate <= RARITIES.Mythic.rate + RARITIES.Legendary.rate then
        return "Legendary"
    elseif rate <= RARITIES.Mythic.rate + RARITIES.Legendary.rate + RARITIES.Epic.rate then
        return "Epic"
    elseif rate <= RARITIES.Mythic.rate + RARITIES.Legendary.rate + RARITIES.Epic.rate + RARITIES.Rare.rate then
        return "Rare"
    else
        return "Common"
    end
end

function GachaSystem:GetPullRates()
    return RARITIES
end

function GachaSystem:AddRollToInventory(player: Player | number, rollResult: {[any]: any})
    local userId = if typeof(player) == "Instance" then player.UserId else player
    local profile = ProfileService:GetProfile(userId)
    if not profile then
        warn("Profile not found for:", userId)
        return
    end
    if not profile.TowerInventory then
        profile.TowerInventory = {}
    end
    if not profile.TowerInventory[rollResult.id] then
        profile.TowerInventory[rollResult.id] = { id = rollResult.id, rarity = rollResult.rarity, quantity = 0 }
    end
    profile.TowerInventory[rollResult.id].quantity = profile.TowerInventory[rollResult.id].quantity + 1
end

function GachaSystem:GetTowerInventory(player: Player | number)
    local userId = if typeof(player) == "Instance" then player.UserId else player
    local profile = ProfileService:GetProfile(userId)
    if not profile then
        return {}
    end
    return profile.TowerInventory or {}
end

function GachaSystem:GetTowerCount(player: Player | number, towerId: string)
    local userId = if typeof(player) == "Instance" then player.UserId else player
    local inventory = self:GetTowerInventory(userId)
    if inventory[towerId] then
        return inventory[towerId].quantity
    end
    return 0
end

return GachaSystem
