--[[
    SpellSystem - Magic abilities and elemental system
    Handles spell mechanics, cooldowns, and elements
]]

local SpellSystem = {}

-- Spell database
local SPELLS = {
    -- PHYSICAL SPELLS
    meteor_strike = {
        id = "meteor_strike",
        name = "Meteor Strike",
        element = "Physical",
        cost = 50,
        cooldown = 10,
        description = "Rain meteors on enemies",
        radius = 60,
        damage = 150,
    },
    
    -- ICE SPELLS
    freeze_all = {
        id = "freeze_all",
        name = "Freeze All",
        element = "Ice",
        cost = 40,
        cooldown = 15,
        description = "Freeze all enemies temporarily",
        duration = 5,
    },
    
    -- FIRE SPELLS
    inferno = {
        id = "inferno",
        name = "Inferno",
        element = "Fire",
        cost = 60,
        cooldown = 20,
        description = "Burn enemies with intense heat",
        damage = 200,
        burnDuration = 8,
    },
    
    -- SUPPORT SPELLS
    heal_walls = {
        id = "heal_walls",
        name = "Heal Walls",
        element = "Support",
        cost = 30,
        cooldown = 8,
        description = "Restore wall health",
        healAmount = 100,
    },
    
    tower_boost = {
        id = "tower_boost",
        name = "Tower Boost",
        element = "Support",
        cost = 35,
        cooldown = 12,
        description = "Boost tower damage temporarily",
        damageMultiplier = 2,
        duration = 6,
    },
    
    -- UTILITY SPELLS
    speed_boost = {
        id = "speed_boost",
        name = "Speed Boost",
        element = "Support",
        cost = 25,
        cooldown = 10,
        description = "Speed up tower attack speed",
        speedMultiplier = 1.5,
        duration = 5,
    },
    
    knockback = {
        id = "knockback",
        name = "Knockback Blast",
        element = "Physical",
        cost = 45,
        cooldown = 12,
        description = "Push all enemies back",
        force = 100,
    },
}

-- Player spell cooldowns
local spellCooldowns = {}

function SpellSystem:GetSpellData(spellId: string)
    return SPELLS[spellId]
end

function SpellSystem:ListSpellsByElement(element: string)
    local result = {}
    for id, spell in pairs(SPELLS) do
        if spell.element == element then
            table.insert(result, spell)
        end
    end
    return result
end

function SpellSystem:GetAllSpells()
    return SPELLS
end

function SpellSystem:CastSpell(player: Player | number, spellId: string, profile: {[any]: any})
    local userId = if typeof(player) == "Instance" then player.UserId else player
    local spell = SPELLS[spellId]
    
    if not spell then
        return false, "Spell not found"
    end
    
    if (profile.Mana or 0) < spell.cost then
        return false, "Insufficient mana"
    end
    
    local lastCast = spellCooldowns[userId .. "_" .. spellId] or 0
    if tick() - lastCast < spell.cooldown then
        return false, "Spell on cooldown (" .. math.ceil(spell.cooldown - (tick() - lastCast)) .. "s)"
    end
    
    profile.Mana = profile.Mana - spell.cost
    spellCooldowns[userId .. "_" .. spellId] = tick()
    
    return true, "Spell cast: " .. spell.name
end

function SpellSystem:GetSpellCooldown(player: Player | number, spellId: string): number
    local userId = if typeof(player) == "Instance" then player.UserId else player
    local lastCast = spellCooldowns[userId .. "_" .. spellId] or 0
    local spell = SPELLS[spellId]
    
    if not spell then
        return 0
    end
    
    local remaining = spell.cooldown - (tick() - lastCast)
    return math.max(0, remaining)
end

function SpellSystem:RegenerateMana(profile: {[any]: any}, amount: number, maxMana: number)
    if not profile.Mana then
        profile.Mana = maxMana
        return
    end
    
    profile.Mana = math.min(profile.Mana + amount, maxMana)
end

return SpellSystem
