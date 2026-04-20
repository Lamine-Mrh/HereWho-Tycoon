<<<<<<< HEAD
-- Modules/Economy
local Economy = {}

function Economy.AddMoney(player, amount)
    if not player then return end
    local ls = player:FindFirstChild("leaderstats")
    if not ls then
        warn("Economy.AddMoney: player has no leaderstats", player)
        return
    end
    local money = ls:FindFirstChild("Money")
    if not money then
        warn("Economy.AddMoney: player has no Money value", player)
        return
    end
    amount = tonumber(amount) or 0
    money.Value = money.Value + math.floor(amount)
    print(("Economy: Added %d to %s (now %d)"):format(amount, player.Name, money.Value))
end

=======
-- Modules/Economy
local Economy = {}

function Economy.AddMoney(player, amount)
    if not player then return end
    local ls = player:FindFirstChild("leaderstats")
    if not ls then
        warn("Economy.AddMoney: player has no leaderstats", player)
        return
    end
    local money = ls:FindFirstChild("Money")
    if not money then
        warn("Economy.AddMoney: player has no Money value", player)
        return
    end
    amount = tonumber(amount) or 0
    money.Value = money.Value + math.floor(amount)
    print(("Economy: Added %d to %s (now %d)"):format(amount, player.Name, money.Value))
end

>>>>>>> 26a6f9e (here who)
return Economy