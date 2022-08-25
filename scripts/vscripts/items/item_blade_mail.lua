item_blade_mail2 = class({})
LinkLuaModifier( "modifier_blade_mail", "items/item_blade_mail.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_blade_mail_taunt", "items/item_blade_mail.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_blade_mail2:PiercesDisableResistance()
    return true
end

function item_blade_mail2:GetIntrinsicModifierName()
	return "modifier_blade_mail"
end

function item_blade_mail2:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Axe.Berserkers_Call", caster)
	EmitSoundOn("DOTA_Item.BladeMail.Activate", caster)

	if caster:HasModifier("modifier_blade_mail_taunt") then
		caster:RemoveModifierByName("modifier_blade_mail_taunt")
	end
	caster:AddNewModifier(caster,self, "modifier_blade_mail_taunt", {Duration = self:GetSpecialValueFor("duration")})
end

item_blade_mail3 = class(item_blade_mail2)
item_blade_mail4 = class(item_blade_mail2)
item_blade_mail5 = class(item_blade_mail2)

modifier_blade_mail = class({})

function modifier_blade_mail:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_blade_mail:OnCreated()
	self.health_regen = self:GetAbility():GetSpecialValueFor("health_regen")
	self.bonus_all = self:GetAbility():GetSpecialValueFor("bonus_all")
	self.bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	
	self.reflection_pct = self:GetSpecialValueFor("passive_reflection_pct") / 100
	self.active_reflection_pct = self:GetSpecialValueFor("active_reflection_pct") / 100
	self.reflection_const = self:GetSpecialValueFor("passive_reflection_constant")
end

function modifier_blade_mail:DeclareFunctions(params)
local funcs = {
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return funcs
end

function modifier_blade_mail:OnTakeDamage(params)
    local hero = self:GetParent()
    local dmg = params.damage
	local dmgtype = params.damage_type
	local attacker = params.attacker
	local blademailActive = hero:HasModifier("modifier_blade_mail_taunt")

	if HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) then return end
	
	if attacker:GetTeamNumber()  ~= hero:GetTeamNumber() and params.unit == hero then
		if blademailActive or params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
			local baseDamage = self.reflection_const
			local damagePct = params.original_damage * TernaryOperator( self.reflection_pct + self.active_reflection_pct, blademailActive, self.reflection_pct )
			
			EmitSoundOn("DOTA_Item.BladeMail.Damage", hero)
			self:GetAbility():DealDamage( hero, attacker, baseDamage + damagePct, {damage_type = params.damage_type, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_REFLECTION} )
		end
	end
end

function modifier_blade_mail:GetModifierConstantHealthRegen()
	return self.health_regen
end

function modifier_blade_mail:GetModifierBonusStats_Strength()
	return self.bonus_all
end

function modifier_blade_mail:GetModifierBonusStats_Intellect()
	return self.bonus_all
end

function modifier_blade_mail:GetModifierBonusStats_Agility()
	return self.bonus_all
end

function modifier_blade_mail:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end

function modifier_blade_mail:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

function modifier_blade_mail:IsHidden()
	return true
end

modifier_blade_mail_taunt = class({})
function modifier_blade_mail_taunt:OnCreated( kv )
    self.reflect = self:GetAbility():GetSpecialValueFor( "active_reflection_pct" )
	if IsServer() then
		self:StartIntervalThink( 0.25 )
	end
end

function modifier_blade_mail_taunt:OnRefresh( kv )
    self.reflect = self:GetAbility():GetSpecialValueFor( "active_reflection_pct" )
end

function modifier_blade_mail_taunt:OnIntervalThink()
	local caster = self:GetCaster()
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1) ) do
		if enemy:GetForceAttackTarget() == nil then
			enemy:SetForceAttackTarget( caster )
			enemy:SetAggroTarget( caster )
			enemy:SetAttacking( caster )
		end
	end
end

function modifier_blade_mail_taunt:OnDestroy( kv )
	if IsServer then
		local caster = self:GetCaster()
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1) ) do
			if enemy:GetForceAttackTarget() == caster then
				enemy:SetForceAttackTarget( nil )
				enemy:SetAggroTarget( nil )
				enemy:SetAttacking( nil )
			end
		end
	end
end

function modifier_blade_mail_taunt:GetEffectName()
	return "particles/items_fx/blademail.vpcf"
end

function modifier_blade_mail_taunt:GetStatusEffectName()
	return "particles/status_fx/status_effect_blademail.vpcf"
end

function modifier_blade_mail_taunt:StatusEffectPriority()
	return 10
end

function modifier_blade_mail_taunt:IsBuff()
	return true
end

