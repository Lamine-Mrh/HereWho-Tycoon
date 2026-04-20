-- GeneratorManagerRunner.server.luau
-- Requires the GeneratorManager module so it runs under ServerScriptService
local ServerScriptService = game:GetService("ServerScriptService")
local modules = ServerScriptService:FindFirstChild("Modules") or script.Parent.Parent:FindFirstChild("Modules")
if not modules then
    warn("GeneratorManagerRunner: Modules folder not found under ServerScriptService")
    return
end

local genModule = modules:FindFirstChild("GeneratorManager")
if not genModule then
    warn("GeneratorManagerRunner: GeneratorManager module not found in Modules")
    return
end

require(genModule)
print("GeneratorManagerRunner: required GeneratorManager module")
