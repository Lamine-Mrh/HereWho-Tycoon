<<<<<<< HEAD
-- BuildSpotsInit.server.luau
local Workspace = game:GetService("Workspace")

local function normalizeName(name)
    -- trim
    return tostring(name):gsub("^%s+",""):gsub("%s+$","")
end

local spots = Workspace:FindFirstChild("BuildSpots")
if not spots then
    warn("BuildSpotsInit: no BuildSpots folder found in Workspace")
    return
end

-- collect children that look like spots, try to sort by trailing number
local entries = {}
for _, child in ipairs(spots:GetChildren()) do
    local nm = normalizeName(child.Name)
    local num = tonumber(nm:match("(%d+)%s*$")) or math.huge
    table.insert(entries, {obj = child, name = nm, num = num})
end
table.sort(entries, function(a,b) return a.num < b.num end)

-- hide all spots except first in sorted order
for i, e in ipairs(entries) do
    local obj = e.obj
    -- store original transparency and color attributes
    if obj:IsA("BasePart") then
        obj:SetAttribute("OrigTransparency", obj.Transparency)
        obj:SetAttribute("OrigR", obj.Color.r)
        obj:SetAttribute("OrigG", obj.Color.g)
        obj:SetAttribute("OrigB", obj.Color.b)
    elseif obj:IsA("Model") then
        local sample = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        if sample then
            obj:SetAttribute("OrigTransparency", sample.Transparency)
            obj:SetAttribute("OrigR", sample.Color.r)
            obj:SetAttribute("OrigG", sample.Color.g)
            obj:SetAttribute("OrigB", sample.Color.b)
        end
        for _, part in ipairs(obj:GetDescendants()) do
            if part:IsA("BasePart") then
                -- nothing per part now
            end
        end
    end

    if i > 1 then
        -- hide and disable collision so it cannot be clicked
        if obj:IsA("BasePart") then
            obj:SetAttribute("OrigTransparency", obj.Transparency)
            obj.Transparency = 1
            obj.CanCollide = false
        elseif obj:IsA("Model") then
            local sample = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if sample and not obj:GetAttribute("OrigTransparency") then
                obj:SetAttribute("OrigTransparency", sample.Transparency)
            end
            for _, part in ipairs(obj:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                    part.CanCollide = false
                end
            end
        end
        obj:SetAttribute("Hidden", true)
    else
        obj:SetAttribute("Hidden", false)
    end

    -- ensure Occupied attribute default false
    if obj:GetAttribute("Occupied") == nil then
        obj:SetAttribute("Occupied", false)
    end
end

print("BuildSpotsInit: initialized, hidden spots set")
=======
-- BuildSpotsInit.server.luau
local Workspace = game:GetService("Workspace")

local function normalizeName(name)
    -- trim
    return tostring(name):gsub("^%s+",""):gsub("%s+$","")
end

local spots = Workspace:FindFirstChild("BuildSpots")
if not spots then
    warn("BuildSpotsInit: no BuildSpots folder found in Workspace")
    return
end

-- collect children that look like spots, try to sort by trailing number
local entries = {}
for _, child in ipairs(spots:GetChildren()) do
    local nm = normalizeName(child.Name)
    local num = tonumber(nm:match("(%d+)%s*$")) or math.huge
    table.insert(entries, {obj = child, name = nm, num = num})
end
table.sort(entries, function(a,b) return a.num < b.num end)

-- hide all spots except first in sorted order
for i, e in ipairs(entries) do
    local obj = e.obj
    -- store original transparency and color attributes
    if obj:IsA("BasePart") then
        obj:SetAttribute("OrigTransparency", obj.Transparency)
        obj:SetAttribute("OrigR", obj.Color.r)
        obj:SetAttribute("OrigG", obj.Color.g)
        obj:SetAttribute("OrigB", obj.Color.b)
    elseif obj:IsA("Model") then
        local sample = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        if sample then
            obj:SetAttribute("OrigTransparency", sample.Transparency)
            obj:SetAttribute("OrigR", sample.Color.r)
            obj:SetAttribute("OrigG", sample.Color.g)
            obj:SetAttribute("OrigB", sample.Color.b)
        end
        for _, part in ipairs(obj:GetDescendants()) do
            if part:IsA("BasePart") then
                -- nothing per part now
            end
        end
    end

    if i > 1 then
        -- hide and disable collision so it cannot be clicked
        if obj:IsA("BasePart") then
            obj:SetAttribute("OrigTransparency", obj.Transparency)
            obj.Transparency = 1
            obj.CanCollide = false
        elseif obj:IsA("Model") then
            local sample = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if sample and not obj:GetAttribute("OrigTransparency") then
                obj:SetAttribute("OrigTransparency", sample.Transparency)
            end
            for _, part in ipairs(obj:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                    part.CanCollide = false
                end
            end
        end
        obj:SetAttribute("Hidden", true)
    else
        obj:SetAttribute("Hidden", false)
    end

    -- ensure Occupied attribute default false
    if obj:GetAttribute("Occupied") == nil then
        obj:SetAttribute("Occupied", false)
    end
end

print("BuildSpotsInit: initialized, hidden spots set")
>>>>>>> 26a6f9e (here who)
