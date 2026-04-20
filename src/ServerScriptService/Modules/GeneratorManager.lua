-- Systems/GeneratorManager
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Economy = require(script.Parent:WaitForChild("Economy"))

local function startGeneratorLoop(generatorModel)
    if not generatorModel or not generatorModel.Parent then return end
    spawn(function()
        while generatorModel.Parent do
            local tickVal = generatorModel:FindFirstChild("TickTime")
            local prodVal = generatorModel:FindFirstChild("Production")
            local ownerVal = generatorModel:FindFirstChild("OwnerUserId")
            if tickVal and prodVal and ownerVal and ownerVal.Value ~= "" then
                local ownerId = tonumber(ownerVal.Value) or tonumber(tostring(ownerVal.Value))
                if ownerId then
                    local player = Players:GetPlayerByUserId(ownerId)
                    if player then
                        Economy.AddMoney(player, prodVal.Value)
                    else
                        warn("GeneratorManager: owner player not found for id", ownerVal.Value)
                    end
                else
                    warn("GeneratorManager: invalid OwnerUserId value:", ownerVal.Value)
                end
                wait(tickVal.Value or 1)
            else
                wait(1)
            end
        end
        print("Generator loop ended for", generatorModel.Name)
    end)
end

-- Start for existing generators
local function scanExisting()
    local bases = Workspace:FindFirstChild("Bases")
    if not bases then
        warn("GeneratorManager: Workspace.Bases not found")
        return
    end
    for _, v in pairs(bases:GetChildren()) do
        if v:IsA("Model") and v.Name == "Generator" then
            startGeneratorLoop(v)
        end
    end
end

-- Listen for new generators placed at runtime
local function hookChildAdded()
    -- Ensure Bases folder exists and hook new Generator models (backwards-compat)
    local bases = Workspace:FindFirstChild("Bases")
    if not bases then
        bases = Instance.new("Folder")
        bases.Name = "Bases"
        bases.Parent = Workspace
    end
    bases.ChildAdded:Connect(function(child)
        if child:IsA("Model") and child.Name == "Generator" then
            local basePart = child:FindFirstChild("Base")
            if basePart and not child.PrimaryPart then
                child.PrimaryPart = basePart
            end
            print("GeneratorManager: new Generator detected for", child.Name)
            startGeneratorLoop(child)
        end
    end)

    -- Also scan BuildSpots for attached generator values and hook them
    local spots = Workspace:FindFirstChild("BuildSpots")
    if spots then
        for _, sp in pairs(spots:GetChildren()) do
            -- if spot already has OwnerUserId value, treat it as a generator source
            if sp:FindFirstChild("OwnerUserId") then
                startGeneratorLoop(sp)
            end
            -- listen for OwnerUserId being added later
            sp.ChildAdded:Connect(function(child)
                if child.Name == "OwnerUserId" then
                    startGeneratorLoop(sp)
                end
            end)
        end
        spots.ChildAdded:Connect(function(child)
            -- for new spots, listen for OwnerUserId value additions
            child.ChildAdded:Connect(function(ch)
                if ch.Name == "OwnerUserId" then
                    startGeneratorLoop(child)
                end
            end)
        end)
    end
end

scanExisting()
hookChildAdded()
print("GeneratorManager: initialized")

-- Return a table so require(genModule) returns one value
return {
    initialized = true,
}