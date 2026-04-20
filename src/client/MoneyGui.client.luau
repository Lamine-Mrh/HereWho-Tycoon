-- MoneyGui.client.luau
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Ensure PlayerGui and ScreenGui
local playerGui = player:FindFirstChild("PlayerGui") or Players:WaitForChild(player.Name):WaitForChild("PlayerGui")
local screenGui = playerGui:FindFirstChild("UI")
if not screenGui then
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UI"
    screenGui.ResetOnSpawn = true
    screenGui.Parent = playerGui
end

-- Ensure MoneyLabel exists
local moneyLabel = screenGui:FindFirstChild("MoneyLabel")
if not moneyLabel then
    moneyLabel = Instance.new("TextLabel")
    moneyLabel.Name = "MoneyLabel"
    moneyLabel.Size = UDim2.new(0, 160, 0, 28)
    moneyLabel.Position = UDim2.new(1, -10, 0, 10)
    moneyLabel.AnchorPoint = Vector2.new(1, 0)
    moneyLabel.BackgroundTransparency = 0.6
    moneyLabel.TextScaled = true
    moneyLabel.Text = "Money: 0"
    moneyLabel.Parent = screenGui
end

local function safeUpdateLabel(text)
    if moneyLabel and moneyLabel.Parent then
        moneyLabel.Text = text
    end
end

-- Helper: wait for leaderstats without infinite WaitForChild
local function getLeaderstats()
    local ls = player:FindFirstChild("leaderstats")
    if ls then return ls end
    local done = false
    local conn
    conn = player.ChildAdded:Connect(function(child)
        if child and child.Name == "leaderstats" then
            done = true
            conn:Disconnect()
        end
    end)
    while not done do
        wait(0.1)
    end
    return player:FindFirstChild("leaderstats")
end

local function getMoneyValueObj(ls)
    if not ls then return nil end
    local m = ls:FindFirstChild("Money")
    if m then return m end
    local done = false
    local conn
    conn = ls.ChildAdded:Connect(function(child)
        if child.Name == "Money" then
            done = true
            conn:Disconnect()
        end
    end)
    while not done do wait(0.1) end
    return ls:FindFirstChild("Money")
end

local leaderstats = getLeaderstats()
local money = getMoneyValueObj(leaderstats)

local function update()
    local value = (money and money.Value) or 0
    safeUpdateLabel("Money: " .. tostring(value))
end

update()
if money then
    money:GetPropertyChangedSignal("Value"):Connect(update)
end

print("MoneyGui: initialized for", player.Name)
