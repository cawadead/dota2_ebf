bossPowerScale = class({})

MAX_STATUS_RESIST = 60

function bossPowerScale:OnCreated(keys)
	self:OnRefresh()
end

function bossPowerScale:OnRefresh(keys)
	local roundNumber = math.floor( self:GetStackCount() / 100 )
	local difficulty = math.floor( ( self:GetStackCount() % 100 ) / 10 ) / 100
	local playerNumber = ( self:GetStackCount() % 10 ) / 100
	
	-- function to scale scaling down early on, ramping it up starting from round 17
	local logisticFunction = 0.1 + 1/ ( 1 + math.exp(-0.25*(roundNumber-17)) )
	
	self.bonusArmor = ( ( (1 + playerNumber * 1) * (1 + difficulty * 3) - 1 ) * 100 ) * logisticFunction
	self.bonusDamage = ( ( (1 + playerNumber * 4) * (1 + difficulty * 20) - 1 ) * 100 ) * logisticFunction
	self.bonusSpellDamage = ( ( (1 + difficulty * 25) - 1 ) * 100 ) * logisticFunction
	self.baseStatusResistance = 40 * roundNumber/38
	self.actualStatusResistance = self.baseStatusResistance
	
	self.statusResistIncreasePerTick = self.baseStatusResistance * 0.25
	self:StartIntervalThink( 0.25 )
	
	if IsServer() then	
		self:GetParent().bossOriginalModel = self:GetParent():GetModelName()
	end
end

function bossPowerScale:OnIntervalThink()
	if self:GetParent():IsStunned() or self:GetParent():IsSilenced() or self:GetParent():IsDisarmed() or self:GetParent():IsHexed() then
		if self.actualStatusResistance == MAX_STATUS_RESIST then -- make status immune for 5 seconds.
			if IsServer() then 
				EmitSoundOn( "Item.LotusOrb.Activate", self:GetParent() )
				self:GetParent():AddNewModifier( self:GetParent(), nil, "status_immune", {duration = 5} )
			end
		else
			self.actualStatusResistance = math.min( self.actualStatusResistance + self.statusResistIncreasePerTick, MAX_STATUS_RESIST )
		end
		
	elseif self.baseStatusResistance < self.actualStatusResistance then
		self.actualStatusResistance = math.max( self.actualStatusResistance - self.statusResistIncreasePerTick, self.baseStatusResistance )
	end
end

function bossPowerScale:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE --+ MODIFIER_ATTRIBUTE_MULTIPLE
end

function bossPowerScale:DeclareFunctions()
  local funcs = {
	MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
	MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
  }
  return funcs
end

function bossPowerScale:GetModifierPhysicalArmorBonus(event)
	return self.bonusArmor
end

function bossPowerScale:GetModifierBaseDamageOutgoing_Percentage(event)
	return self.bonusDamage
end

function bossPowerScale:GetModifierSpellAmplify_Percentage(event)
	return self.bonusSpellDamage
end

function bossPowerScale:GetModifierStatusResistanceStacking(event)
	return self.actualStatusResistance
end

function bossPowerScale:IsHidden()
  return true --change that to true when finished debuging
end

function bossPowerScale:IsDebuff()
  return false
end

function bossPowerScale:IsPurgable()
  return false
end