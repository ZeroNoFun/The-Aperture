AddCSLuaFile()
DEFINE_BASECLASS("portalbutton_base")

ENT.PrintName		= "Wired Button (Ball)"
ENT.Spawnable		= istable(PortalButtons)
ENT.AdminOnly		= false
ENT.Category		= "Aperture Science"

local WireAddon = WireAddon or WIRE_CLIENT_INSTALLED
local PortalButtons = PortalButtons

if ( WireAddon ) then
	ENT.WireDebugName = "Floor Button (Ball)"
end

if CLIENT then

	function ENT:Initialize()
		self.BaseClass.Initialize( self )
	end
	
	function ENT:Think()
		self.BaseClass.BaseClass.Think( self )
	end
	
	return
	
end

function ENT:SpawnFunction( ply, tr )

	if ( !APERTURESCIENCE.ALLOWING.floor_button && !ply:IsSuperAdmin() ) then ply:PrintMessage( HUD_PRINTTALK, "This entity is blocked" ) return end
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 1
	local ent = ents.Create( "sent_portalbutton_ball" )
	if ( !IsValid( ent ) ) then return end
	
	ent.Owner = ply
	ent.CanUpdateSettings = true

	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
end

local AcceptedModels = nil
function ENT:Initialize()
	self:SetModel( "models/portal_custom/ball_button_custom.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	
	self.PressTriggerHeight = 11
	self.PressTriggerSize = 17
	self.UsePlayerTrigger = false
	self.PressTraceCount = 2

	if !AcceptedModels and PortalButtons then
		AcceptedModels = PortalButtons.GetAcceptedObjects()["Spheres"] or {}
	end

	self.BaseClass.Initialize(self)
	self.BaseClass.BaseClass.Initialize( self )
	
	self:AddOutput( "Activated", true )

end

function ENT:OnUpdateSettings()
	self.PressTriggerHeight = 11
	self.PressTriggerSize = 17
	self.UsePlayerTrigger = false
	self.PressTraceCount = 2
end

function ENT:Filter( ent )
	if !AcceptedModels then return false end
	if !AcceptedModels[ent:GetModel()] then return false end

	return true
end

function ENT:OnChangePressEnt(ent_new, ent_old)
	if !AcceptedModels then return end

	if IsValid(ent_old) then
		if !ent_old:IsPlayer() then
			local model = ent_old:GetModel()
			local skin = ent_old:GetSkin()
			local skindata = AcceptedModels[model] or {}

			local SkinChange = (skindata.off or {})[skin]
			if SkinChange then
				ent_old:SetSkin(SkinChange)
			end

			ent_old:PhysWake()
		end
	end
	
	if IsValid(ent_new) then
		if !ent_new:IsPlayer() then
			local model = ent_new:GetModel()
			local skin = ent_new:GetSkin()
			local skindata = AcceptedModels[model] or {}

			local SkinChange = (skindata.on or {})[skin]
			if SkinChange then
				ent_new:SetSkin(SkinChange)
			end

			ent_new:PhysWake()
		end
	end
end

function ENT:OnTurnOn()
	self:SetSkin(1)
	self:SetAnim(2)
end

function ENT:OnTurnOFF()
	self:SetSkin(0)
	self:SetAnim(3)
end