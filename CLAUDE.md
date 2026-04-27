# Tower Defense Game — Roblox Project

## Project Overview
A Roblox tower defense extraction game. Players defend a Nexus from enemy waves,
earn currency, and choose to extract or keep going at wave milestones.
Built in Luau for Roblox Studio, synced via Rojo.

## Tech Stack
- Luau (Roblox's Lua 5.1 dialect)
- Rojo for Studio sync
- Wally for packages (ProfileService for data persistence)
- Roblox Studio for 3D environment


## Architecture Rules (follow these strictly)
- ALL authoritative game state lives on the server only
- Clients only handle visuals, UI, and input — never trust client values
- Use task.wait() never wait() or Wait()
- Use task.spawn() never spawn() or coroutine.wrap() for simple cases
- RemoteEvents fire server→client for visual effects and UI updates only
- RemoteEvents fire client→server for player actions (place tower, extract, etc)
- Server validates ALL client requests before acting on them
- Never hardcode numbers in systems — all stats live in Data modules
- In Lua/Luau, define private functions in dependency order (bottom-up). If function A calls function B, define B before A. This prevents "attempt to call a nil value" errors at runtime.

## Coding Practices
- Every file, function, and public API must be documented with JSDoc-style comments
- Format: describe what it does, list @param with type, list @return with type
- Always use `ipairs()` when iterating Roblox Instance methods that return tables (GetChildren, GetDescendants, etc): `for _, child in ipairs(parent:GetChildren()) do`


## Naming Conventions
- Modules return a table: local MyModule = {} ... return MyModule
- Types use PascalCase: EnemyConfig, TowerConfig
- Constants use SCREAMING_SNAKE_CASE: MAX_TOWERS, NEXUS_HEALTH
- Private functions prefix with underscore: _spawnEnemy()
- Instances in workspace use descriptive names: Enemies/, Towers/, Path/