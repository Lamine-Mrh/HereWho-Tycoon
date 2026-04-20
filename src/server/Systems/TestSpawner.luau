<<<<<<< HEAD
-- ServerScriptService/Systems/TestSpawner
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local tpl = ReplicatedStorage:WaitForChild("Templates"):WaitForChild("Generator")

Players.PlayerAdded:Connect(function(player)
    wait(1)
    local gen = tpl:Clone()
    gen.Name = "Generator"

    -- Ensure OwnerUserId exists and set it
    local owner = gen:FindFirstChild("OwnerUserId")
    if not owner then
        owner = Instance.new("StringValue")
        owner.Name = "OwnerUserId"
        owner.Parent = gen
    end
    owner.Value = tostring(player.UserId)

    -- Ensure Production and TickTime exist
    if not gen:FindFirstChild("Production") then
        local p = Instance.new("NumberValue")
        p.Name = "Production"
        p.Value = 5
        p.Parent = gen
    end
    if not gen:FindFirstChild("TickTime") then
        local t = Instance.new("NumberValue")
        t.Name = "TickTime"
        t.Value = 1
        t.Parent = gen
    end

    -- Ensure Base part exists and set PrimaryPart
    local base = gen:FindFirstChild("Base")
    if base and not gen.PrimaryPart then
        gen.PrimaryPart = base
    end

    -- Parent to Workspace.Bases (create folder if missing)
    local bases = Workspace:FindFirstChild("Bases")
    if not bases then
        bases = Instance.new("Folder")
        bases.Name = "Bases"
        bases.Parent = Workspace
    end
    gen.Parent = bases

    -- Place it somewhere visible
    if gen.PrimaryPart then
        gen:SetPrimaryPartCFrame(CFrame.new(0, 5 + (#bases:GetChildren() * 6), 0))
    end

    print("TestSpawner: spawned generator for", player.Name, "OwnerUserId:", owner.Value)
=======
-- ServerScriptService/Systems/TestSpawner
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local tpl = ReplicatedStorage:WaitForChild("Templates"):WaitForChild("Generator")

Players.PlayerAdded:Connect(function(player)
    wait(1)
    local gen = tpl:Clone()
    gen.Name = "Generator"

    -- Ensure OwnerUserId exists and set it
    local owner = gen:FindFirstChild("OwnerUserId")
    if not owner then
        owner = Instance.new("StringValue")
        owner.Name = "OwnerUserId"
        owner.Parent = gen
    end
    owner.Value = tostring(player.UserId)

    -- Ensure Production and TickTime exist
    if not gen:FindFirstChild("Production") then
        local p = Instance.new("NumberValue")
        p.Name = "Production"
        p.Value = 5
        p.Parent = gen
    end
    if not gen:FindFirstChild("TickTime") then
        local t = Instance.new("NumberValue")
        t.Name = "TickTime"
        t.Value = 1
        t.Parent = gen
    end

    -- Ensure Base part exists and set PrimaryPart
    local base = gen:FindFirstChild("Base")
    if base and not gen.PrimaryPart then
        gen.PrimaryPart = base
    end

    -- Parent to Workspace.Bases (create folder if missing)
    local bases = Workspace:FindFirstChild("Bases")
    if not bases then
        bases = Instance.new("Folder")
        bases.Name = "Bases"
        bases.Parent = Workspace
    end
    gen.Parent = bases

    -- Place it somewhere visible
    if gen.PrimaryPart then
        gen:SetPrimaryPartCFrame(CFrame.new(0, 5 + (#bases:GetChildren() * 6), 0))
    end

    print("TestSpawner: spawned generator for", player.Name, "OwnerUserId:", owner.Value)
>>>>>>> 26a6f9e (here who)
end)