--[[
	ShopService - Shop management
	Handles shop inventory, items, and purchases
--]]

local ShopService = {}
local ProfileService = require(script.Parent:WaitForChild("ProfileService"))
local RunService = game:GetService("RunService")

if not RunService:IsServer() then
	error("ShopService can only be used on the server!")
end

-- Shop database
local shops = {}

-- Signal for purchase events
local PurchaseSignal = {}
PurchaseSignal.__index = PurchaseSignal

function PurchaseSignal.new()
	return setmetatable({
		_bindables = {},
	}, PurchaseSignal)
end

function PurchaseSignal:Connect(callback)
	local bindable = Instance.new("BindableFunction")
	bindable.OnInvoke = callback
	table.insert(self._bindables, bindable)
	
	return {
		Disconnect = function(self)
			for i, b in ipairs(self._bindables) do
				if b == bindable then
					table.remove(self._bindables, i)
					break
				end
			end
		end
	}
end

function PurchaseSignal:Fire(...)
	local args = {...}
	for _, bindable in ipairs(self._bindables) do
		task.spawn(function()
			bindable:Invoke(table.unpack(args))
		end)
	end
end

--[[
	RegisterShop
	Registers a new shop
	
	@param shopName (string) - Name of the shop
	@param shopData (table) - Shop configuration
]]
function ShopService:RegisterShop(shopName: string, shopData: {[any]: any})
	assert(shopName, "shopName is required")
	assert(shopData, "shopData is required")
	
	shops[shopName] = {
		name = shopName,
		items = shopData.items or {},
		currency = shopData.currency or "Money", -- Which profile field to use for payment
		description = shopData.description or "",
		PurchasedSignal = PurchaseSignal.new(),
	}
	
	print("Registered shop:", shopName)
end

--[[
	AddItemToShop
	Adds an item to a shop
	
	@param shopName (string) - Shop name
	@param itemId (string) - Unique item ID
	@param itemData (table) - Item configuration {name, price, description, ...}
]]
function ShopService:AddItemToShop(shopName: string, itemId: string, itemData: {[any]: any})
	assert(shopName, "shopName is required")
	assert(itemId, "itemId is required")
	assert(itemData, "itemData is required")
	
	local shop = shops[shopName]
	if not shop then
		warn("Shop not found:", shopName)
		return false
	end
	
	shop.items[itemId] = {
		id = itemId,
		name = itemData.name or "Unknown Item",
		price = itemData.price or 0,
		description = itemData.description or "",
		maxStack = itemData.maxStack or 1,
		custom = itemData.custom or {},
	}
	
	return true
end

--[[
	GetShop
	Retrieves a shop's data
	
	@param shopName (string) - Shop name
	@return shop data or nil
]]
function ShopService:GetShop(shopName: string)
	return shops[shopName]
end

--[[
	GetShopItems
	Gets all items in a shop
	
	@param shopName (string) - Shop name
	@return table of items
]]
function ShopService:GetShopItems(shopName: string)
	local shop = shops[shopName]
	if not shop then
		return {}
	end
	
	return shop.items
end

--[[
	GetItem
	Gets a specific item from a shop
	
	@param shopName (string) - Shop name
	@param itemId (string) - Item ID
	@return item data or nil
]]
function ShopService:GetItem(shopName: string, itemId: string)
	local shop = shops[shopName]
	if not shop then
		return nil
	end
	
	return shop.items[itemId]
end

--[[
	PurchaseItem
	Handles item purchase
	
	@param player - Player object or UserId (number)
	@param shopName (string) - Shop name
	@param itemId (string) - Item ID
	@return success (boolean), message (string)
]]
function ShopService:PurchaseItem(player: Player | number, shopName: string, itemId: string)
	assert(shopName, "shopName is required")
	assert(itemId, "itemId is required")
	
	local userId = if typeof(player) == "Instance" then player.UserId else player
	local shop = shops[shopName]
	local item = shop and shop.items[itemId]
	
	if not shop then
		return false, "Shop not found: " .. shopName
	end
	
	if not item then
		return false, "Item not found: " .. itemId
	end
	
	local profile = ProfileService:GetProfile(userId)
	if not profile then
		return false, "Player profile not found"
	end
	
	-- Check if player has enough currency
	local currencyField = shop.currency
	local playerCurrency = profile[currencyField]
	
	if not playerCurrency or playerCurrency < item.price then
		return false, "Insufficient " .. currencyField
	end
	
	-- Deduct currency
	profile[currencyField] = profile[currencyField] - item.price
	
	-- Add item to inventory
	if not profile.Inventory then
		profile.Inventory = {}
	end
	
	if not profile.Inventory[itemId] then
		profile.Inventory[itemId] = {
			id = itemId,
			name = item.name,
			quantity = 0,
		}
	end
	
	profile.Inventory[itemId].quantity = profile.Inventory[itemId].quantity + 1
	
	-- Fire purchase signal
	if shop.PurchasedSignal then
		shop.PurchasedSignal:Fire(userId, itemId, item.price)
	end
	
	return true, "Purchase successful"
end

--[[
	ListAllShops
	Gets all registered shops
	
	@return table of shop names
]]
function ShopService:ListAllShops()
	local shopList = {}
	for shopName, _ in pairs(shops) do
		table.insert(shopList, shopName)
	end
	return shopList
end

return ShopService
