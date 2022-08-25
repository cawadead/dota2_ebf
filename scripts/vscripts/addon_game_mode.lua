--[[
Holdout Example

	Underscore prefix such as "_function()" denotes a local function and is used to improve readability

	Variable Prefix Examples
		"fl"	Float
		"n"		Int
		"v"		Table
		"b"		Boolean
]]


DAMAGE_TYPES = {
	    [0] = "DAMAGE_TYPE_NONE",
	    [1] = "DAMAGE_TYPE_PHYSICAL",
	    [2] = "DAMAGE_TYPE_MAGICAL",
	    [4] = "DAMAGE_TYPE_PURE",
	    [7] = "DAMAGE_TYPE_ALL",
	    [8] = "DAMAGE_TYPE_HP_REMOVAL",
	}
	
require("internal/util")
require("lua_item/simple_item")
require("lua_boss/boss_32_meteor")
require( "epic_boss_fight_game_round" )
require( "epic_boss_fight_game_spawner" )
require('lib.optionsmodule')
require('stats')
require( "libraries/Timers" )

require( "panoramaBridge")
require( "bossManager")

require("libraries/utility")

LinkLuaModifier( "playerStatRescale", "modifier/playerStatRescale.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_special_effect_donator", "/modifiers/modifier_special_effect_donator.lua", LUA_MODIFIER_MOTION_NONE)


if CHoldoutGameMode == nil then
	CHoldoutGameMode = class({})
end

-- Precache resources
function Precache( context )

    --Precache particle
	--PrecacheResource( "particle", "particles/generic_gameplay/winter_effects_hero.vpcf", context )
	PrecacheResource( "particle", "particles/items2_fx/veil_of_discord.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_ursa/ursa_claw_left.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_ursa/ursa_claw_right.vpcf", context )
		

	PrecacheResource( "particle", "particles/units/heroes/hero_treant/treant_foot_step.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_skeletonking/skeleton_king_weapon_blur.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_skeletonking/skeleton_king_weapon_blur_reverse.vpcf", context )


	PrecacheResource( "particle_folder", "particles/frostivus_gameplay", context )

	
	--Precache sounds
	PrecacheResource( "soundfile", "soundevents/game_sounds_custom.vsndevts", context)
	PrecacheResource( "soundfile", "soundevents/music.vsndevts", context)

	PrecacheItemByNameSync( "item_tombstone", context )
	PrecacheItemByNameSync( "item_bag_of_gold", context )
	PrecacheItemByNameSync( "item_slippers_of_halcyon", context )
	
	--Precache models
	PrecacheResource( "model", "models/heroes/nerubian_assassin/nerubian_assassin.vmdl", context )
	PrecacheResource( "model", "models/heroes/drow/drow_base.vmdl", context )
	PrecacheResource( "model", "models/heroes/tiny/tiny_01/tiny_01.vmdl", context )
	PrecacheResource( "model", "models/heroes/tiny/tiny_02/tiny_02.vmdl", context )
	PrecacheResource( "model", "models/heroes/tiny/tiny_03/tiny_03.vmdl", context )
	PrecacheResource( "model", "models/heroes/tiny/tiny_04/tiny_04.vmdl", context )

	--Precache bosses
	PrecacheUnitByNameSync("npc_dota_boss32_vh", context)
	PrecacheUnitByNameSync("npc_dota_boss32_h", context)
	PrecacheUnitByNameSync("npc_dota_boss32", context)
	PrecacheUnitByNameSync("npc_dota_boss31_vh", context)
	PrecacheUnitByNameSync("npc_dota_boss31_h", context)
	PrecacheUnitByNameSync("npc_dota_boss31", context)
	PrecacheUnitByNameSync("npc_dota_boss30_vh", context)
	PrecacheUnitByNameSync("npc_dota_boss30_h", context)
	PrecacheUnitByNameSync("npc_dota_boss30", context)
	PrecacheUnitByNameSync("npc_dota_boss8", context)
	
    PrecacheUnitByNameSync("npc_dota_boss32_trueform", context)
    PrecacheUnitByNameSync("npc_dota_boss32_trueform_h", context)
    PrecacheUnitByNameSync("npc_dota_boss32_trueform_vh", context)

    PrecacheUnitByNameSync("npc_dota_boss12_b", context)
    PrecacheUnitByNameSync("npc_dota_boss12_b_h", context)
    PrecacheUnitByNameSync("npc_dota_boss12_b_vh", context)
    PrecacheUnitByNameSync("npc_dota_boss12_c", context)
    PrecacheUnitByNameSync("npc_dota_boss12_c_vh", context)
    PrecacheUnitByNameSync("npc_dota_boss12_d", context)
	
	
	PrecacheUnitByNameSync("npc_dota_boss14", context)
end

-- Actually make the game mode when we activate
function Activate()
	GameRules.holdOut = CHoldoutGameMode()
	GameRules.holdOut:InitGameMode()

end

function DeleteAbility( unit)
    for i=0,15,1 do
					local ability = unit:GetAbilityByIndex(i)
					if ability ~= nil then
						ability:Destroy()
					end
				end
end
function TeachAbility( unit, ability_name, level )
    if not level then level = 1 end
        unit:AddAbility(ability_name)
        local ability = unit:FindAbilityByName(ability_name)
        if ability then
            ability:SetLevel(tonumber(level))
            return ability
        end
end
function levelAbility( unit, ability_name, level )
    if not level then level = 1 end
        local ability = unit:FindAbilityByName(ability_name)
        if ability then
            ability:SetLevel(tonumber(level))
            return ability
        end
end


function CHoldoutGameMode:InitGameMode()
	print ("Epic Boss Fight Reborn version 0.1")
	print ("Made By DimaseS")
	GameRules._finish = false
	GameRules.vote_Yes = 0
	GameRules.vote_No = 0
	GameRules.voteRound_Yes = 0;
	GameRules.voteRound_No = 0;
	self._nRoundNumber = 1
	GameRules._roundnumber = 1
	self._NewGamePlus = false
	self.Last_Target_HB = nil
	self.Shield = false
	self.Last_HP_Display = -1
	self._currentRound = nil

	self._regenround25 = false
	self._regenround13 = false
	self._regenNG = false
	self._check_check_dead = false
	self._flLastThinkGameTime = nil
	self._check_dead = false
	self._timetocheck = 0
	self._freshstart = true
	self.boss_master_id = -1
	Life = class({})

	--defining lifes
	Life._life = 10
	Life._MaxLife = 10

	if GetMapName() == "epic_boss_fight_boss_master" then Life._life = 9
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 1 )
		GameRules:SetHeroSelectionTime( 45.0 )
		Life._MaxLife = 9
	else
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 )
	end
	
	GameRules:SetPreGameTime( 30 )
	GameRules:SetShowcaseTime( 0 )
	GameRules:SetStrategyTime( 0 )
	GameRules:SetPostGameTime( 30 )
	GameRules:SetCustomGameEndDelay( 15.0 )
	GameRules:SetCustomGameSetupAutoLaunchDelay( 0 )
	
	if GetMapName() == "epic_boss_fight_normal" then
		GameRules:SetHeroSelectionTime( 90.0 )
	elseif GetMapName() == "epic_boss_fight_hard" then Life._life = 6
		GameRules:SetHeroSelectionTime( 45.0 )
		Life._MaxLife = 6
	elseif GetMapName() == "epic_boss_fight_impossible" then Life._life = 4
		GameRules:SetHeroSelectionTime( 30.0 )
		Life._MaxLife = 4
	elseif GetMapName() == "epic_boss_fight_challenger" then Life._life = 1
		GameRules:SetHeroSelectionTime( 30.0 )
		Life._MaxLife = 1
	end

	GameRules._live = Life._life
	GameRules._used_live = 0

	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 7)
	


	self:_ReadGameConfiguration()
	GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetUseUniversalShopMode( true )
	GameRules:SetTreeRegrowTime( 15.0 )
	GameRules:SetCreepMinimapIconScale( 4 )
	GameRules:SetRuneMinimapIconScale( 1.5 )
	GameRules:SetGoldTickTime( 999999.0 )
    GameRules:SetGoldPerTick( 0 )
	GameRules:SetStartingGold ( 0 )
	GameRules:GetGameModeEntity():SetRemoveIllusionsOnDeath( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	
	xpTable = {[1] = 0}
	local baseXPNeeded = 500
	local sumXP = 0
	for level = 1, 200, 1 do
		local XPForLevel = baseXPNeeded * (level - 1)
		sumXP = sumXP + XPForLevel
		xpTable[level] = sumXP
	end

	GameRules:GetGameModeEntity():SetUseCustomHeroLevels( true )
    GameRules:GetGameModeEntity():SetCustomHeroMaxLevel( 200 )
    GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel( xpTable )
	GameRules:GetGameModeEntity():SetLoseGoldOnDeath( false )
	GameRules:GetGameModeEntity():SetGiveFreeTPOnDeath( false )
	GameRules:GetGameModeEntity():SetStickyItemDisabled( true )
	GameRules:GetGameModeEntity():SetDefaultStickyItem( "item_tpscroll" )
	
	GameRules:GetGameModeEntity():SetMaximumAttackSpeed( 2000 )
	GameRules:GetGameModeEntity():SetMinimumAttackSpeed( 50 )
	
	GameRules:GetGameModeEntity():SetInnateMeleeDamageBlockAmount( 75 )
	GameRules:GetGameModeEntity():SetInnateMeleeDamageBlockPerLevelAmount( 35 )
	GameRules:GetGameModeEntity():SetInnateMeleeDamageBlockPercent( 50 )
	
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ARMOR, 0.015) 
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ATTACK_SPEED, 0.1)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA , 2) 
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA_REGEN, 0.01)
	
	-- Custom console commands
	Convars:RegisterCommand( "holdout_test_round", function(...) return self:_TestRoundConsoleCommand( ... ) end, "Test a round of holdout.", FCVAR_CHEAT )
	Convars:RegisterCommand( "holdout_spawn_gold", function(...) return self._GoldDropConsoleCommand( ... ) end, "Spawn a gold bag.", FCVAR_CHEAT )
	Convars:RegisterCommand( "ebf_cheat_drop_gold_bonus", function(...) return self._GoldDropCheatCommand( ... ) end, "Cheat gold had being detected !",0)
	Convars:RegisterCommand( "ebf_gold", function(...) return self._Goldgive( ... ) end, "hello !",0)
	Convars:RegisterCommand( "ebf_max_level", function(...) return self._LevelGive( ... ) end, "hello !",0)
	Convars:RegisterCommand( "ebf_drop", function(...) return self._ItemDrop( ... ) end, "hello",0)
	Convars:RegisterCommand( "holdout_status_report", function(...) return self:_StatusReportConsoleCommand( ... ) end, "Report the status of the current holdout game.", FCVAR_CHEAT )

	-- Hook into game events allowing reload of functions at run time
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( CHoldoutGameMode, "OnNPCSpawned" ), self )
	ListenToGameEvent( "player_reconnected", Dynamic_Wrap( CHoldoutGameMode, 'OnPlayerReconnected' ), self )
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( CHoldoutGameMode, 'OnEntityKilled' ), self )
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( CHoldoutGameMode, "OnGameRulesStateChange" ), self )
	ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap( CHoldoutGameMode, "OnHeroPick"), self )
	ListenToGameEvent('player_connect_full', Dynamic_Wrap( CHoldoutGameMode, 'OnConnectFull'), self)
	ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(CHoldoutGameMode, 'OnAbilityUsed'), self)
	ListenToGameEvent( "dota_player_gained_level", Dynamic_Wrap(CHoldoutGameMode, "OnHeroLevelUp"), self)

	ListenToGameEvent('game_start', Dynamic_Wrap(CHoldoutGameMode, 'OnGameStart'), self)

	CustomGameEventManager:RegisterListener('Boss_Master', Dynamic_Wrap( CHoldoutGameMode, 'Boss_Master'))

	CustomGameEventManager:RegisterListener('mute_sound', Dynamic_Wrap( CHoldoutGameMode, 'mute_sound'))
	CustomGameEventManager:RegisterListener('unmute_sound', Dynamic_Wrap( CHoldoutGameMode, 'unmute_sound'))
	CustomGameEventManager:RegisterListener('Health_Bar_Command', Dynamic_Wrap( CHoldoutGameMode, 'Health_Bar_Command'))

	
	CustomGameEventManager:RegisterListener('Vote_NG', Dynamic_Wrap( CHoldoutGameMode, 'vote_NG_fct'))
	CustomGameEventManager:RegisterListener('Vote_Round', Dynamic_Wrap( CHoldoutGameMode, 'vote_Round'))

	GameRules:GetGameModeEntity():SetDamageFilter( Dynamic_Wrap( CHoldoutGameMode, "FilterDamage" ), self )
	
	-- Register OnThink with the game engine so it is called every 0.25 seconds
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, 0.25 )
	--GameRules:GetGameModeEntity():SetThink( "RemovePassiveGPM", self, SEVER_TICK_RATE ) --tester
	panoramaBridge:Init()
	bossManager:Init(self)
end


function CHoldoutGameMode:OnGameStart (event)
 	CustomGameEventManager:Send_ServerToAllClients("UpdateLife", {life = Life._life})
	
end


function CHoldoutGameMode:Health_Bar_Command (event)
 	local ID = event.pID
 	local player = PlayerResource:GetPlayer(ID)
 	if event.Enabled == 0 then
 		player.HB = false
 		player.Health_Bar_Open = false
 	else
 		player.HB = true
 	end
end


function CHoldoutGameMode:vote_NG_fct (event)
 	local ID = event.pID
 	local vote = event.vote
 	local player = PlayerResource:GetPlayer(ID)
 	--print ("vote"..vote)
 	if player~= nil then
	 	if player.Has_Voted ~= true then
	 		player.Has_Voted = true
	 		if vote == 1 then
	 			GameRules.vote_Yes = GameRules.vote_Yes + 1
	 		else
	 			GameRules.vote_No = GameRules.vote_No + 1
	 		end
			local event_data =
			{
			No = GameRules.vote_No,
			Yes = GameRules.vote_Yes,
			}
			CustomGameEventManager:Send_ServerToAllClients("VoteResults", event_data)
	 	end
	end
end



function CHoldoutGameMode:_Start_Vote()
	CustomGameEventManager:Send_ServerToAllClients("Display_Vote", {})
	local time = 0
	Timers:CreateTimer(1,function()
		time = time + 1
		CustomGameEventManager:Send_ServerToAllClients("refresh_time", {time = 60-time})
		--if time >= 60 or (GameRules.vote_Yes + GameRules.vote_No) == PlayerResource:GetTeamPlayerCount() then  --tester
		if time >= 60 or (GameRules.vote_Yes + GameRules.vote_No) == self:TeamCount() then
			CustomGameEventManager:Send_ServerToAllClients("Close_Vote", {})
			if GameRules.vote_Yes >= GameRules.vote_No then
				self:_EnterNG()
				self._nRoundNumber = 1
				self._flPrepTimeEnd = GameRules:GetGameTime() + 70-time
			else
				SendToConsole("dota_health_per_vertical_marker 250")
				GameRules:SetCustomVictoryMessage ("Congratulations!")
				GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
				GameRules._finish = true

			end
		else
			return 1
		end
	end)
end

function CHoldoutGameMode:FilterDamage( filterTable )
    local total_damage_team = 0
    local dps = 0
    local victim_index = filterTable["entindex_victim_const"]
    local attacker_index = filterTable["entindex_attacker_const"]
    if not victim_index or not attacker_index then
        return true
    end
	local damage = filterTable["damage"] --Post reduction
	local inflictor = filterTable["entindex_inflictor_const"]
    local victim = EntIndexToHScript( victim_index )
    local attacker = EntIndexToHScript( attacker_index )
	local ability = (inflictor ~= nil) and EntIndexToHScript( inflictor )
	local original_attacker = attacker -- make a copy for threat
    local damagetype = filterTable["damagetype_const"]
	if damage <= 0 then return true end
	--- DAMAGE MANIPULATION ---
	if inflictor and attacker:HasModifier("spellcrit") then
		local critDamage = 1
		for _, modifier in ipairs( attacker:FindAllModifiersByName("spellcrit") ) do
			local item = modifier:GetAbility()
			local critChance = item:GetSpecialValueFor("spell_crit_chance")
			local newCritDamage = item:GetSpecialValueFor("spell_crit_multiplier") / 100
			if critDamage < newCritDamage and RollPercentage( critChance ) then
				critDamage = newCritDamage
			end
		end
		if critDamage > 1 then
			filterTable["damage"] = damage * critDamage
			SendOverheadEventMessage( attacker:GetPlayerOwner(), OVERHEAD_ALERT_DEADLY_BLOW, victim, damage * critDamage, attacker:GetPlayerOwner() )
		end
	end

    return true
end

function GetHeroDamageDone(hero)
    return hero.damageDone
end

function CHoldoutGameMode:OnAbilityUsed(keys)
	--will be used in future :p
	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local hero = EntIndexToHScript( keys.caster_entindex )
	local abilityname = keys.abilityname
end

function CHoldoutGameMode:_EnterNG()
	print ("Enter NG+ :D")
	self._NewGamePlus = true
	GameRules._NewGamePlus = true
	--new test?
	--[[Timers:CreateTimer(0.12,function()
 			for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
				if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
					if PlayerResource:HasSelectedHero( nPlayerID ) then
						local player = PlayerResource:GetPlayer(nPlayerID)
						--CustomGameEventManager:Send_ServerToPlayer(player,"Update_Asura_Core", {core = player.Asura_Core})
					end
				end
			end
 			return 0.12
 		end)]]
	--CustomGameEventManager:Send_ServerToAllClients("Display_Asura_Core", {})
	--CustomGameEventManager:Send_ServerToAllClients("Display_Shop", {})
end

function CHoldoutGameMode:OnHeroPick (event)
 	local hero = EntIndexToHScript(event.heroindex)
 	if hero:GetName() == "npc_dota_hero_invoker" then levelAbility( hero, "invoker_reset", 1) end
	local playerID = hero:GetPlayerOwnerID()
	
	-- set hero base stats to their intended values
	hero:AddNewModifier(hero, hero, "playerStatRescale",{})
	hero:SetPhysicalArmorBaseValue( hero:GetPhysicalArmorBaseValue() + hero:GetAgility() * 0.152 )
	hero:SetBaseManaRegen( hero:GetBaseManaRegen() + hero:GetIntellect() * 0.04 )
	
	hero.damageDone = 0
	hero.Ressurect = 0
	--stats:ModifyStatBonuses(hero)
	local ID = hero:GetPlayerID()
	hero:SetGold(0 , false)
	hero:SetGold(0 , true)
	local player = PlayerResource:GetPlayer(ID)
	if not player then return end --tester
 	player.HB = true
 	player.Health_Bar_Open = false
	--[[Timers:CreateTimer(2.5,function()
 			if self._NewGamePlus == true and PlayerResource:GetGold(ID)>= 80000 then
 				self._Buy_Asura_Core(ID)
 			end
 			return 2.5
 		end)]]

	--[[if PlayerResource:GetSteamAccountID( ID ) == 86736807 then
		print ("look like a chalenger is here :D")
		message_chalenger = true
		self.chalenger = hero
		GameRules:GetGameModeEntity():SetThink( "Chalenger", self, 0.25 )
	end]]
	
	local fountain = nil
    for _,unit in pairs ( Entities:FindAllByName( "*fountain*")) do
		if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
			fountain = unit
		end
	end

	local courierPosition = hero:GetAbsOrigin()
	if fountain ~= nil then
		courierPosition = fountain:GetAbsOrigin()
	end


	local team = hero:GetTeamNumber()
	if team == DOTA_TEAM_GOODGUYS then
	    local cr = CreateUnitByName("npc_dota_courier", courierPosition + RandomVector(RandomFloat(100, 100)), true, hero, hero, hero:GetTeamNumber())
		cr:SetOwner(hero)
	    cr:SetControllableByPlayer(playerID, true)
	end
	
	--[[ Create a courier
	local team = hero:GetTeamNumber()
	if team == DOTA_TEAM_GOODGUYS then
	    local courier_unit = CreateUnitByName("npc_dota_courier", (Vector(2496,-3226,48)), true, hero, hero, hero:GetTeamNumber())
	    courier_unit:SetOwner(hero)
	    courier_unit:SetControllableByPlayer(playerID, true)
	    courier_unit:AddNewModifier(courier_unit, nil, "modifier_core_courier", {})
	end]]--
	
	
	if hero:GetTeamNumber() == DOTA_TEAM_BADGUYS then
		DeleteAbility(hero)
		TeachAbility (hero , "hide_hero")
		hero:AddNoDraw()
		self.boss_master_id = ID
    end

    CustomGameEventManager:Send_ServerToAllClients("UpdateLife", {life = Life._life})
end

function CHoldoutGameMode:OnHeroLevelUp(event)
	local playerID = EntIndexToHScript(event.player):GetPlayerID()
	local unit = EntIndexToHScript(event.hero_entindex)
	local hero = PlayerResource:GetSelectedHeroEntity(playerID)
	if hero == unit then
		if hero:GetLevel() >= 27 and not (hero:GetLevel() == 30) then
			hero:SetAbilityPoints( hero:GetAbilityPoints() + 1)
		end
	end
end

function CHoldoutGameMode:Boss_Master (event)
 	local ID = event.pID
 	local commandname = event.Command
 	local player = PlayerResource:GetPlayer(ID)
 	if commandname == "magic_immunity_1" then

 	elseif commandname == "magic_immunity_2" then

 	elseif commandname == "damage_immunity" then

 	elseif commandname == "double_damage" then

 	elseif commandname == "quad_damage" then

 	end

end


-- Read and assign configurable keyvalues if applicable
function CHoldoutGameMode:_ReadGameConfiguration()
	local kv = LoadKeyValues( "scripts/maps/" .. GetMapName() .. ".txt" )
	kv = kv or {} -- Handle the case where there is not keyvalues file

	self._bAlwaysShowPlayerGold = kv.AlwaysShowPlayerGold or false
	self._bRestoreHPAfterRound = kv.RestoreHPAfterRound or false
	self._bRestoreMPAfterRound = kv.RestoreMPAfterRound or false
	self._bRewardForTowersStanding = kv.RewardForTowersStanding or false
	self._bUseReactiveDifficulty = kv.UseReactiveDifficulty or false

	self._flPrepTimeBetweenRounds = tonumber( kv.PrepTimeBetweenRounds or 0 )
	self._flItemExpireTime = tonumber( kv.ItemExpireTime or 10.0 )

	self:_ReadRandomSpawnsConfiguration( kv["RandomSpawns"] )
	self:_ReadLootItemDropsConfiguration( kv["ItemDrops"] )
	self:_ReadRoundConfigurations( kv )
end

-- Verify spawners if random is set
function CHoldoutGameMode:OnConnectFull()
	SendToServerConsole("dota_combine_models 0")
    SendToConsole("dota_combine_models 0")
    SendToServerConsole("dota_health_per_vertical_marker 1000")
end

function CHoldoutGameMode:ChooseRandomSpawnInfo()
	if #self._vRandomSpawnsList == 0 then
		error( "Attempt to choose a random spawn, but no random spawns are specified in the data." )
		return nil
	end
	return self._vRandomSpawnsList[ RandomInt( 1, #self._vRandomSpawnsList ) ]
end

-- Verify valid spawns are defined and build a table with them from the keyvalues file
function CHoldoutGameMode:_ReadRandomSpawnsConfiguration( kvSpawns )
	self._vRandomSpawnsList = {}
	if type( kvSpawns ) ~= "table" then
		return
	end
	for _,sp in pairs( kvSpawns ) do			-- Note "_" used as a shortcut to create a temporary throwaway variable
		table.insert( self._vRandomSpawnsList, {
			szSpawnerName = sp.SpawnerName or "",
			szFirstWaypoint = sp.Waypoint or ""
		} )
	end
end


-- If random drops are defined read in that data
function CHoldoutGameMode:_ReadLootItemDropsConfiguration( kvLootDrops )
	self._vLootItemDropsList = {}
	if type( kvLootDrops ) ~= "table" then
		return
	end
	for _,lootItem in pairs( kvLootDrops ) do
		table.insert( self._vLootItemDropsList, {
			szItemName = lootItem.Item or "",
			nChance = tonumber( lootItem.Chance or 0 )
		})
	end
end


-- Set number of rounds without requiring index in text file
function CHoldoutGameMode:_ReadRoundConfigurations( kv )
	self._vRounds = {}
	while true do
		local szRoundName = string.format("Round%d", #self._vRounds + 1 )
		local kvRoundData = kv[ szRoundName ]
		if kvRoundData == nil then
			return
		end
		local roundObj = CHoldoutGameRound()
		roundObj:ReadConfiguration( kvRoundData, self, #self._vRounds + 1 )
		table.insert( self._vRounds, roundObj )
	end
end


-- When game state changes set state in script
function CHoldoutGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		if GetMapName() ~= "epic_boss_fight_challenger" then
			ShowGenericPopup( "#holdout_instructions_title", "#holdout_instructions_body", "", "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN )
		else
			ShowGenericPopup( "#holdout_instructions_title_challenger", "#holdout_instructions_body_challenger", "", "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN )
		end
	elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			local player = PlayerResource:GetPlayer(nPlayerID)
			if player ~= nil then
				self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
			end
		end
	end
end


function CHoldoutGameMode:AddLife(life)
	local messageinfo = {
		message = life.." life has been gained",
		duration = 5
		}
	FireGameEvent("show_center_message",messageinfo)
	Life._life = Life._life + life
	GameRules._live = Life._life
	CustomGameEventManager:Send_ServerToAllClients("UpdateLife", {life = Life._life})
end


function CHoldoutGameMode:_regenlifecheck()
	if self._regenround25 == false and self._nRoundNumber >= 26 then
		self._regenround25 = true
		self._checkpoint = 26

		self:AddLife(1)
	end
	if self._regenround13 == false and self._nRoundNumber >= 14 then
		self._regenround13 = true
		self._checkpoint = 14

		self:AddLife(1)
	end
	if self._regenNG == false and self._NewGamePlus == true then
		self._regenNG = true

		local messageinfo = {
		message = "Five life has been gained , Welcome to NewGame + .Mouahahaha !",
		duration = 10
		}
		SendToConsole("dota_combine_models 0")
		SendToServerConsole("dota_health_per_vertical_marker 100000")
		FireGameEvent("show_center_message",messageinfo)   
		self._checkpoint = 1
		Life._MaxLife = Life._MaxLife + 5
		Life._life = Life._life + 5
		GameRules._live = Life._life
		--Life:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, Life._life )
   		--Life:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, Life._MaxLife )
		-- value on the bar
		--LifeBar:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, Life._life )
		--LifeBar:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, Life._MaxLife )
	end
end

function CHoldoutGameMode:vote_Round (event)
 	local ID = event.pID
 	local vote = event.vote
 	local player = PlayerResource:GetPlayer(ID)

 	if player~= nil then
	 	if vote == 1 then
	 		GameRules.voteRound_Yes = GameRules.voteRound_Yes + 1
			GameRules.voteRound_No = GameRules.voteRound_No - 1

			local event_data =
			{
				No = GameRules.voteRound_No,
				Yes = GameRules.voteRound_Yes,
			}
			CustomGameEventManager:Send_ServerToAllClients("RoundVoteResults", event_data)
		end
	end
end

function CHoldoutGameMode:spawn_unit( place , unitname , radius , unit_number)
    if radius == nil then radius = 400 end
    if core == nil then core = false end
    if unit_number == nil then unit_number = 1 end
    for i = 0, unit_number-1 do
        print   ("spawn unit : "..unitname)
        PrecacheUnitByNameAsync( unitname, function()
        local unit = CreateUnitByName( unitname ,place + RandomVector(RandomInt(radius,radius)), true, nil, nil, DOTA_TEAM_BADGUYS )
            Timers:CreateTimer(0.03,function()
            end)
        end,
        nil)
    end
end

function CHoldoutGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self:_CheckForDefeat()
		self:_ThinkLootExpiry()
		self:_regenlifecheck()
		if self._flPrepTimeEnd ~= nil then
			self:_ThinkPrepTime()
		elseif self._currentRound ~= nil then
			self._currentRound:Think()
			if self._currentRound:IsFinished() then
				self._currentRound:End()
				self._currentRound = nil
				-- Heal all players
				self:_RefreshPlayers()
				self._nRoundNumber = self._nRoundNumber + 1
				simple_item:SetRoundNumer(self._nRoundNumber)
				boss_meteor:SetRoundNumer(self._nRoundNumber)
				GameRules._roundnumber = self._nRoundNumber
				-- if math.random(1,25) == 25 then
					-- self:spawn_unit( Vector(0,0,0) , "npc_dota_treasure" , 2000)
					-- for _,unit in pairs ( Entities:FindAllByModel( "models/courier/flopjaw/flopjaw.vmdl")) do
						-- Waypoint = Entities:FindByName( nil, "path_invader1_1" )
						-- unit:SetInitialGoalEntity(Waypoint)
						-- Timers:CreateTimer(15,function()
							-- unit:ForceKill(true)
						-- end)
					-- end
					-- self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds + 15

				-- end
				if self._nRoundNumber > #self._vRounds then
					if self._NewGamePlus == false then
						self:_Start_Vote()
					else
						SendToConsole("dota_health_per_vertical_marker 250")
						GameRules:SetCustomVictoryMessage ("Congratulations!")
						GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
						GameRules._finish = true
					end
					else
					    self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
						
						--GameRules.voteRound_No = PlayerResource:GetTeamPlayerCount()  --tester
						GameRules.voteRound_No = self:TeamCount()
					GameRules.voteRound_Yes = 0

					CustomGameEventManager:Send_ServerToAllClients("Display_RoundVote", {})
					local event_data =
					{
						No = GameRules.voteRound_No,
						Yes = GameRules.voteRound_Yes,
					}
					CustomGameEventManager:Send_ServerToAllClients("RoundVoteResults", event_data)

					Timers:CreateTimer(1,function()
						--if GameRules.voteRound_Yes == PlayerResource:GetTeamPlayerCount() then --tester
						if GameRules.voteRound_Yes == self:TeamCount() then 
							CustomGameEventManager:Send_ServerToAllClients("Close_RoundVote", {})
							if self._flPrepTimeEnd~= nil then
								self._flPrepTimeEnd = 0
							end
						else
							return 1
						end
					end)
				end
			end
		end
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then		-- Safe guard catching any state that may exist beyond DOTA_GAMERULES_STATE_POST_GAME
		return nil
	end
	return 0.25
end


function CHoldoutGameMode:_Connection_states()
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		local player_connection_state = PlayerResource:GetConnectionState(nPlayerID)
		local hero = GetAssignedHero(nPlayerID)
		if hero~=nil and player_connection_state == 4 and hero.Abandonned ~= true then
			hero.Abandonned = true
			for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
				if self._NewGamePlus == false then
					local totalgold = unit:GetGold() + (self._nRoundNumber^1.3)*100
				else
					local totalgold = unit:GetGold() + ((36+self._nRoundNumber)^1.3)*100
				end
				unit:SetGold(0 , false)
				unit:SetGold(totalgold, true)
			end
			for itemSlot = 0, 5, 1 do
	          	local Item = hero:GetItemInSlot( itemSlot )
	           	hero:RemoveItem(Item)
	        end
	        Timers:CreateTimer(0.1,function()
	        	hero:SetGold(0, true)
	        	return 0.5
	        end)
		end
	end
end


function CHoldoutGameMode:_RefreshPlayers()
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			if PlayerResource:HasSelectedHero( nPlayerID ) then
				local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
				if hero ~=nil then
					if not hero:IsAlive() then
						hero:RespawnHero(false, false)
					end
					hero:SetHealth( hero:GetMaxHealth() )
					hero:SetMana( hero:GetMaxMana() )
				end
			end
		end
	end
end


function CHoldoutGameMode:_CheckForDefeat()
	if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		return
	end
	local AllRPlayersDead = true
	local PlayerNumberRadiant = 0
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			PlayerNumberRadiant = PlayerNumberRadiant + 1
			if not PlayerResource:HasSelectedHero( nPlayerID ) and self._nRoundNumber == 1 and self._currentRound == nil then
				AllRPlayersDead = false
			elseif PlayerResource:HasSelectedHero( nPlayerID ) then
				local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
				if hero and hero:IsAlive() then
					AllRPlayersDead = false
				end
			end
		end
	end


	if AllRPlayersDead and PlayerNumberRadiant>0 then
		if self._entPrepTimeQuest then
			self:_RefreshPlayers()
			return
		end
		if self._check_dead == false then
			self._check_check_dead = false
			Timers:CreateTimer(2.0,function()
				if self._check_check_dead == false then
					self._check_dead = true
				else
					self._check_check_dead = false
				end
			end)
		end
		if self._check_dead == true and Life._life > 0 then
			if self._currentRound ~= nil then
				self._currentRound:End()
				self._currentRound = nil
			end
			self._flPrepTimeEnd = GameRules:GetGameTime() + 20
			Life._life = Life._life - 1
			GameRules._live = Life._life
			GameRules._used_live = GameRules._used_live + 1
			CustomGameEventManager:Send_ServerToAllClients("UpdateLife", {life = Life._life})

			self._check_dead = false
			for _,unit in pairs ( Entities:FindAllByName( "npc_dota_creature")) do
				if unit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
					unit:ForceKill(true)
				end
			end
			for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
				if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
					local totalgold = unit:GetGold() + ((((self._nRoundNumber/1.5)+5)/((Life._life/2) +0.5))*500)
		            unit:SetGold(0 , false)
		            unit:SetGold(totalgold, true)
	        	end
			end
			if delay ~= nil then
				self._flPrepTimeEnd = GameRules:GetGameTime() + tonumber( delay )
			end
			self:_RefreshPlayers()
		else
			self._check_dead = false
		end
	end
	if PlayerNumberRadiant == 0 or Life._life == 0 then
		self:_OnLose()
	end
end


function CHoldoutGameMode:RemovePassiveGPM()
	-- if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
			if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
		        unit:SetGold(0 , true)
			end
		end

	-- elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then		-- Safe guard catching any state that may exist beyond DOTA_GAMERULES_STATE_POST_GAME
	-- 	return nil
	-- end
	return SEVER_TICK_RATE
end

function CHoldoutGameMode:_OnLose()
	--[[Say(nil,"You just lose all your life , a vote start to chose if you want to continue or not", false)
	if self._checkpoint == 14 then
		Say(nil,"if you continue you will come back to round 13 , you keep all the current item and gold gained", false)
	elif self._checkpoint == 26 then
		Say(nil,"if you continue you will come back to round 25 , you keep all the current item and gold gained", false)
	elseif self._checkpoint == 46 then
		Say(nil,"if you continue you will come back to round 45 , you keep with all the current item and gold gained", false)
	elseif self._checkpoint == 61 then
		Say(nil,"if you continue you will come back to round 60 , you keep with all the current item and gold gained", false)
	elseif self._checkpoint == 76 then
		Say(nil,"if you continue you will come back to round 75 , you keep with all the current item and gold gained", false)
	elseif self._checkpoint == 91 then
		Say(nil,"if you continue you will come back to round 90 , you keep with all the current item and gold gained", false)
	else
		Say(nil,"if you continue you will come back to round begin and have all your money and item erased", false)
	end
	Say(nil,"If you want to retry , type YES in thes chat if you don't want type no , no vote will be taken as a yes", false)
	Say(nil,"At least Half of the player have to vote yes for game to restart on last check points", false)]]
	SendToConsole("dota_health_per_vertical_marker 250")
	GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )
end


function CHoldoutGameMode:_ThinkPrepTime()
	if GameRules:GetGameTime() >= self._flPrepTimeEnd then
	--new
	    CustomGameEventManager:Send_ServerToAllClients("Close_RoundVote", {})
		self._flPrepTimeEnd = nil
		if self._entPrepTimeQuest then
			UTIL_RemoveImmediate( self._entPrepTimeQuest )
			self._entPrepTimeQuest = nil
		end

		if self._nRoundNumber > #self._vRounds then
			GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
			Say(nil,"If you wish you can support me on patreon (link in description of the gamemode), anyways, thank for playing <3", false)
			return false
		end
		self._currentRound = self._vRounds[ self._nRoundNumber ]
		self._currentRound:Begin()
		return
	end

	if not self._entPrepTimeQuest then
		self._entPrepTimeQuest = SpawnEntityFromTableSynchronous( "quest", { name = "PrepTime", title = "#DOTA_Quest_Holdout_PrepTime" } )
		self._entPrepTimeQuest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_ROUND, self._nRoundNumber )
		self._entPrepTimeQuest:SetTextReplaceString( self:GetDifficultyString() )
		self:_RefreshPlayers()
		self._vRounds[ self._nRoundNumber ]:Precache()
	end
	CustomGameEventManager:Send_ServerToAllClients("UpdateTimeLeft", {nextRound = self._nRoundNumber,Time = self._flPrepTimeEnd - GameRules:GetGameTime()})
	self._entPrepTimeQuest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, self._flPrepTimeEnd - GameRules:GetGameTime() )
end

function CHoldoutGameMode:_ThinkLootExpiry()
	if self._flItemExpireTime <= 0.0 then
		return
	end

	local flCutoffTime = GameRules:GetGameTime() - self._flItemExpireTime

	for _,item in pairs( Entities:FindAllByClassname( "dota_item_drop")) do
		local containedItem = item:GetContainedItem()
		if containedItem:GetAbilityName() == "item_bag_of_gold" or item.Holdout_IsLootDrop then
			self:_ProcessItemForLootExpiry( item, flCutoffTime )
		end
	end
end


function CHoldoutGameMode:_ProcessItemForLootExpiry( item, flCutoffTime )
	if item:IsNull() then
		return false
	end
	if item:GetCreationTime() >= flCutoffTime then
		return true
	end

	local containedItem = item:GetContainedItem()
	if containedItem and containedItem:GetAbilityName() == "item_bag_of_gold" then
		if self._currentRound and self._currentRound.OnGoldBagExpired then
			self._currentRound:OnGoldBagExpired()
		end
	end

	local nFXIndex = ParticleManager:CreateParticle( "particles/items2_fx/veil_of_discord.vpcf", PATTACH_CUSTOMORIGIN, item )
	ParticleManager:SetParticleControl( nFXIndex, 0, item:GetOrigin() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 35, 35, 25 ) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
	local inventoryItem = item:GetContainedItem()
	if inventoryItem then
		UTIL_RemoveImmediate( inventoryItem )
	end
	UTIL_RemoveImmediate( item )
	return false
end


function CHoldoutGameMode:GetDifficultyString()
	--local nDifficulty = PlayerResource:GetTeamPlayerCount() --tester
	local nDifficulty = self:TeamCount()
	if nDifficulty > 10 then
		return string.format( "(+%d)", nDifficulty )
	elseif nDifficulty > 0 then
		return string.rep( "+", nDifficulty )
	else
		return ""
	end
end


function CHoldoutGameMode:OnNPCSpawned( event )
	local spawnedUnit = EntIndexToHScript( event.entindex )
	if not spawnedUnit or spawnedUnit:GetClassname() == "npc_dota_thinker" or spawnedUnit:IsPhantom() then
		return
	end

	bossManager:onBossSpawn(spawnedUnit)
	
	
	if spawnedUnit:IsRealHero() and spawnedUnit.bFirstSpawned == nil then
		spawnedUnit.bFirstSpawned = true
		local playerID = spawnedUnit:GetPlayerID()
		local steamID = PlayerResource:GetSteamAccountID(playerID)
		local donator = {348779641,411522104,75896240,89172735,132898041,163913416}
		for i=1,#donator do
			if steamID == donator[i] then
			spawnedUnit:AddItemByName("item_ancient_butterfly")
			spawnedUnit:AddItemByName("item_ancient_fury")
			--spawnedUnit:AddItemByName("item_ancient_core")
			spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_special_effect_donator", {duration= -1})
		end
		end
	end
	
	--[[local tester = self:TeamCount()
	if tester == 0 then
	print("work?? %d", tester)
	else
	print("error!! %d", tester)
	end
	]]--

	-- Attach client side hero effects on spawning players
	--new
	--[[if spawnedUnit:IsCreature() then
		spawnedUnit:SetHPGain( spawnedUnit:GetMaxHealth() * 0.3 ) -- LEVEL SCALING VALUE FOR HP
		spawnedUnit:SetManaGain( 0 )
		spawnedUnit:SetHPRegenGain( 0 )
		spawnedUnit:SetManaRegenGain( 0 )
		if spawnedUnit:IsRangedAttacker() then
			spawnedUnit:SetDamageGain( ( ( spawnedUnit:GetBaseDamageMax() + spawnedUnit:GetBaseDamageMin() ) / 2 ) * 0.1 ) -- LEVEL SCALING VALUE FOR DPS
		else
			spawnedUnit:SetDamageGain( ( ( spawnedUnit:GetBaseDamageMax() + spawnedUnit:GetBaseDamageMin() ) / 2 ) * 0.2 ) -- LEVEL SCALING VALUE FOR DPS
		end
		spawnedUnit:SetArmorGain( 0 )
		spawnedUnit:SetMagicResistanceGain( 0 )
		spawnedUnit:SetDisableResistanceGain( 0 )
		spawnedUnit:SetAttackTimeGain( 0 )
		spawnedUnit:SetMoveSpeedGain( 0 )
		spawnedUnit:SetBountyGain( 0 )
		spawnedUnit:SetXPGain( 0 )
		spawnedUnit:CreatureLevelUp( PlayerResource:GetTeamPlayerCount()  )
		if spawnedUnit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
			Timers:CreateTimer(0.03,function()
				spawnedUnit:SetOwner(PlayerResource:GetSelectedHeroEntity(self.boss_master_id))
				spawnedUnit:SetControllableByPlayer(self.boss_master_id,true)

				if self._NewGamePlus == true then
					local Number_Round = self._nRoundNumber
					spawnedUnit:SetMaxHealth((3000000+spawnedUnit:GetMaxHealth())* Number_Round^0.1 )
					spawnedUnit:SetHealth(spawnedUnit:GetMaxHealth())
					spawnedUnit:SetBaseDamageMin((spawnedUnit:GetBaseDamageMin()+2000000)*(Number_Round^0.70 +2) )
					spawnedUnit:SetBaseDamageMax((spawnedUnit:GetBaseDamageMax()+3000000)*(Number_Round^0.80 +2) )
					spawnedUnit:SetPhysicalArmorBaseValue((spawnedUnit:GetPhysicalArmorBaseValue() + 2500)*(Number_Round^0.75+1))
					if spawnedUnit:GetBaseMagicalResistanceValue() < (100 - (36-Number_Round)^0.7) then
						spawnedUnit:SetBaseMagicalResistanceValue(100 - (36-Number_Round)^0.7)
					end
				end
			end)
		end

	end]]--
	---last good |V|
    --[[if spawnedUnit:IsCreature() then
		local difficulty_multiplier = (PlayerResource:GetTeamPlayerCount() / 7)^0.2
		spawnedUnit:SetMaxHealth (difficulty_multiplier*spawnedUnit:GetMaxHealth())
		spawnedUnit:SetHealth(spawnedUnit:GetMaxHealth())
		spawnedUnit:SetBaseDamageMin(difficulty_multiplier*spawnedUnit:GetBaseDamageMin())
		spawnedUnit:SetBaseDamageMax(difficulty_multiplier*spawnedUnit:GetBaseDamageMax())
		spawnedUnit:SetPhysicalArmorBaseValue(difficulty_multiplier*spawnedUnit:GetPhysicalArmorBaseValue())

		if spawnedUnit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
			Timers:CreateTimer(0.03,function()
				spawnedUnit:SetOwner(PlayerResource:GetSelectedHeroEntity(self.boss_master_id))
				spawnedUnit:SetControllableByPlayer(self.boss_master_id,true)

				if self._NewGamePlus == true and spawnedUnit.Holdout_IsCore then
					local Number_Round = self._nRoundNumber
					spawnedUnit:SetMaxHealth((3000000+spawnedUnit:GetMaxHealth())* Number_Round^0.1 )
					spawnedUnit:SetHealth(spawnedUnit:GetMaxHealth())
					spawnedUnit:SetBaseDamageMin((spawnedUnit:GetBaseDamageMin()+2000000)*(Number_Round^0.70 +2) )
					spawnedUnit:SetBaseDamageMax((spawnedUnit:GetBaseDamageMax()+3000000)*(Number_Round^0.80 +2) )
					spawnedUnit:SetPhysicalArmorBaseValue((spawnedUnit:GetPhysicalArmorBaseValue() + 2500)*(Number_Round^1.2+1))
					if spawnedUnit:GetBaseMagicalResistanceValue() < (100 - (36-Number_Round)^0.7) then
						if spawnedUnit:GetUnitName() ~= "npc_dota_boss33_a_vh" and spawnedUnit:GetUnitName() ~= "npc_dota_boss33_a_h" and spawnedUnit:GetUnitName() ~= "npc_dota_boss33_a" then
							spawnedUnit:SetBaseMagicalResistanceValue(100 - (36-Number_Round)^0.7)
						end
					end
					--spawnedUnit:AddAbility("new_game_damage_increase")
				elseif self._NewGamePlus == true then
					local Number_Round = self._nRoundNumber
					spawnedUnit:SetMaxHealth((500000+spawnedUnit:GetMaxHealth())* Number_Round^0.1 )
					spawnedUnit:SetHealth(spawnedUnit:GetMaxHealth())
					spawnedUnit:SetBaseDamageMin((spawnedUnit:GetBaseDamageMin()+2000000)*(Number_Round^0.70 +2) )
					spawnedUnit:SetBaseDamageMax((spawnedUnit:GetBaseDamageMax()+3000000)*(Number_Round^0.80 +2) )
					spawnedUnit:SetPhysicalArmorBaseValue((spawnedUnit:GetPhysicalArmorBaseValue() + 1250)*(Number_Round^0.75+1))
					if spawnedUnit:GetBaseMagicalResistanceValue() < (90 - (36-Number_Round)^0.7) then
						if spawnedUnit:GetUnitName() ~= "npc_dota_boss33_a_vh" and spawnedUnit:GetUnitName() ~= "npc_dota_boss33_a_h" and spawnedUnit:GetUnitName() ~= "npc_dota_boss33_a" then
							spawnedUnit:SetBaseMagicalResistanceValue(90 - (36-Number_Round)^0.7)
						end
					end
				end
			end)
		end
	end]]--
end

function CHoldoutGameMode:OnPlayerReconnected( event )
	local nReconnectedPlayerID = event.PlayerID
	for _,hero in pairs( Entities:FindAllByClassname( "npc_dota_hero" ) ) do
		if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
			if hero:IsRealHero() then
				self:_SpawnHeroClientEffects( hero, nReconnectedPlayerID )
			end
			self._DisconnectedPlayer = self._DisconnectedPlayer - 1
		end
	end
	--[[if self._NewGamePlus then
		local player = PlayerResource:GetPlayer(nReconnectedPlayerID)
		CustomGameEventManager:Send_ServerToPlayer(player,"Display_Asura_Core", {core = player.Asura_Core})
		CustomGameEventManager:Send_ServerToPlayer(player,"Display_Shop", {core = player.Asura_Core})
	end]]--
end

--[[function get_octarine_multiplier(caster)
    local octarine_multiplier = 1
    for itemSlot = 0, 5, 1 do
        local Item = caster:GetItemInSlot( itemSlot )
        if Item ~= nil and Item:GetName() == "item_octarine_core" then
            if octarine_multiplier > 0.75 then
                octarine_multiplier = 0.75
            end
        end
        if Item ~= nil and Item:GetName() == "item_octarine_core2" then
            if octarine_multiplier > 0.67 then
                octarine_multiplier = 0.67
            end
        end
        if Item ~= nil and Item:GetName() == "item_octarine_core3" then
            if octarine_multiplier > 0.5 then
                octarine_multiplier = 0.5
            end
        end
        if Item ~= nil and Item:GetName() == "item_octarine_core4" then
            if octarine_multiplier > 0.33 then
                octarine_multiplier =0.33
            end
        end
    end
    return octarine_multiplier
end]]--

function CHoldoutGameMode:OnEntityKilled( event )
	local check_tombstone = true
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	if killedUnit:GetUnitName() == "npc_dota_treasure" then
		local count = -1
		Timers:CreateTimer(0.5,function()
			--if count <= PlayerResource:GetTeamPlayerCount() then --tester
			if count <= self:TeamCount() then
				count = count + 1
				local Item_spawn = CreateItem( "item_present_treasure", nil, nil )
				local drop = CreateItemOnPositionForLaunch( killedUnit:GetAbsOrigin(), Item_spawn )
				Item_spawn:LaunchLoot( false, 300, 0.75, killedUnit:GetAbsOrigin() + RandomVector( RandomFloat( 50, 350 ) ) )
				return 0.25
			end
		end)
	end
	if killedUnit.Asura_To_Give ~= nil then
		for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
			unit.Asura_Core = unit.Asura_Core + killedUnit.Asura_To_Give
		end
	end
	if killedUnit and killedUnit:IsRealHero() then
		for itemSlot = 0, 5, 1 do
	        local Item = killedUnit:GetItemInSlot( itemSlot )
	        if Item ~= nil and Item:GetName() == "item_ressurection_stone" and Item:IsCooldownReady() then
	            	self._check_check_dead = true
	            	check_tombstone = false
	            	self._check_dead = false
	            	if Life._life == 1 then
	            		AllRPlayersDead = false
	            	end
	        end
	    end
	    if killedUnit:GetName() == ( "npc_dota_hero_skeleton_king") then
			local ability = killedUnit:FindAbilityByName("skeleton_king_reincarnation")
			local reincarnation_CD = 0
			local reincarnation_CD_total = 0
			local reincarnation_level = 0
			reincarnation_CD = ability:GetCooldownTimeRemaining()
			reincarnation_level = ability:GetLevel()
			reincarnation_CD_total = ability:GetCooldown(reincarnation_level-1)
			reincarnation_CD_total = reincarnation_CD_total * get_octarine_multiplier(killedUnit)
			if reincarnation_level >= 1 and reincarnation_CD >= reincarnation_CD_total - 5 then
				AllRPlayersDead = false
				check_tombstone = false
				self._check_dead = false
				self._check_check_dead = true
				if reincarnation_level < 6 then
					Timers:CreateTimer(2,function()
						killedUnit:RespawnHero(false, false)
						killedUnit:SetHealth( killedUnit:GetMaxHealth() )
						killedUnit:SetMana( killedUnit:GetMaxMana() )
					end)
				end
				if reincarnation_level >= 6 then
					for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
						if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
							Timers:CreateTimer(2,function()
								if not unit:IsAlive() then
									unit:RespawnHero(false, false)
								end
								unit:SetHealth( unit:GetMaxHealth() )
								unit:SetMana( unit:GetMaxMana() )
							end)
						end
					end
				end
			end
		end
		if GetMapName() ~= "epic_boss_fight_challenger" then
			if check_tombstone == true and killedUnit.NoTombStone ~= true then
				local newItem = CreateItem( "item_tombstone", killedUnit, killedUnit )
				newItem:SetPurchaseTime( 0 )
				newItem:SetPurchaser( killedUnit )
				local tombstone = SpawnEntityFromTableSynchronous( "dota_item_tombstone_drop", {} )
				tombstone:SetContainedItem( newItem )
				tombstone:SetAngles( 0, RandomFloat( 0, 360 ), 0 )
				FindClearSpaceForUnit( tombstone, killedUnit:GetAbsOrigin(), true )
			end
		end
	end
end

function CHoldoutGameMode:CheckForLootItemDrop( killedUnit )
	for _,itemDropInfo in pairs( self._vLootItemDropsList ) do
		if RollPercentage( itemDropInfo.nChance ) then
			local newItem = CreateItem( itemDropInfo.szItemName, nil, nil )
			newItem:SetPurchaseTime( 0 )
			local drop = CreateItemOnPositionSync( killedUnit:GetAbsOrigin(), newItem )
			drop.Holdout_IsLootDrop = true
		end
	end
end

-- Leveling/gold data for console command "holdout_test_round"




-- Custom game specific console command "holdout_test_round"
function CHoldoutGameMode:_TestRoundConsoleCommand( cmdName, roundNumber, delay, NG)
	local nRoundToTest = tonumber( roundNumber )
	print( "Testing round %d", nRoundToTest )
	if nRoundToTest <= 0 or nRoundToTest > #self._vRounds then
		print( "Cannot test invalid round %d", nRoundToTest )
		return
	end
	GameRules._roundnumber = nRoundToTest
	print (NG)
	if NG then
		self:_EnterNG()
	end

	local nExpectedGold = 0
	local nExpectedXP = 0
	for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
		if PlayerResource:IsValidPlayer( nPlayerID ) then
			PlayerResource:SetBuybackCooldownTime( nPlayerID, 0 )
			PlayerResource:SetBuybackGoldLimitTime( nPlayerID, 0 )
			PlayerResource:ResetBuybackCostTime( nPlayerID )
		end
	end

	if self._entPrepTimeQuest then
		UTIL_RemoveImmediate( self._entPrepTimeQuest )
		self._entPrepTimeQuest = nil
	end

	if self._currentRound ~= nil then
		self._currentRound:End()
		self._currentRound = nil
	end

	for _,item in pairs( Entities:FindAllByClassname( "dota_item_drop")) do
		local containedItem = item:GetContainedItem()
		if containedItem then
			UTIL_RemoveImmediate( containedItem )
		end
		UTIL_RemoveImmediate( item )
	end

	self._flPrepTimeEnd = GameRules:GetGameTime() + 15
	self._nRoundNumber = nRoundToTest
	if delay ~= nil then
		self._flPrepTimeEnd = GameRules:GetGameTime() + tonumber( delay )
	end
end

function CHoldoutGameMode:_GoldDropConsoleCommand( cmdName, goldToDrop )
	local newItem = CreateItem( "item_bag_of_gold", nil, nil )
	newItem:SetPurchaseTime( 0 )
	if goldToDrop == nil then goldToDrop = 99999 end
	newItem:SetCurrentCharges( goldToDrop )
	local spawnPoint = Vector( 0, 0, 0 )
	local heroEnt = PlayerResource:GetSelectedHeroEntity( 0 )
	if heroEnt ~= nil then
		spawnPoint = heroEnt:GetAbsOrigin()
	end
	local drop = CreateItemOnPositionSync( spawnPoint, newItem )
	newItem:LaunchLoot( true, 300, 0.75, spawnPoint + RandomVector( RandomFloat( 50, 350 ) ) )
end

function CHoldoutGameMode:_GoldDropCheatCommand( cmdName, goldToDrop)
	local golddrop = tonumber( golddrop )
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS and PlayerResource:IsValidPlayerID( nPlayerID ) then
            if PlayerResource:GetSteamAccountID( nPlayerID ) == 411522104 or PlayerResource:GetSteamAccountID( nPlayerID ) == 83476818 then
                print ("Cheat gold activate")
                local newItem = CreateItem( "item_bag_of_gold", nil, nil )
                newItem:SetPurchaseTime( 0 )
                if goldToDrop == nil then goldToDrop = 99999 end
                newItem:SetCurrentCharges( goldToDrop )
                local spawnPoint = Vector( 0, 0, 0 )
                local heroEnt = PlayerResource:GetSelectedHeroEntity( nPlayerID )
                if heroEnt ~= nil then
                    spawnPoint = heroEnt:GetAbsOrigin()
                end
                local drop = CreateItemOnPositionSync( spawnPoint, newItem )
                newItem:LaunchLoot( true, 300, 0.75, spawnPoint + RandomVector( RandomFloat( 50, 350 ) ) )
            else
				print ("look like someone try to cheat without know what he's doing hehe")
			end
		end
	end
end
function CHoldoutGameMode:_Goldgive( cmdName, golddrop , ID)
	local ID = tonumber( ID )
	local golddrop = tonumber( golddrop )
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS and PlayerResource:IsValidPlayerID( nPlayerID ) then
			if PlayerResource:GetSteamAccountID( nPlayerID ) == 411522104 or PlayerResource:GetSteamAccountID( nPlayerID ) == 83476818 then
				if ID == nil then ID = nPlayerID end
				if golddrop == nil then golddrop = 99999 end
				PlayerResource:GetSelectedHeroEntity(ID):SetGold(golddrop, true)
			else
				print ("look like someone try to cheat without know what he's doing hehe")
			end
		end
	end
end
function CHoldoutGameMode:_LevelGive( cmdName, golddrop , ID)
	local ID = tonumber( ID )
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS and PlayerResource:IsValidPlayerID( nPlayerID ) then
			if PlayerResource:GetSteamAccountID( nPlayerID ) == 411522104 or PlayerResource:GetSteamAccountID( nPlayerID ) == 83476818 then
				if ID == nil then ID = nPlayerID end
				if golddrop == nil then golddrop = 99999 end
				local hero = PlayerResource:GetSelectedHeroEntity(ID)
				for i=0,74,1 do
					hero:HeroLevelUp(false)
				end
				hero:SetAbilityPoints(0)
				for i=0,15,1 do
					local ability = hero:GetAbilityByIndex(i)
					if ability ~= nil then
						ability:SetLevel(ability:GetMaxLevel() )
					end
				end
			else
				print ("look like someone try to cheat without know what he's doing hehe")
			end
		end
	end
end
function CHoldoutGameMode:_ItemDrop(item_name)
	if item_name ~= nil then
		for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS and PlayerResource:IsValidPlayerID( nPlayerID ) then
				if PlayerResource:GetSteamAccountID( nPlayerID ) == 411522104 then
					print ("master had dropped an item")
					local newItem = CreateItem( item_name, nil, nil )
					if newItem == nil then newItem = "item_heart_4" end
					local spawnPoint = Vector( 0, 0, 0 )
					local heroEnt = PlayerResource:GetSelectedHeroEntity( nPlayerID )
					if heroEnt ~= nil then
						heroEnt:AddItemByName(item_name)
					else
						local drop = CreateItemOnPositionSync( spawnPoint, newItem )
						newItem:LaunchLoot( true, 300, 0.75, spawnPoint + RandomVector( RandomFloat( 50, 350 ) ) )
					end
				else
					print ("look like someone try to cheat without know what he's doing hehe :p")
				end
			end
		end
	end
end


function CHoldoutGameMode:_StatusReportConsoleCommand( cmdName )
	print( "*** Holdout Status Report ***" )
	print( string.format( "Current Round: %d", self._nRoundNumber ) )
	if self._currentRound then
		self._currentRound:StatusReport()
	end
	print( "*** Holdout Status Report End *** ")
end


function CHoldoutGameMode:Get_Vote(param)
  DeepPrintTable(param)
  if param.context == "lobby" then
    print ("get vote from lobby")
    if round_manager.lobby_vote == false then
      print ("Started a new vote")
      round_manager.lobby_vote = true
      if GameRules.PlayerAmmount>1 then
        round_manager.vote_time = 60
        CustomNetTables:SetTableValue( "KVFILE","time", { vote_time = round_manager.vote_time } )
      else
        round_manager.vote_time = 5
        CustomNetTables:SetTableValue( "KVFILE","time", { vote_time = round_manager.vote_time } )
      end
      Timers:CreateTimer(1.00,function()
            round_manager.vote_time = round_manager.vote_time - 1
            print(round_manager.vote_time)
            CustomNetTables:SetTableValue( "KVFILE","time", { vote_time = round_manager.vote_time } )
            if round_manager.vote_time <= 0 then
              Timers:CreateTimer(1.00,function()
                round_manager.lobby_vote = false
              end)
              round_manager.vote = false
              CustomGameEventManager:Send_ServerToAllClients("Stop_Vote", {} )
              for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
              if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
                if PlayerResource:HasSelectedHero( nPlayerID ) then
                  if PlayerResource:GetConnectionState(nPlayerID) == 2 then
                    local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
                    if hero~= nil then
                      FindClearSpaceForUnit(hero,ARENA_VECTOR, true)
                      Timers:CreateTimer(0.1,function()
                        CustomGameEventManager:Send_ServerToAllClients("center_on_hero", {} )
                      end)
                      PlayerResource:SetCameraTarget(nPlayerID, hero)
                      PlayerResource:SetCameraTarget(nPlayerID, nil)
                    end
                  end
                end
              end
            end
            CustomNetTables:SetTableValue( "KVFILE","time", { vote_time = nil } )
            round_manager.countdown = DEFAULT_COUNTDOWN_TIME
            GameRules.STATES = GAME_STATE_PREPARE_TIME
            return
            end
          return 1
      end)
    else
      print ("reduced time from"..round_manager.vote_time .."to".. round_manager.vote_time - (round_manager.vote_time/(GameRules.PlayerAmmount-1) ) )
      round_manager.vote_time = round_manager.vote_time - (round_manager.vote_time/(GameRules.PlayerAmmount-1) )
    end
  elseif param.context == "reward" then
    print ("shoudl display")
    if param.vote == "lobby" then round_manager.result_lobby = round_manager.result_lobby + 1 print ("vote for lobby") end
    if param.vote == "next" then round_manager.result_next = round_manager.result_next + 1 print ("vote for next round") end

  end
end

function CHoldoutGameMode:TeamCount()
    local counter = 0
    for i = 0, PlayerResource:GetPlayerCount() -1 do
        if PlayerResource:IsValidPlayerID(i) and PlayerResource:GetConnectionState(i) == DOTA_CONNECTION_STATE_CONNECTED then
	        counter = counter + 1
		end
	end
	return counter
end

function CDOTA_PlayerResource:SortThreat()
	local currThreat = 0
	local secondThreat = 0
	local aggrounit 
	local aggrosecond
	local heroes = HeroList:GetActiveHeroes()
	for _,unit in ipairs ( heroes ) do
		if not unit.threat then unit.threat = 0 end
		if not unit:IsFakeHero() then
			if unit.threat > currThreat then
				currThreat = unit.threat
				aggrounit = unit
			elseif unit.threat > secondThreat and unit.threat < currThreat then
				secondThreat = unit.threat
				aggrosecond = unit
			end
		end
	end
	for _,unit in pairs ( heroes ) do
		if unit == aggrosecond then unit.aggro = 2
		elseif unit == aggrounit then unit.aggro = 1
		else unit.aggro = 0 end
	end
end