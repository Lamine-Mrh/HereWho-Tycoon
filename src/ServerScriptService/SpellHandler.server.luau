--[[
	SpellHandler - Manages spell casting and effects
	Coordinates spell cooldowns and mana system
]]

local SharedServices = require(game.ReplicatedStorage.Shared.SharedServices)

-- Mana regeneration system
local MANA_REGEN_RATE = 5 -- Mana per second
local MAX_MANA = 100
local MANA_CHECK_INTERVAL = 1 -- Regenerate mana every 1 second

-- Mana state per player
local playerMana = {}

--[[
	CastSpell
	Casts a spell for player
	
	@param player - Player object
	@param spellId (string) - Spell ID
	@return success (boolean), message (string)
]]
local function castSpell(player, spellId: string)
	local profile = SharedServices.Profile:GetProfile(player.UserId)
	local gameState = SharedServices.GameState:GetGameState(player.UserId)
	
	if not profile or not gameState then
		return false, "Profile or game state not found"
	end
	
	-- Initialize mana if needed
	if not playerMana[player.UserId] then
		playerMana[player.UserId] = MAX_MANA
	end
	
	profile.Mana = playerMana[player.UserId]
	
	-- Cast spell through SpellSystem
	local success, message = SharedServices.Spell:CastSpell(player, spellId, profile)
	
	if success then
		playerMana[player.UserId] = profile.Mana
		print("[SpellHandler] " .. player.Name .. " cast " .. spellId)
	end
	
	return success, message
end

--[[
	GetSpellCooldown
	Returns cooldown remaining for spell
	
	@param player - Player object
	@param spellId (string) - Spell ID
	@return cooldown in seconds
]]
local function getSpellCooldown(player, spellId: string)
	return SharedServices.Spell:GetSpellCooldown(player, spellId)
end

--[[
	GetPlayerMana
	Returns current mana for player
	
	@param player - Player object or UserId
	@return mana amount
]]
	local function getPlayerMana(player: Player | number)
	local userId = if typeof(player) == "Instance" then player.UserId else player
	return playerMana[userId] or MAX_MANA
end

-- Mana regeneration loop
task.spawn(function()
	while true do
		task.wait(MANA_CHECK_INTERVAL)
		
		-- Regenerate mana for all players
		for userId, currentMana in pairs(playerMana) do
			local newMana = math.min(currentMana + MANA_REGEN_RATE, MAX_MANA)
			playerMana[userId] = newMana
		end
	end
end)

-- Expose functions for RemoteFunctions
_G.SpellHandler = {
	CastSpell = castSpell,
	GetSpellCooldown = getSpellCooldown,
	GetPlayerMana = getPlayerMana,
}

print("[SpellHandler] Spell handler loaded! Mana regen: " .. MANA_REGEN_RATE .. "/sec")
