status_immune = class({})

function status_immune:OnCreated()
	print("modifier added")
	if IsServer() then
		local fx = ParticleManager:CreateParticle("particles/items_fx/glyph.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(fx, 1, Vector( (self:GetParent():GetHullRadius() * 2 + 50) * self:GetParent():GetModelScale(), 1, 1) )
		self:AddEffect(fx)
	end
end

function status_immune:CheckState()
	return {[MODIFIER_STATE_ROOTED] = false,
			[MODIFIER_STATE_DISARMED] = false,
			[MODIFIER_STATE_SILENCED] = false,
			[MODIFIER_STATE_MUTED] = false,
			[MODIFIER_STATE_STUNNED] = false,
			[MODIFIER_STATE_HEXED] = false,
			[MODIFIER_STATE_FROZEN] = false,
			[MODIFIER_STATE_PASSIVES_DISABLED] = false,
			[MODIFIER_STATE_UNSLOWABLE] = true}
end

function status_immune:DeclareFunctions()
	return { MODIFIER_PROPERTY_MODEL_CHANGE,
			 MODIFIER_PROPERTY_OVERRIDE_ANIMATION_WEIGHT }
end

function status_immune:GetModifierModelChange()
	return self:GetParent().bossOriginalModel or self:GetParent():GetModelName()
end

function status_immune:GetOverrideAnimationWeight()
	return 0
end

function status_immune:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function status_immune:GetTexture()
	return "spawnlord_aura"
end