-- PurchaseHandler.server.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Templates = ReplicatedStorage:WaitForChild("Templates")
local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local purchaseEvent = remoteFolder:WaitForChild("Purchase")
local Economy = require(script.Parent.Modules:WaitForChild("Economy"))

local COSTS = {
    Generator = 100,
}
local COST_MULT = 2.0

local function findBuildSpot(name)
    local spots = Workspace:FindFirstChild("BuildSpots")
    if not spots then return nil end
    return spots:FindFirstChild(name)
end

purchaseEvent.OnServerEvent:Connect(function(player, itemType, buildSpotName)
    if typeof(itemType) ~= "string" then return end

    -- Special client helper: user clicked purchase without selecting a spot
    if itemType == "RequestSelect" then
        purchaseEvent:FireClient(player, "PurchaseFailed", "SelectSpot")
        return
    end

    local cost = COSTS[itemType] or 0

    -- Validate build spot
    local spot = nil
    if buildSpotName and typeof(buildSpotName) == "string" then
        spot = findBuildSpot(buildSpotName)
    end
    if not spot then
        purchaseEvent:FireClient(player, "PurchaseFailed", "InvalidSpot")
        return
    end

    -- Prevent double-placing by checking an attribute on the spot
    if spot:GetAttribute("Occupied") then
        purchaseEvent:FireClient(player, "PurchaseFailed", "Occupied")
        return
    end

    -- Determine number of existing generators owned by player (count both Bases and BuildSpots)
    local function countOwnedGenerators()
        local count = 0
        local bases = Workspace:FindFirstChild("Bases")
        if bases then
            for _, v in pairs(bases:GetChildren()) do
                if v:IsA("Model") and v.Name == "Generator" then
                    local ownerVal = v:FindFirstChild("OwnerUserId")
                    if ownerVal and tostring(ownerVal.Value) == tostring(player.UserId) then
                        count = count + 1
                    end
                end
            end
        end
        local spots = Workspace:FindFirstChild("BuildSpots")
        if spots then
            for _, s in pairs(spots:GetChildren()) do
                local owner = s:FindFirstChild("OwnerUserId")
                if owner and tostring(owner.Value) == tostring(player.UserId) then
                    count = count + 1
                end
            end
        end
        return count
    end

    local ownedCount = countOwnedGenerators()

    -- Compute dynamic exponential cost
    local baseCost = COSTS[itemType] or 0
    local computedCost = math.floor(baseCost * (COST_MULT ^ ownedCount) + 0.5)

    local ls = player:FindFirstChild("leaderstats")
    local money = ls and ls:FindFirstChild("Money")
    if not money then
        purchaseEvent:FireClient(player, "PurchaseFailed", "NoLeaderstats")
        return
    end
    if money.Value < computedCost then
        purchaseEvent:FireClient(player, "PurchaseFailed", "InsufficientBalance", computedCost)
        return
    end

    -- Deduct cost
    money.Value = money.Value - computedCost

    -- Instead of spawning a separate generator model, mark the build spot as owned
    -- and attach OwnerUserId/Production/TickTime values to the spot itself.
    -- ownedCount already computed above (counts Bases and BuildSpots)

    -- Attach owner and production values to the spot itself
    local function ensureChildValue(parent, className, name)
        local v = parent:FindFirstChild(name)
        if not v then
            v = Instance.new(className)
            v.Name = name
            v.Parent = parent
        end
        return v
    end

    local owner = ensureChildValue(spot, "StringValue", "OwnerUserId")
    owner.Value = tostring(player.UserId)

    -- Production scaling (server-side)
    local baseProd = 10
    local prodMult = 1.25
    local prodVal = ensureChildValue(spot, "NumberValue", "Production")
    prodVal.Value = math.floor(baseProd * (prodMult ^ ownedCount) + 0.5)

    local tickVal = ensureChildValue(spot, "NumberValue", "TickTime")
    tickVal.Value = 1

    -- mark spot occupied
    spot:SetAttribute("Occupied", true)
    -- change spot visuals to purchased color (green)
    local purchasedColor = Color3.fromRGB(92, 165, 36)
    if spot:IsA("BasePart") then
        -- store original color/transparency if not stored
        if not spot:GetAttribute("OrigR") then
            spot:SetAttribute("OrigR", spot.Color.r)
            spot:SetAttribute("OrigG", spot.Color.g)
            spot:SetAttribute("OrigB", spot.Color.b)
        end
        spot.Color = purchasedColor
        -- do not modify transparency or collision
    elseif spot:IsA("Model") then
        if not spot:GetAttribute("OrigR") then
            local sample = spot.PrimaryPart or spot:FindFirstChildWhichIsA("BasePart")
            if sample then
                spot:SetAttribute("OrigR", sample.Color.r)
                spot:SetAttribute("OrigG", sample.Color.g)
                spot:SetAttribute("OrigB", sample.Color.b)
            end
        end
        for _, part in ipairs(spot:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Color = purchasedColor
                -- do not modify transparency or collision
            end
        end
    end

    -- unlock next spot if present (by numeric suffix)
    local function unlockNextSpot(spotName)
        if not spotName then return end
        local prefix, num = tostring(spotName):match("^(.-)%s*(%d+)%s*$")
        if not num then
            -- fallback: try common patterns
            num = tostring(spotName):match("(%d+)")
            prefix = tostring(spotName):gsub("%s*%d+%s*$","")
        end
        if not num then return end
        local nextNum = tonumber(num) + 1
        local candidates = {
            prefix .. tostring(nextNum),
            prefix .. " " .. tostring(nextNum),
            "Spot" .. tostring(nextNum),
            "spot" .. tostring(nextNum),
            "Spot " .. tostring(nextNum),
        }
        for _, name in ipairs(candidates) do
            local s = findBuildSpot(name)
            if s then
                -- restore original transparency and enable collision
                local origT = s:GetAttribute("OrigTransparency")
                if s:IsA("BasePart") then
                    if origT then s.Transparency = origT else s.Transparency = 0 end
                    s.CanCollide = true
                elseif s:IsA("Model") then
                    for _, part in ipairs(s:GetDescendants()) do
                        if part:IsA("BasePart") then
                            if origT then part.Transparency = origT else part.Transparency = 0 end
                            part.CanCollide = true
                        end
                    end
                end
                s:SetAttribute("Hidden", false)
                return
            end
        end
    end

    unlockNextSpot(spot.Name)

    purchaseEvent:FireClient(player, "PurchaseSuccess", itemType, spot.Name, computedCost)
end)

print("PurchaseHandler: initialized")
