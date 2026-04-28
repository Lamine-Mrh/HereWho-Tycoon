--[[
    SharedConfig - Configuration module
    Contains game-wide configuration for services
]]

local SharedConfig = {}

SharedConfig.LEADERBOARDS = {
    {
        name = "TopMoney",
        sortDescending = true,
        description = "Players with the most money",
    },
    {
        name = "TopLevel",
        sortDescending = true,
        description = "Highest level players",
    },
    {
        name = "TopPlayTime",
        sortDescending = true,
        description = "Most played players",
    },
    {
        name = "TopDonations",
        sortDescending = true,
        description = "Most generous donors",
    },
}

SharedConfig.SHOPS = {
    MainShop = {
        name = "Main Shop",
        currency = "Money",
        description = "The main in-game shop",
        items = {
            tower_basic = {
                name = "Basic Tower",
                price = 100,
                description = "A basic tower for defense",
                maxStack = 999,
                custom = { damage = 10, range = 50, attackSpeed = 1 },
            },
            tower_advanced = {
                name = "Advanced Tower",
                price = 500,
                description = "A more powerful tower",
                maxStack = 999,
                custom = { damage = 25, range = 75, attackSpeed = 1.5 },
            },
            health_potion = {
                name = "Health Potion",
                price = 50,
                description = "Restores 50 health",
                maxStack = 999,
                custom = { heals = 50 },
            },
            speed_boost = {
                name = "Speed Boost",
                price = 75,
                description = "Increases movement speed temporarily",
                maxStack = 999,
                custom = { speedMultiplier = 1.5, duration = 30 },
            },
        },
    },
    PremiumShop = {
        name = "Premium Shop",
        currency = "Money",
        description = "Premium items for advanced players",
        items = {
            premium_tower = {
                name = "Premium Tower",
                price = 2000,
                description = "Ultimate defense tower",
                maxStack = 99,
                custom = { damage = 50, range = 150, attackSpeed = 2 },
            },
            legendary_weapon = {
                name = "Legendary Weapon",
                price = 5000,
                description = "Powerful legendary weapon",
                maxStack = 1,
                custom = { damage = 100, rarity = "Legendary" },
            },
        },
    },
}

SharedConfig.GAME_PASSES = {
    { id = 0, name = "2x Money Multiplier", description = "Double all money earned", price = 400, custom = { moneyMultiplier = 2 } },
    { id = 0, name = "VIP Pass", description = "Get exclusive VIP benefits", price = 800, custom = { isVIP = true, xpMultiplier = 1.5 } },
}

SharedConfig.DEVELOPER_PRODUCTS = {
    { id = 0, name = "100 Coins", benefit = "coins", amount = 100 },
    { id = 0, name = "500 Coins", benefit = "coins", amount = 500 },
    { id = 0, name = "1000 Coins + Bonus", benefit = "coins", amount = 1000, bonus = 100 },
}

SharedConfig.DONATIONS = { minAmount = 10, maxAmount = 100000, currency = "Money", allowFriendOnly = false, tax = 0.05 }

SharedConfig.PROGRESSION = { startingMoney = 0, startingLevel = 1, expPerLevel = 100, maxLevel = 100, levelUpReward = 500 }

SharedConfig.MARKETPLACE = { currencyMultipliers = { Money = 1, PremiumCurrency = 100 }, purchaseCooldown = 0.5, maxPurchasesPerSession = 1000 }

return SharedConfig
