

if bossManager == nil then
	bossManager = class({})
end


function bossManager:Init(MainClass)

	self.MainClass = MainClass

end

function bossManager:EHPFix(EHP_GOAL,HP) --you enter the current HP
  local Multiplier = (EHP_GOAL/HP)
	return Multiplier
end

LinkLuaModifier( "bossHealthRescale", "modifier/bossHealthRescale.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "bossPowerScale", "modifier/bossPowerScale.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "status_immune", "modifier/status_immune.lua", LUA_MODIFIER_MOTION_NONE )


function bossManager:NewGamePlusBoss(spawnedUnit)

  if self.MainClass._NewGamePlus == true then
    local Number_Round = self.MainClass._nRoundNumber
    spawnedUnit.MaxEHP = (30000000 + (spawnedUnit.MaxEHP*Number_Round^1.5) )

    spawnedUnit:SetBaseDamageMin( (spawnedUnit:GetBaseDamageMin()+1000000) + 80000 * Number_Round )
    spawnedUnit:SetBaseDamageMax( (spawnedUnit:GetBaseDamageMax()+1500000) + 100000 * Number_Round )
    spawnedUnit:SetPhysicalArmorBaseValue( (spawnedUnit:GetPhysicalArmorBaseValue() + 50 ) * math.log( 1+Number_Round ) )
    spawnedUnit:SetBaseMagicalResistanceValue( (1 - (1-spawnedUnit:GetBaseMagicalResistanceValue()/100)*0.7)*100 )
  end
end


function bossManager:onBossSpawn(spawnedUnit)

	if spawnedUnit:IsCreature() then
	   --[[local difficulty_multiplier = (PlayerResource:GetTeamPlayerCount() / 7)^0.2
		spawnedUnit.MaxEHP = difficulty_multiplier*spawnedUnit:GetMaxHealth()
		--spawnedUnit:SetHealth(spawnedUnit:GetMaxHealth())
		--spawnedUnit:SetBaseDamageMin(difficulty_multiplier*spawnedUnit:GetBaseDamageMin())
		--spawnedUnit:SetBaseDamageMax(difficulty_multiplier*spawnedUnit:GetBaseDamageMax())
		spawnedUnit:SetPhysicalArmorBaseValue(difficulty_multiplier*spawnedUnit:GetPhysicalArmorBaseValue())
		--]]
		
		--[[spawnedUnit.MaxEHP = spawnedUnit:GetMaxHealth()
		spawnedUnit:SetHealth(spawnedUnit:GetMaxHealth())
		spawnqedUnit:SetBaseDamageMin(spawnedUnit:GetBaseDamageMin())
		spawnedUnit:SetBaseDamageMax(spawnedUnit:GetBaseDamageMax())
		spawnedUnit:SetPhysicalArmorBaseValue(spawnedUnit:GetPhysicalArmorBaseValue())]] --tester
		local HP_difficulty_multiplier = ( (7 or TeamCount()) / 5)^0.6 + 0.1 * ((7 or TeamCount())-1)
		local armor_difficulty_multiplier = ( (7 or TeamCount()) / 5)^0.6 + 0.1
		local DMG_difficulty_multiplier = ( (7 or TeamCount()) / 5)^0.3
		
		spawnedUnit.MaxEHP = HP_difficulty_multiplier*spawnedUnit:GetMaxHealth()
		spawnedUnit:SetHealth(spawnedUnit:GetMaxHealth())
		spawnedUnit:SetBaseDamageMin(DMG_difficulty_multiplier*spawnedUnit:GetBaseDamageMin())
		spawnedUnit:SetBaseDamageMax(DMG_difficulty_multiplier*spawnedUnit:GetBaseDamageMax())
		
		spawnedUnit:SetPhysicalArmorBaseValue( armor_difficulty_multiplier*spawnedUnit:GetPhysicalArmorBaseValue() )
    	self:NewGamePlusBoss(spawnedUnit)
		
    	if GetMapName() == "epic_boss_fight_boss_master" then 
			if spawnedUnit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
				Timers:CreateTimer(0.03,function()
					spawnedUnit:SetOwner(PlayerResource:GetSelectedHeroEntity(self.MainClass.boss_master_id))
					spawnedUnit:SetControllableByPlayer(self.MainClass.boss_master_id,true)

				end)
			end
		end
		
		if spawnedUnit.Holdout_IsCore then
			local powerScale = spawnedUnit:AddNewModifier(spawnedUnit, spawnedUnit, "bossPowerScale",{})
			powerScale:SetStackCount( GetRoundNumber() * 100 + GetGameDifficulty()*10 + (TeamCount() - 1) )
			powerScale:ForceRefresh( ) -- force client/server update
		end
		
		spawnedUnit.EHP_MULT = 1 
		if spawnedUnit:GetUnitName() ~= "npc_dota_boss36" then -- don't scale evil core ever
			Timers:CreateTimer( 0.1, function()
				if spawnedUnit.MaxEHP > 10000000 then
					spawnedUnit:SetBaseMaxHealth(10000000)
					spawnedUnit:SetMaxHealth(10000000)
					spawnedUnit:SetHealth(10000000)
					local EHP_MULT = self:EHPFix(spawnedUnit.MaxEHP,10000000)
					spawnedUnit.EHP_MULT = EHP_MULT
					spawnedUnit:SetBaseHealthRegen(spawnedUnit:GetBaseHealthRegen()/EHP_MULT)
					spawnedUnit:AddNewModifier(spawnedUnit, spawnedUnit, "bossHealthRescale",{})
				else
					spawnedUnit:SetBaseMaxHealth(spawnedUnit.MaxEHP)
					spawnedUnit:SetMaxHealth(spawnedUnit.MaxEHP)
					spawnedUnit:SetHealth(spawnedUnit.MaxEHP)
					spawnedUnit.EHP_MULT = 1
				end
			end)
		end
	end
end


function TeamCount()
    local counter = 0
    for i = 0, PlayerResource:GetPlayerCount() -1 do
        if PlayerResource:IsValidPlayerID(i) and PlayerResource:GetConnectionState(i) == DOTA_CONNECTION_STATE_CONNECTED then
	        counter = counter + 1
		end
	end
	return counter
end

function GetGameDifficulty()
	if GetMapName() == "epic_boss_fight_hard" then
		return 1
	elseif GetMapName() == "epic_boss_fight_impossible" then
		return 2
	elseif GetMapName() == "epic_boss_fight_boss_master" then
		return 3
	else
		return 0
	end
end

function GetRoundNumber()
	return GameRules._roundnumber
end