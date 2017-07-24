AddCSLuaFile( )
DEFINE_BASECLASS("base_aperture_turret")

local WireAddon = WireAddon or WIRE_CLIENT_INSTALLED

ENT.PrintName 		= "Portal Turret Floor"

ENT.TurretEyePos 				= Vector(11.7, 0, 36.8)
ENT.TurretSoundFound 			= "TA:TurretDeployVO"
ENT.TurretSoundSearch 			= "TA:TurretSearchVO"
ENT.TurretSoundAutoSearch 		= "TA:TurretAutoSearchVO"
ENT.TurretRetract				= "TA:TurretRetractVO"
ENT.TurretSoundFizzle 			= "TA:TurretFizzleVO"
ENT.TurretSoundPickup 			= "TA:TurretPickupVO"
ENT.TurretDisabled				= "TA:TurretDisabledVO"

if WireAddon then
	ENT.WireDebugName = ENT.PrintName
end

function ENT:Initialize()

	self.BaseClass.Initialize(self)
	
	if SERVER then
		self:SetModel("models/npcs/turret/turret.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		
		if self:GetStartEnabled() then self:Enable(true) end

		if not WireAddon then return end
		self.Inputs = Wire_CreateInputs(self, {"Enable"})
	end

	if CLIENT then
		
	end
end

-- no more client side
if CLIENT then return end
