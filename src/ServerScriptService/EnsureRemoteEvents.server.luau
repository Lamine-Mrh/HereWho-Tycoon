-- EnsureRemoteEvents.server.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remoteFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteFolder then
    remoteFolder = Instance.new("Folder")
    remoteFolder.Name = "RemoteEvents"
    remoteFolder.Parent = ReplicatedStorage
end

local function ensureEvent(name)
    local ev = remoteFolder:FindFirstChild(name)
    if not ev then
        ev = Instance.new("RemoteEvent")
        ev.Name = name
        ev.Parent = remoteFolder
    end
    return ev
end

ensureEvent("Purchase")
print("EnsureRemoteEvents: ensured Purchase RemoteEvent")
