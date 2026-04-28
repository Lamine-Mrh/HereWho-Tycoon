--[[
	README - Shared Services System
	
	This module provides a comprehensive shared system for managing game data,
	leaderboards, shops, donations, and marketplace integration.
	
	QUICK START:
	============
	
	1. SERVER INITIALIZATION:
	   -----------------------
	   local SharedServices = require(game.ReplicatedStorage.Shared.SharedServices)
	   local SharedConfig = require(game.ReplicatedStorage.Shared.SharedConfig)
	   
	   -- Setup shops
	   SharedServices.Shop:RegisterShop("MainShop", SharedConfig.SHOPS.MainShop)
	   SharedServices.Shop:AddItemToShop("MainShop", "tower_basic", ...)
	   
	   -- Setup leaderboards
	   for _, lbConfig in ipairs(SharedConfig.LEADERBOARDS) do
	       SharedServices.Leaderboard:RegisterLeaderboard(lbConfig.name, lbConfig.sortDescending)
	   end
	
	2. PLAYER DATA:
	   -----------
	   -- Load player profile
	   local profile = SharedServices.Profile:LoadProfile(player)
	   
	   -- Access/modify profile
	   local money = profile.Money
	   SharedServices.Profile:AddMoney(player, 100)
	   
-- See Documentation/ folder for all project docs (INTEGRATION_GUIDE, QUICK_START_GUIDE, README, SYSTEMS_DOCUMENTATION)
	   -- Update leaderboard
--]]