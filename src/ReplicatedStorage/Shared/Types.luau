--[[
	Types.luau
	Shared type definitions used across all systems.
	Define all game-wide types here to maintain a single source of truth.
]]

export type Vector3 = {x: number, y: number, z: number}

export type EnemyConfig = {
	Id: string,
	Health: number,
	Speed: number,
	Reward: number,
	Size: number,
}

export type TowerConfig = {
	Id: string,
	Cost: number,
	Damage: number,
	Range: number,
	FireRate: number,
	Size: number,
}

export type WaveComposition = {
	EnemyId: string,
	Count: number,
	SpawnDelay: number, -- seconds between spawns
}

export type Wave = {
	Id: number,
	Enemies: {WaveComposition},
	Delay: number, -- seconds before next wave
}

export type Enemy = {
	Id: string,
	Model: Instance,
	Config: EnemyConfig,
	CurrentHealth: number,
	PathIndex: number,
	IsAlive: boolean,
}

export type Tower = {
	Id: string,
	Model: Instance,
	Config: TowerConfig,
	Position: Vector3,
}

return {}
