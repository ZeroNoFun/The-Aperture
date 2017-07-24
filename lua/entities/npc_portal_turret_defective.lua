AddCSLuaFile( )
DEFINE_BASECLASS("base_aperture_turret")

local WireAddon = WireAddon or WIRE_CLIENT_INSTALLED

ENT.PrintName 		= "Portal Turret Defective"

ENT.TurretEyePos 				= Vector(11.7, 0, 36.8)
ENT.TurretSoundFound 			= "TA:TurretDefectiveActivateVO"
ENT.TurretSoundSearch 			= "TA:TurretDetectiveAutoSearth"
ENT.TurretSoundAutoSearch 		= "TA:TurretDetectiveAutoSearth"
ENT.TurretRetract				= ""
ENT.TurretSoundFizzle 			= ""
ENT.TurretSoundPickup 			= ""
ENT.CantShoot					= true

if WireAddon then
	ENT.WireDebugName = ENT.PrintName
end

function ENT:Initialize()

	self.BaseClass.Initialize(self)
	
	if SERVER then
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
