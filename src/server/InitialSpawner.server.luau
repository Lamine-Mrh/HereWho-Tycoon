<<<<<<< HEAD
-- InitialSpawner.server.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Templates = ReplicatedStorage:FindFirstChild("Templates")
if not Templates then
    warn("InitialSpawner: ReplicatedStorage.Templates missing")
    return
end
local genTpl = Templates:FindFirstChild("Generator")
if not genTpl then
    warn("InitialSpawner: Generator template missing in ReplicatedStorage.Templates")
end

local function ensureBases()
    local bases = Workspace:FindFirstChild("Bases")
    if not bases then
        bases = Instance.new("Folder")
        bases.Name = "Bases"
        bases.Parent = Workspace
    end
    return bases
end

Players.PlayerAdded:Connect(function(player)
    wait(0.5)
    if not genTpl then return end
    local bases = ensureBases()

    -- Spawn one starter generator
    local starter = genTpl:Clone()
    starter.Name = "Generator"

    local owner = starter:FindFirstChild("OwnerUserId")
    if not owner then
        owner = Instance.new("StringValue")
        owner.Name = "OwnerUserId"
        owner.Parent = starter
    end
    owner.Value = tostring(player.UserId)

    -- ensure production values exist
    if not starter:FindFirstChild("Production") then
        local p = Instance.new("NumberValue")
        p.Name = "Production"
        p.Value = 5
        p.Parent = starter
    end
    if not starter:FindFirstChild("TickTime") then
        local t = Instance.new("NumberValue")
        t.Name = "TickTime"
        t.Value = 1
        t.Parent = starter
    end

    -- place starter in Bases folder at fixed coords
    starter.Parent = bases
    if starter:FindFirstChild("Base") then
        starter.PrimaryPart = starter.Base
        starter:SetPrimaryPartCFrame(CFrame.new(-13, 0.5, -11))
    end

    print("InitialSpawner: spawned starter generator for", player.Name)
end)

print("InitialSpawner: initialized")
=======
-- InitialSpawner.server.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Templates = ReplicatedStorage:FindFirstChild("Templates")
if not Templates then
    warn("InitialSpawner: ReplicatedStorage.Templates missing")
    return
end
local genTpl = Templates:FindFirstChild("Generator")
if not genTpl then
    warn("InitialSpawner: Generator template missing in ReplicatedStorage.Templates")
end

local function ensureBases()
    local bases = Workspace:FindFirstChild("Bases")
    if not bases then
        bases = Instance.new("Folder")
        bases.Name = "Bases"
        bases.Parent = Workspace
    end
    return bases
end

Players.PlayerAdded:Connect(function(player)
    wait(0.5)
    if not genTpl then return end
    local bases = ensureBases()

    -- Spawn one starter generator
    local starter = genTpl:Clone()
    starter.Name = "Generator"

    local owner = starter:FindFirstChild("OwnerUserId")
    if not owner then
        owner = Instance.new("StringValue")
        owner.Name = "OwnerUserId"
        owner.Parent = starter
    end
    owner.Value = tostring(player.UserId)

    -- ensure production values exist
    if not starter:FindFirstChild("Production") then
        local p = Instance.new("NumberValue")
        p.Name = "Production"
        p.Value = 5
        p.Parent = starter
    end
    if not starter:FindFirstChild("TickTime") then
        local t = Instance.new("NumberValue")
        t.Name = "TickTime"
        t.Value = 1
        t.Parent = starter
    end

    -- place starter in Bases folder at fixed coords
    starter.Parent = bases
    if starter:FindFirstChild("Base") then
        starter.PrimaryPart = starter.Base
        starter:SetPrimaryPartCFrame(CFrame.new(-13, 0.5, -11))
    end

    print("InitialSpawner: spawned starter generator for", player.Name)
end)

print("InitialSpawner: initialized")
>>>>>>> 26a6f9e (here who)
