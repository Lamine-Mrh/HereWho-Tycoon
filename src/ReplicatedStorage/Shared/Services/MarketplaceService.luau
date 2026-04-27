--[[
	MarketplaceService - Game passes and developer products
	Handles in-game purchases, game passes, and developer products
--]]

local MarketplaceService = {}
local RobloxMarketplaceService = game:GetService("MarketplaceService")
local ProfileService = require(script.Parent:WaitForChild("ProfileService"))
local RunService = game:GetService("RunService")

if not RunService:IsServer() then
	error("MarketplaceService can only be used on the server!")
end

-- Product database
local products = {}
local purchaseCallbacks = {}

--[[
	RegisterGamePass
	Registers a game pass for tracking
	
	@param productId (number) - Roblox game pass ID
	@param productData (table) - Product info {name, description, price, ...}
]]
function MarketplaceService:RegisterGamePass(productId: number, productData: {[any]: any})
	assert(productId, "productId is required")
	assert(productData, "productData is required")
	
	products[productId] = {
		id = productId,
		type = "GamePass",
		name = productData.name or "Unknown Pass",
		description = productData.description or "",
		price = productData.price or 0,
		custom = productData.custom or {},
	}
	
	print("Registered game pass:", productId, "-", products[productId].name)
end

--[[
	RegisterDeveloperProduct
	Registers a developer product for tracking
	
	@param productId (number) - Roblox developer product ID
	@param productData (table) - Product info {name, description, ...}
]]
function MarketplaceService:RegisterDeveloperProduct(productId: number, productData: {[any]: any})
	assert(productId, "productId is required")
	assert(productData, "productData is required")
	
	products[productId] = {
		id = productId,
		type = "DeveloperProduct",
		name = productData.name or "Unknown Product",
		description = productData.description or "",
		custom = productData.custom or {},
	}
	
	print("Registered developer product:", productId, "-", products[productId].name)
end

--[[
	GetProductInfo
	Gets information about a product
	
	@param productId (number) - Product ID
	@return product data or nil
]]
function MarketplaceService:GetProductInfo(productId: number)
	return products[productId]
end

--[[
	ListProducts
	Gets all registered products
	
	@return table of products
]]
function MarketplaceService:ListProducts()
	return products
end

--[[
	ProcessGamePassPurchase
	Handles game pass purchase rewards
	
	@param userId (number) - Player's UserId
	@param gamePassId (number) - Game pass ID
	@param rewardFunction (function) - Function to execute on purchase
]]
function MarketplaceService:ProcessGamePassPurchase(userId: number, gamePassId: number, rewardFunction: (any) -> ())
	assert(userId, "userId is required")
	assert(gamePassId, "gamePassId is required")
	
	local profile = ProfileService:GetProfile(userId)
	if not profile then
		warn("Profile not found for UserId:", userId)
		return false
	end
	
	local product = products[gamePassId]
	if not product then
		warn("Product not found:", gamePassId)
		return false
	end
	
	-- Execute reward function
	if rewardFunction then
		task.spawn(function()
			rewardFunction(profile)
		end)
	end
	
	return true
end

--[[
	ProcessDeveloperProductPurchase
	Handles developer product purchase rewards
	
	@param userId (number) - Player's UserId
	@param productId (number) - Developer product ID
	@param rewardFunction (function) - Function to execute on purchase
]]
function MarketplaceService:ProcessDeveloperProductPurchase(userId: number, productId: number, rewardFunction: (any) -> ())
	assert(userId, "userId is required")
	assert(productId, "productId is required")
	
	local profile = ProfileService:GetProfile(userId)
	if not profile then
		warn("Profile not found for UserId:", userId)
		return false
	end
	
	local product = products[productId]
	if not product then
		warn("Product not found:", productId)
		return false
	end
	
	-- Execute reward function
	if rewardFunction then
		task.spawn(function()
			rewardFunction(profile)
		end)
	end
	
	return true
end

--[[
	PromptGamePassPurchase
	Prompts a player to purchase a game pass
	
	@param player - Player object
	@param gamePassId (number) - Game pass ID
]]
function MarketplaceService:PromptGamePassPurchase(player, gamePassId: number)
	assert(gamePassId, "gamePassId is required")
	
	-- This is a client-side operation, so we'll return a guide
	warn("PromptGamePassPurchase should be called from client scripts using RemoteFunction")
end

--[[
	PromptDeveloperProductPurchase
	Prompts a player to purchase a developer product
	
	@param player - Player object
	@param productId (number) - Product ID
]]
function MarketplaceService:PromptDeveloperProductPurchase(player, productId: number)
	assert(productId, "productId is required")
	
	-- This is a client-side operation, so we'll return a guide
	warn("PromptDeveloperProductPurchase should be called from client scripts using RemoteFunction")
end

return MarketplaceService
