AddCSLuaFile()

local WireAddon = WireAddon or WIRE_CLIENT_INSTALLED

ENT.Editable				= true
ENT.PrintName				= "Aperture base class"
ENT.AutomaticFrameAdvance 	= true
ENT.Purpose 				= "Base for aperture SEnts"
ENT.RenderGroup				= RENDERGROUP_BOTH
ENT.Spawnable 				= false
ENT.AdminOnly 				= false

ENT.IsAperture 				= true
ENT.IsConnectable 			= false

if WireAddon then
	DEFINE_BASECLASS("base_wire_entity")
	ENT.WireDebugName = "Aperture Base"
else
	DEFINE_BASECLASS("base_gmodentity")
end

-- function ENT:Initialize()

	-- if CLIENT then
	
		-- return
	-- end
-- end

function ENT:Draw()
	self:DrawModel()
end

function ENT:PlaySequence(seq, rate)
	local sequence = self:LookupSequence(seq)
	self:ResetSequence(sequence)
	self:SetPlaybackRate(rate)
	self:SetSequence(sequence)
	return self:SequenceDuration(sequence)
end