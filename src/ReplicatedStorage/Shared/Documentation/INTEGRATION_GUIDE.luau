--[[
        INTEGRATION GUIDE - Shared Services System

        This guide explains how to integrate the Shared Services system into your
        Roblox Tycoon/Tower Defence game.

        TABLE OF CONTENTS:
        1. Project Structure
        2. Getting Started
        3. Service Overview
        4. Integration Steps
        5. Common Patterns
        6. Troubleshooting
]]

-- =====================================================================
-- 1. PROJECT STRUCTURE
-- =====================================================================

--[[
ReplicatedStorage/
├── Shared/
│   ├── SharedServices.luau          (Main module - import this)
│   ├── SharedConfig.luau            (Configuration for all services)
│   ├── README.luau                  (Service documentation)
│   └── Services/
│       ├── DataStoreService.luau    (DataStore wrapper)
│       ├── ProfileService.luau      (Player profiles & progression)
│       ├── LeaderboardService.luau  (Leaderboards)
│       ├── ShopService.luau         (Shop system)
│       ├── DonationService.luau     (Player donations)
│       └── MarketplaceService.luau  (Game passes & dev products)

ServerScriptService/
├── SharedServicesInit.server.luau   (Initializes all services)
├── RemoteFunctionsSetup.server.luau (Client-server communication)
└── ... (your existing scripts)

StarterPlayer/
└── StarterPlayerScripts/
        ├── ClientServicesExample.client.luau (Client-side examples)
        └── ... (your existing scripts)
]]

-- =====================================================================
-- 2. GETTING STARTED
-- =====================================================================

--[[
STEP 1: Verify Files Are In Place
- Check that the Shared folder exists in ReplicatedStorage
- Verify all service files are present

STEP 2: Update SharedConfig
- Edit ReplicatedStorage/Shared/SharedConfig.luau
- Set real Roblox Game Pass IDs and Developer Product IDs
- Customize shop items and leaderboards for your game

STEP 3: Add Initialization Scripts
- Run SharedServicesInit.server.luau (already in ServerScriptService)
- Run RemoteFunctionsSetup.server.luau (already in ServerScriptService)

STEP 4: Test in Studio
- Start the server
- Check console for initialization messages
- Test with a player to verify profile loading

STEP 5: Integrate Into Your Code
- Replace existing data-saving code with SharedServices calls
- Use RemoteFunctions for client-server communication
- Reference examples in this file and README.luau
]]

-- =====================================================================
-- 3. SERVICE OVERVIEW
-- =====================================================================

--[[
ProfileService:
    Handles player character progression, money, levels, and inventory
  
    Key Functions:
        LoadProfile(player) - Load or create profile
        SaveProfile(player) - Save to DataStore
        AddMoney(player, amount) - Add money with calculation
        AddExperience(player, amount) - Add XP with level-up logic
        UpdateProfileField(player, field, value) - Direct field access
    
    Profile Structure:
        {
            Money = 0,
            Level = 1,
            Experience = 0,
            PlayTime = 0,
            Inventory = {},
            Statistics = { TowersPlaced, MoneyEarned, ... },
            Settings = { MusicVolume, SoundVolume, ... },
        }

DataStoreService:
    Wrapper around Roblox DataStore with retry logic
  
    Key Functions:
        GetDataStore(storeName) - Get or create DataStore
        LoadPlayerData(dataStore, key) - Load with retries
        SavePlayerData(dataStore, key, data) - Save with retries
        IncrementValue(dataStore, key, amount) - Atomic increment
        RemoveKey(dataStore, key) - Delete key

LeaderboardService:
    Track and manage leaderboards (money, level, playtime, etc.)
  
    Key Functions:
        RegisterLeaderboard(name, sortDescending) - Create leaderboard
        UpdateLeaderboardEntry(name, userId, playerName, score) - Add/update entry
        GetLeaderboard(name, limit) - Get top N players
        GetPlayerRank(name, userId) - Get specific rank
        SaveLeaderboards() - Persist to DataStore

ShopService:
    In-game shop system for purchasing items with in-game currency
  
    Key Functions:
        RegisterShop(name, shopData) - Create shop
        AddItemToShop(shopName, itemId, itemData) - Add items
        PurchaseItem(player, shopName, itemId) - Handle purchase
        GetShopItems(shopName) - List shop items
    
    Features:
        - Multiple shops with different currencies
        - Purchase signals for rewards/effects
        - Automatic inventory management
        - Configurable item data

DonationService:
    Player-to-player donations and gifting
  
    Key Functions:
        DonateToPlayer(fromId, toId, amount) - Send donation
        GetDonationHistory(userId) - View received donations
        GetTotalDonationsReceived(userId) - Total donations count
    
    Features:
        - Persistent donation history
        - Validation and currency checks
        - Tax system support

MarketplaceService:
    Integration with Roblox game passes and developer products
  
    Key Functions:
        RegisterGamePass(id, data) - Register pass
        RegisterDeveloperProduct(id, data) - Register product
        ProcessGamePassPurchase(userId, passId, rewardFn) - Handle rewards
        ProcessDeveloperProductPurchase(userId, productId, rewardFn) - Handle rewards
    
    Features:
        - Automatic product registration
        - Custom reward functions
        - Purchase tracking
]]

-- =====================================================================
-- 4. INTEGRATION STEPS
-- =====================================================================

--[[
STEP 1: Connect Existing Systems to ProfileService

BEFORE (your current Economy.luau):
    function Economy.AddMoney(player, amount)
            local ls = player:FindFirstChild("leaderstats")
            if ls then
                    local money = ls:FindFirstChild("Money")
                    if money then
                            money.Value = money.Value + amount
                    end
            end
    end

AFTER (using SharedServices):
    local SharedServices = require(game.ReplicatedStorage.Shared.SharedServices)
  
    function Economy.AddMoney(player, amount)
            SharedServices.Profile:AddMoney(player, amount)
    end

---

STEP 2: Replace DataStore Calls

BEFORE:
    local DataStore = game:GetService("DataStoreService"):GetDataStore("PlayerData")
    local success, data = pcall(function()
            return DataStore:GetAsync("player_" .. player.UserId)
    end)

AFTER:
    local SharedServices = require(game.ReplicatedStorage.Shared.SharedServices)
    local DataStore = SharedServices.DataStore:GetDataStore("PlayerData")
    local data = SharedServices.DataStore:LoadPlayerData(DataStore, "player_" .. player.UserId)

---

STEP 3: Setup Client-Server Communication

SCENARIO: Client wants to purchase an item from shop

CLIENT SIDE:
    local PurchaseRemote = game.ReplicatedStorage:WaitForChild("PurchaseItemRemote")
    local success, message = PurchaseRemote:InvokeServer("MainShop", "tower_basic")

SERVER SIDE:
    -- Already created in RemoteFunctionsSetup.server.luau
    -- No additional setup needed!

---

STEP 4: Add Shop System to Your Game

1. Update SharedConfig.luau with your shop items
2. In RemoteFunctionsSetup.server.luau, add new RemoteFunctions as needed:
   
     createRemoteFunction("MyCustomFunction", function(player, arg1, arg2)
             -- Use SharedServices here
             return result
     end)

3. Call from client scripts using RemoteFunctions
]]

-- =====================================================================
-- 5. COMMON PATTERNS
-- =====================================================================

--[[
PATTERN 1: Increase Money from Different Sources

    local SharedServices = require(game.ReplicatedStorage.Shared.SharedServices)
  
    -- From tower sales
    SharedServices.Profile:AddMoney(player, 100)
  
    -- From level rewards
    SharedServices.Profile:AddMoney(player, 500)
  
    -- Direct profile access (emergency)
    local profile = SharedServices.Profile:GetProfile(player)
    profile.Money = profile.Money + 1000

---

PATTERN 2: Handle Purchase Events

    local SharedServices = require(game.ReplicatedStorage.Shared.SharedServices)
    local shop = SharedServices.Shop:GetShop("MainShop")
  
    shop.PurchasedSignal:Connect(function(userId, itemId, price)
            print("Player " .. userId .. " bought " .. itemId)
      
            -- Give player the tower/item
            local itemData = SharedServices.Shop:GetItem("MainShop", itemId)
            if itemData.custom.damage then
                    -- Place a tower
                    placeNewTower(userId, itemData)
            end
    end)

---

PATTERN 3: Reward System (Level Up, Quest Complete, etc.)

    local function onQuestComplete(player, questReward)
            local SharedServices = require(game.ReplicatedStorage.Shared.SharedServices)
      
            SharedServices.Profile:AddMoney(player, questReward.money)
            SharedServices.Profile:AddExperience(player, questReward.experience)
      
            -- Update leaderboards
            local profile = SharedServices.Profile:GetProfile(userId)
            SharedServices.Leaderboard:UpdateLeaderboardEntry("TopMoney", player.UserId, player.Name, profile.Money)
    end

---

PATTERN 4: Cross-Server Communication (using DataStore)

    local SharedServices = require(game.ReplicatedStorage.Shared.SharedServices)
  
    -- Server A: Save data
    local data = { player_count = 50, total_money = 100000 }
    SharedServices.Profile:SaveProfile(player) -- Saves to DataStore
  
    -- Server B: Load data
    local loaded = SharedServices.Profile:LoadProfile(player) -- Loads from DataStore

---

PATTERN 5: Admin Commands

    local function givePlayerMoney(player, amount)
            local SharedServices = require(game.ReplicatedStorage.Shared.SharedServices)
            SharedServices.Profile:AddMoney(player, amount)
            print("Gave " .. player.Name .. " $" .. amount)
    end

---

PATTERN 6: Daily Rewards

    local function claimDailyReward(player)
            local SharedServices = require(game.ReplicatedStorage.Shared.SharedServices)
            local profile = SharedServices.Profile:GetProfile(player.UserId)
      
            if not profile.LastDailyReward or tick() - profile.LastDailyReward > 86400 then
                    SharedServices.Profile:AddMoney(player, 1000)
                    profile.LastDailyReward = tick()
                    return true
            end
      
            return false, "Already claimed today"
    end
]]

-- =====================================================================
-- 6. TROUBLESHOOTING
-- =====================================================================

--[[
ISSUE: "DataStoreService can only be used on the server!"
CAUSE: Trying to use SharedServices from a LocalScript
FIX: Use RemoteFunctions to communicate from client to server
         All SharedServices calls must be on server scripts

---

ISSUE: Profile returns nil after player joins
CAUSE: Profile not loaded yet or player didn't join successfully
FIX: Ensure SharedServicesInit.server.luau runs before accessing profiles
        Use waitForChild() if loading profiles early
        Check that player is in Players:GetPlayers()

---

ISSUE: Leaderboard entries not updating
CAUSE: UpdateLeaderboardEntry not called when data changes
FIX: Call UpdateLeaderboardEntry whenever profile changes
        Check that leaderboard was registered before updating

---

ISSUE: DataStore save fails
CAUSE: DataStore quota exceeded or network error
FIX: DataStoreService includes automatic retries
        Check DataStore limits in Roblox developer console
        Reduce save frequency if too many saves

---

ISSUE: Shop purchase shows success but item not in inventory
CAUSE: Purchase logic complete but reward not implemented
FIX: Connect to PurchasedSignal to handle rewards
        Or manually give item after purchase confirmation

---

ISSUE: Game Pass rewards not applying
CAUSE: ProcessGamePassPurchase called but reward function not defined
FIX: Provide rewardFunction callback:
--]]