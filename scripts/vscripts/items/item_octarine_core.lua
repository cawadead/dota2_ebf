item_octarine_core2 = class({})

function item_octarine_core2:GetIntrinsicModifierName()
	return "modifier_item_octarine_core_ebf"
end

item_octarine_core = class(item_octarine_core2)
item_octarine_core3 = class(item_octarine_core2)
item_octarine_core4 = class(item_octarine_core2)
item_octarine_core5 = class(item_octarine_core2)

function item_octarine_core5:IsRefreshable()
	return false
end

function item_octarine_core5:OnSpellStart()
	self:GetCaster():RefreshAllCooldowns( true )
	
	EmitSoundOn( "DOTA_Item.Refresher.Activate", self:GetCaster() )
	ParticleManager:FireParticle( "particles/items2_fx/refresher.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
end

item_asura_core = class(item_octarine_core5)

modifier_item_octarine_core_ebf = class({})
LinkLuaModifier( "modifier_item_octarine_core_ebf", "items/item_octarine_core.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_octarine_core_ebf:OnCreated()
	self:OnRefresh()
end

function modifier_item_octarine_core_ebf:OnRefresh()
	self.bonus_mana_regen = self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
	self.bonus_mana = self:GetAbility():GetSpecialValueFor("bonus_mana")
	self.bonus_health = self:GetAbility():GetSpecialValueFor("bonus_health")
	self.bonus_all = self:GetAbility():GetSpecialValueFor("bonus_all")
	self.cast_range_bonus = self:GetAbility():GetSpecialValueFor("cast_range_bonus")
	self.cdr = self:GetAbility():GetSpecialValueFor("bonus_cooldown")
	
	self.bonus_all_pr = self:GetAbility():GetSpecialValueFor("bonus_all_pr")
	if self.bonus_all_pr > 0 and IsServer() then
		self:StartIntervalThink(0.25)
	end
end

function modifier_item_octarine_core_ebf:OnIntervalThink()
	local stack = GameRules._roundnumber
	if stack ~= self:GetStackCount() then
		self:SetStackCount( stack )
	end
end

function modifier_item_octarine_core_ebf:DeclareFunctions(params)
local funcs = {
    MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    MODIFIER_PROPERTY_HEALTH_BONUS,
    MODIFIER_PROPERTY_MANA_BONUS,
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
	MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
	MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
    }
    return funcs
end

function modifier_item_octarine_core_ebf:GetModifierConstantManaRegen()
	return self.bonus_mana_regen
end

function modifier_item_octarine_core_ebf:GetModifierManaBonus()
	return self.bonus_mana
end

function modifier_item_octarine_core_ebf:GetModifierHealthBonus()
	return self.bonus_health
end

function modifier_item_octarine_core_ebf:GetModifierBonusStats_Strength()
	return self.bonus_all + self.bonus_all_pr * self:GetStackCount()
end

function modifier_item_octarine_core_ebf:GetModifierBonusStats_Intellect()
	return self.bonus_all + self.bonus_all_pr * self:GetStackCount()
end

function modifier_item_octarine_core_ebf:GetModifierBonusStats_Agility()
	return self.bonus_all + self.bonus_all_pr * self:GetStackCount()
end

function modifier_item_octarine_core_ebf:GetModifierPercentageCasttime()
	return self.cdr
end

function modifier_item_octarine_core_ebf:GetModifierPercentageCooldown()
	return self.cdr
end

function modifier_item_octarine_core_ebf:GetModifierCastRangeBonusStacking()
	return self.cast_range_bonus
end

function modifier_item_octarine_core_ebf:IsHidden()
	return true
end