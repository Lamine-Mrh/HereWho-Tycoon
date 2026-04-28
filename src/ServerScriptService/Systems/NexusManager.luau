--[[
	NexusManager.luau
	Manages the Nexus (the player's base). Tracks health and damage.
	Owns: nexus health, damage events.
	Reports game over when health reaches 0.
]]

local Constants = require(game:GetService("ReplicatedStorage").Shared.Constants)
local Debug = require(game:GetService("ServerScriptService").Modules.Debug)

local NexusManager = {}

-- Private state
local _health = Constants.NEXUS_STARTING_HEALTH
local _maxHealth = Constants.NEXUS_STARTING_HEALTH
local _isAlive = true
local _deathEvent = Instance.new("BindableEvent")

--[[
	Initialize NexusManager.
	@return void
]]
function NexusManager.Init(): void
	_health = Constants.NEXUS_STARTING_HEALTH
	_maxHealth = Constants.NEXUS_STARTING_HEALTH
	_isAlive = true
end

--[[
	Deal damage to the Nexus.
	@param damage number — amount of damage to deal
	@return void
]]
function NexusManager.TakeDamage(damage: number): void
	if not _isAlive then
		return
	end

	Debug.PrintTag("NEXUS", "took", damage, "damage (health: " .. _health .. " -> " .. (_health - damage) .. ")")

	_health -= damage

	if _health <= 0 then
		_health = 0
		_onNexusDestroyed()
	end

	-- TODO: fire RemoteEvent to clients to update UI
end

--[[
	Private: called when Nexus is destroyed.
]]
local function _onNexusDestroyed(): void
	_isAlive = false
	Debug.PrintTag("NEXUS", "DESTROYED - GAME OVER")
	_deathEvent:Fire()
end

--[[
	Get current Nexus health.
	@return number
]]
function NexusManager.GetHealth(): number
	return _health
end

--[[
	Get max Nexus health.
	@return number
]]
function NexusManager.GetMaxHealth(): number
	return _maxHealth
end

--[[
	Check if Nexus is alive.
	@return boolean
]]
function NexusManager.IsAlive(): boolean
	return _isAlive
end

--[[
	Check if Nexus is destroyed.
	@return boolean
]]
function NexusManager.IsDestroyed(): boolean
	return not _isAlive
end

--[[
	Connect to nexus death event.
	@param callback function — called when nexus is destroyed
	@return RBXScriptConnection
]]
function NexusManager.OnDestroyed(callback: (any) -> ()): any
	return _deathEvent.Event:Connect(callback)
end

--[[
	Heal the Nexus (for future power-ups or abilities).
	@param amount number — amount to heal
	@return void
]]
function NexusManager.Heal(amount: number): void
	_health = math.min(_health + amount, _maxHealth)
end

return NexusManager
