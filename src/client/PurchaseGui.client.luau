-- PurchaseGui.client.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local purchaseEvent = remoteFolder:WaitForChild("Purchase")

-- Remove any existing stale GUI named PurchaseGui
local pg = player:FindFirstChild("PlayerGui")
if pg then
    local existing = pg:FindFirstChild("PurchaseGui")
    if existing then existing:Destroy() end
end

-- Create a clean ScreenGui and frame
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PurchaseGui"
screenGui.ResetOnSpawn = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 120)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundTransparency = 0.35
frame.Parent = screenGui
frame.Visible = false

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 24)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "Build Menu"
title.Parent = frame

local selectionLabel = Instance.new("TextLabel")
selectionLabel.Size = UDim2.new(1, -10, 0, 22)
selectionLabel.Position = UDim2.new(0, 5, 0, 28)
selectionLabel.Text = ""
selectionLabel.TextXAlignment = Enum.TextXAlignment.Left
selectionLabel.Visible = false
selectionLabel.BackgroundTransparency = 1
selectionLabel.Parent = frame

local priceLabel = Instance.new("TextLabel")
priceLabel.Size = UDim2.new(1, -10, 0, 22)
priceLabel.Position = UDim2.new(0, 5, 0, 54)
priceLabel.Text = ""
priceLabel.TextXAlignment = Enum.TextXAlignment.Left
priceLabel.Visible = false
priceLabel.BackgroundTransparency = 1
priceLabel.Parent = frame

local msgLabel = Instance.new("TextLabel")
msgLabel.Size = UDim2.new(1, -10, 0, 18)
msgLabel.Position = UDim2.new(0, 5, 0, 80)
msgLabel.Text = ""
msgLabel.TextXAlignment = Enum.TextXAlignment.Left
msgLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
msgLabel.BackgroundTransparency = 1
msgLabel.Parent = frame

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 110, 0, 28)
btn.Position = UDim2.new(1, -120, 0, 84)
btn.Text = "Purchase"
btn.Active = false
btn.AutoButtonColor = false
btn.Visible = true
btn.Parent = frame

local selectedSpot = nil
local previousSpot = nil
local BASE_COST = 100
local COST_MULT = 2.0
local function getOwnedCount()
    local count = 0
    local bases = workspace:FindFirstChild("Bases")
    if not bases then return 0 end
    for _, v in pairs(bases:GetChildren()) do
        if v:IsA("Model") and v.Name == "Generator" then
            local owner = v:FindFirstChild("OwnerUserId")
            if owner and tostring(owner.Value) == tostring(player.UserId) then
                count = count + 1
            end
        end
    end
    return count
end
-- Also count owned build spots (when server attaches OwnerUserId to spots)
local function getOwnedCountAll()
    local count = getOwnedCount()
    local spotFolder = workspace:FindFirstChild("BuildSpots")
    if spotFolder then
        for _, sp in ipairs(spotFolder:GetChildren()) do
            local owner = sp:FindFirstChild("OwnerUserId")
            if owner and tostring(owner.Value) == tostring(player.UserId) then
                count = count + 1
            end
        end
    end
    return count
end

local function computeCost()
    local n = getOwnedCountAll()
    local cost = math.floor(BASE_COST * (COST_MULT ^ n) + 0.5)
    return cost
end

local function updateInfo()
    -- info used for messages; selection/price labels handle selection display
    if selectedSpot then
        selectionLabel.Visible = true
        selectionLabel.Text = "Selected: " .. selectedSpot
        priceLabel.Visible = true
        priceLabel.Text = ("Price: %d"):format(computeCost())
        btn.Active = true
        btn.AutoButtonColor = true
        btn.Text = "Buy"
        frame.Visible = true
    else
        selectionLabel.Visible = false
        priceLabel.Visible = false
        btn.Active = false
        btn.AutoButtonColor = false
        btn.Text = "Purchase"
        frame.Visible = false
    end
    msgLabel.Text = ""
end

local function updateCostText()
    updateInfo()
end

-- update when bases change
local basesFolder = workspace:FindFirstChild("Bases")
if basesFolder then
    basesFolder.ChildAdded:Connect(updateCostText)
    basesFolder.ChildRemoved:Connect(updateCostText)
end
updateCostText()

-- (moved earlier) updateInfo is defined above to avoid nil-call

-- click to select build spot
-- click to select build spot (with debug prints and visual highlight)
local selectionBox = Instance.new("SelectionBox")
selectionBox.LineThickness = 0.02
selectionBox.SurfaceColor3 = Color3.fromRGB(0, 170, 255)
selectionBox.SurfaceTransparency = 0.7

local OCC_COLOR = Color3.fromRGB(140, 140, 140)

local function setSpotOccupiedVisual(spotObj)
    -- Do not override server-side purchased color. Keep client-side handling minimal.
    if not spotObj then return end
    -- remove selection if this was selected
    if previousSpot == spotObj then
        selectionBox.Parent = nil
        selectedSpot = nil
        previousSpot = nil
        updateInfo()
    end
end

local function restoreSpotVisual(spotObj)
    if not spotObj then return end
    local r = spotObj:GetAttribute("OrigR")
    local g = spotObj:GetAttribute("OrigG")
    local b = spotObj:GetAttribute("OrigB")
    local t = spotObj:GetAttribute("OrigTransparency")
    if r and g and b then
        if spotObj:IsA("BasePart") then
            spotObj.Color = Color3.new(r, g, b)
        elseif spotObj:IsA("Model") then
            for _, part in ipairs(spotObj:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Color = Color3.new(r, g, b)
                end
            end
        end
    end
end

local function hookSpot(spotObj)
    if not spotObj then return end
    -- initial occupied state
    if spotObj:GetAttribute("Occupied") then
        setSpotOccupiedVisual(spotObj)
    end
    -- listen for occupied changes
    pcall(function()
        spotObj:GetAttributeChangedSignal("Occupied"):Connect(function()
            local occ = spotObj:GetAttribute("Occupied")
            if occ then
                -- clear selection if this was selected
                if previousSpot == spotObj then
                    selectionBox.Parent = nil
                    selectedSpot = nil
                    previousSpot = nil
                    updateInfo()
                end
                setSpotOccupiedVisual(spotObj)
            else
                restoreSpotVisual(spotObj)
            end
            updateCostText()
        end)
    end)
end

-- hook existing build spots and future ones
local spotFolder = workspace:FindFirstChild("BuildSpots")
if spotFolder then
    for _, sp in ipairs(spotFolder:GetChildren()) do
        hookSpot(sp)
    end
    spotFolder.ChildAdded:Connect(function(child)
        hookSpot(child)
    end)
end

mouse.Button1Down:Connect(function()
    local target = mouse.Target
    print("PurchaseGui: Mouse clicked. target=", target and target.Name or "nil")
    local spotFolder = workspace:FindFirstChild("BuildSpots")
    if not spotFolder then
        print("PurchaseGui: BuildSpots folder missing in workspace")
        return
    end

    local function clearSelection()
        if previousSpot then
            restoreSpotVisual(previousSpot)
        end
        selectionBox.Parent = nil
        selectedSpot = nil
        previousSpot = nil
        updateInfo()
    end

    if not target then
        print("PurchaseGui: click had no target - clearing selection")
        clearSelection()
        return
    end

    -- Accept either clicking the part itself or a child of a Model under BuildSpots
    if target:IsDescendantOf(spotFolder) then
        -- find the top-level child under BuildSpots
        local current = target
        while current.Parent and current.Parent ~= spotFolder do
            current = current.Parent
        end
        if current.Parent == spotFolder then
            selectedSpot = current.Name
            -- don't select if occupied
            local spotObj = spotFolder:FindFirstChild(selectedSpot)
            if spotObj and spotObj:GetAttribute("Occupied") then
                msgLabel.Text = "Spot is already purchased"
                print("PurchaseGui: spot is occupied, can't select")
                selectedSpot = nil
                return
            end
            if spotObj and spotObj:GetAttribute("Hidden") then
                msgLabel.Text = "Locked — unlock the previous spot first"
                print("PurchaseGui: spot is hidden/locked, can't select")
                selectedSpot = nil
                return
            end
            updateInfo()
            print("PurchaseGui: selected spot =", selectedSpot)

            -- highlight the selected spot and change its color
            selectionBox.Adornee = nil
            local spotObj = spotFolder:FindFirstChild(selectedSpot)
            if spotObj then
                -- restore previous spot color
                if previousSpot and previousSpot ~= spotObj and previousSpot.Parent then
                    -- restore stored original color attributes if present
                    local r = previousSpot:GetAttribute("OrigR")
                    local g = previousSpot:GetAttribute("OrigG")
                    local b = previousSpot:GetAttribute("OrigB")
                    if r and g and b then
                        if previousSpot:IsA("BasePart") then
                            previousSpot.Color = Color3.new(r, g, b)
                        elseif previousSpot:IsA("Model") then
                            for _, part in ipairs(previousSpot:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Color = Color3.new(r, g, b)
                                end
                            end
                        end
                    end
                end

                local adornTarget = nil
                if spotObj:IsA("BasePart") then
                    adornTarget = spotObj
                elseif spotObj:IsA("Model") then
                    adornTarget = spotObj.PrimaryPart or spotObj:FindFirstChildWhichIsA("BasePart")
                end
                if adornTarget then
                    selectionBox.Adornee = adornTarget
                    selectionBox.Parent = workspace
                else
                    selectionBox.Parent = nil
                end

                    -- store original color attributes on the spot if not present
                    if not spotObj:GetAttribute("OrigR") then
                        local samplePart = adornTarget
                        if samplePart then
                            spotObj:SetAttribute("OrigR", samplePart.Color.r)
                            spotObj:SetAttribute("OrigG", samplePart.Color.g)
                            spotObj:SetAttribute("OrigB", samplePart.Color.b)
                        end
                    end

                -- change color to selected (bright green)
                local selColor = Color3.fromRGB(0, 255, 128)
                if spotObj:IsA("BasePart") then
                    spotObj.Color = selColor
                elseif spotObj:IsA("Model") then
                    for _, part in ipairs(spotObj:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Color = selColor
                        end
                    end
                end
                previousSpot = spotObj
            end
        end
    else
        print("PurchaseGui: clicked object is not under BuildSpots (", target:GetFullName(), ") - clearing selection")
        clearSelection()
    end
end)

btn.MouseButton1Click:Connect(function()
    if not selectedSpot then
        purchaseEvent:FireServer("RequestSelect")
        return
    end
    purchaseEvent:FireServer("Generator", selectedSpot)
end)

-- listen to server responses
purchaseEvent.OnClientEvent:Connect(function(status, ...)
    if status == "PurchaseSuccess" then
        local itemType, spotName = ...
        msgLabel.Text = ("Placed %s at %s"):format(itemType, spotName)
        -- clear selection and UI
        selectedSpot = nil
        previousSpot = nil
        selectionBox.Parent = nil
        updateCostText()
        updateInfo()
    elseif status == "PurchaseFailed" then
        local reason, extra = ...
        if reason == "InsufficientBalance" and extra then
            msgLabel.Text = ("Purchase failed: Need %d"):format(extra)
        elseif reason == "SelectSpot" then
            msgLabel.Text = "Purchase failed: Select a spot first"
        elseif reason == "Occupied" then
            msgLabel.Text = "Purchase failed: Spot occupied"
        else
            msgLabel.Text = ("Purchase failed: %s"):format(tostring(reason))
        end
    end
end)

print("PurchaseGui: initialized")
