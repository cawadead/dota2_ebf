LinkLuaModifier("modifier_lion_finger_of_death_ebf_bonus", "heroes/hero_lion/lion_finger_of_death_ebf.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lion_finger_of_death_ebf_death", "heroes/hero_lion/lion_finger_of_death_ebf.lua", LUA_MODIFIER_MOTION_NONE)

lion_finger_of_death_ebf = class({})

function lion_finger_of_death_ebf:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
	end
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function lion_finger_of_death_ebf:GetAOERadius()
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("splash_radius_scepter")
	end
end

function lion_finger_of_death_ebf:GetCastRange(vLocation, hTarget)
	-- if self:GetCaster():HasScepter() then
		-- return self:GetSpecialValueFor("cast_range_scepter")
	-- end
	return self:GetSpecialValueFor("cast_range")
end

function lion_finger_of_death_ebf:GetCooldown(iLevel)
	-- if self:GetCaster():HasScepter() then
		-- return self:GetSpecialValueFor("cooldown_scepter")
	-- end
	return self.BaseClass.GetCooldown(self, iLevel)
end

function lion_finger_of_death_ebf:GetManaCost(iLevel)
	-- if self:GetCaster():HasScepter() then
		-- return self:GetSpecialValueFor("mana_cost_scepter")
	-- end
	return self.BaseClass.GetManaCost(self, iLevel)
end

function lion_finger_of_death_ebf:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local targets = {target}

		local damage_delay = self:GetSpecialValueFor("damage_delay")
		local kill_grace_duration = self:GetSpecialValueFor("kill_grace_duration")
		local splash_radius = self:GetSpecialValueFor("splash_radius_scepter")
	 
		local base_damage = self:GetSpecialValueFor(value_if_scepter(caster, "damage_scepter", "damage"))
		local damage_per_kill = self:GetSpecialValueFor("damage_per_kill")
		local extra_int = GetSpecialValueFor(self, "damage_per_int") * caster:GetIntellect() or 0
		local kill_count = caster:GetModifierStackCount("modifier_lion_finger_of_death_ebf_bonus", nil)
		local damage = math.ceil((base_damage + extra_int + damage_per_kill * kill_count) / 1)

		caster:EmitSound("Hero_Lion.FingerOfDeath")

		if caster:HasScepter() then
			targets = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, splash_radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		end

		for _, target in pairs(targets) do
			_PlayEffect(caster, target)

			local sound_default = "Hero_Lion.FingerOfDeathImpact"
			local sound_immortal = "Hero_Lion.FingerOfDeathImpact.Immortal"
			local sound_name = value_if_scepter(caster, sound_immortal, sound_default)
			target:EmitSound(sound_name)

			if not target:TriggerSpellAbsorb(self) then
				if caster:HasTalent("special_bonus_finger_of_death_health_inf_kill_duration") then
					target:AddNewModifier(caster, self, "modifier_lion_finger_of_death_ebf_death", {duration = nil})
				else
					target:AddNewModifier(caster, self, "modifier_lion_finger_of_death_ebf_death", {duration = kill_grace_duration * (1 - target:GetStatusResistance())})
				end

				for i = 1, 1 do
					Timers:CreateTimer(damage_delay * FrameTime(), function()
						if target ~= nil and IsValidEntity(target) and target:IsAlive() and (not target:IsMagicImmune() or caster:HasScepter()) then
							ApplyDamage({
								attacker = caster,
								victim = target,
								damage = damage,
								damage_type = DAMAGE_TYPE_MAGICAL,
								ability = self,
							})
						end
					end)
				end
			end
		end
	end
end

function _PlayEffect(caster, target)
	local particle_name_normal = "particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf"
	local particle_name_ti8 = "particles/econ/items/lion/lion_ti8/lion_spell_finger_of_death_charge_ti8.vpcf"
	particle_name_ti8 = particle_name_normal
	local particle_name = value_if_scepter(caster, particle_name_ti8, particle_name_normal)
	
	local particle_finger_fx = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(particle_finger_fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle_finger_fx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(particle_finger_fx, 2, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_finger_fx, 3, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_finger_fx, 4, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_finger_fx, 5, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_finger_fx, 6, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_finger_fx, 7, target:GetAbsOrigin())
	ParticleManager:SetParticleControlEnt(particle_finger_fx, 10, caster, PATTACH_ABSORIGIN, "attach_attack2", caster:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particle_finger_fx)
end

--------------------------------------------------------------------------------

modifier_lion_finger_of_death_ebf_bonus = class({})
function modifier_lion_finger_of_death_ebf_bonus:IsBuff() return true end
function modifier_lion_finger_of_death_ebf_bonus:IsPermanent() return true end
function modifier_lion_finger_of_death_ebf_bonus:IsPurgable() return false end
function modifier_lion_finger_of_death_ebf_bonus:RemoveOnDeath() return false end
function modifier_lion_finger_of_death_ebf_bonus:OnCreated() if not IsServer() then return end self:SetStackCount(1) end
function modifier_lion_finger_of_death_ebf_bonus:OnRefresh() if not IsServer() then return end self:IncrementStackCount() end
function modifier_lion_finger_of_death_ebf_bonus:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP, MODIFIER_PROPERTY_HEALTH_BONUS} 
end
function modifier_lion_finger_of_death_ebf_bonus:OnStackCountChanged(old)
	if IsServer() then self:GetParent():CalculateStatBonus(true) end
end
function modifier_lion_finger_of_death_ebf_bonus:GetModifierHealthBonus()
	return self:GetStackCount() * self:GetParent():FindTalentValue("special_bonus_finger_of_death_health_per_kill")
end
function modifier_lion_finger_of_death_ebf_bonus:OnTooltip() return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("damage_per_kill") end


modifier_lion_finger_of_death_ebf_death = class({})
function modifier_lion_finger_of_death_ebf_death:IsHidden() return false end
function modifier_lion_finger_of_death_ebf_death:IsPurgable() return false end
function modifier_lion_finger_of_death_ebf_death:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_lion_finger_of_death_ebf_death:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end
function modifier_lion_finger_of_death_ebf_death:OnTooltip()
	return self:GetAbility():GetSpecialValueFor("damage_per_kill")
end
function modifier_lion_finger_of_death_ebf_death:OnRemoved()
	if not IsServer() then return end
	if not self:GetParent():IsAlive() then
		self:GetParent():EmitSoundParams("Hero_Lion.KillCounter", 1, 0.5, 0)
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lion_finger_of_death_ebf_bonus", {})
	end
end

--------------------------------------------------------------------------------

function value_if_scepter(npc, ifYes, ifNot)
	if npc:HasScepter() then
		return ifYes
	end
	return ifNot
end

--talents
function HasTalent(unit, talentName)
	if unit:HasAbility(talentName) then
		if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
	end
	return false
end

function GetSpecialValueFor(ability, value)
	local base = ability:GetSpecialValueFor(value)
	local talentName
	local valueName
	local kv = ability:GetAbilityKeyValues()
	for k,v in pairs(kv) do -- trawl through keyvalues
		if k == "AbilitySpecial" then
			for l,m in pairs(v) do
				if m[value] then
					talentName = m["LinkedSpecialBonus"]
					valueName = m["LinkedSpecialBonusField"]
				end
			end
		end
	end
	if talentName then 
		local talent = ability:GetCaster():FindAbilityByName(talentName)
		if talent and talent:GetLevel() > 0 then
			valueName = valueName or "value"
			base = base + talent:GetSpecialValueFor(valueName) 
		end
	end
	return base
end
