-- Leaderstats.server.luau
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local Money = Instance.new("IntValue")
    Money.Name = "Money"
    Money.Value = 0
    Money.Parent = leaderstats

    print("Leaderstats: created leaderstats for", player.Name)
end)

print("Leaderstats.server: initialized")
