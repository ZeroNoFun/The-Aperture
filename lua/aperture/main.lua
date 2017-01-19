--[[

	APERTURE API MAIN
	
]]

AddCSLuaFile( )

APERTURESCIENCE = { }

function APERTURESCIENCE:PlaySequence(self, seq)

	if !self:IsValid() then
		return
	end
	
	local sequence = self:LookupSequence(seq)
	self:ResetSequence(sequence)

	self:SetPlaybackRate(1.0)
	self:SetSequence(sequence)
	
	return self:SequenceDuration(sequence)
end