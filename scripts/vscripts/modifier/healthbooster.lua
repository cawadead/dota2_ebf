healthBooster = class({})

function healthBooster:OnCreated(keys)
end

function healthBooster:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE --+ MODIFIER_ATTRIBUTE_MULTIPLE
end

function healthBooster:OnCreated()
   self.HpPerStr=self:GetAbility():GetSpecialValueFor("health_per_str")
end

function healthBooster:OnRefresh()
   self.HpPerStr=math.max(self.HpPerStr, self:GetAbility():GetSpecialValueFor("health_per_str") )
end

function healthBooster:DeclareFunctions()
  local funcs = {
   MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS
  }
  return funcs
end


function healthBooster:GetModifierExtraHealthBonus()
  
  if (self:GetAbility() == nil) then
    self:GetParent():RemoveModifierByName(self:GetName())
    return 0
  end

  return self.HpPerStr*math.floor( self:GetParent():GetStrength() + 0.5 )
end

function healthBooster:IsHidden()
  return true 
end

function healthBooster:IsDebuff()
  return false
end

function healthBooster:IsPurgable()
  return false
end

function healthBooster:CheckState()
  local state = {
  }

  return state
end
