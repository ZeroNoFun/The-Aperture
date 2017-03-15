AddCSLuaFile()
DEFINE_BASECLASS("gasl_floor_button_base")

local WireAddon = WireAddon or WIRE_CLIENT_INSTALLED
local PortalButtons = PortalButtons

if ( WireAddon ) then
	ENT.WireDebugName = "Floor Button (Old)"
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

if CLIENT then return end

function ENT:SpawnFunction( ply, tr )

	if ( !APERTURESCIENCE.ALLOWING.floor_button && !ply:IsSuperAdmin() ) then ply:PrintMessage( HUD_PRINTTALK, "This entity is blocked" ) return end

	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 1
	local ent = ents.Create( "sent_portalbutton_old" )
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
	self:SetModel( "models/portal_custom/underground_floor_button_custom.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )

	if !AcceptedModels and PortalButtons then
		AcceptedModels = PortalButtons.GetAcceptedObjects()["All"] or {}
	end

	self.BaseClass.Initialize( self )
	self.BaseClass.BaseClass.Initialize( self )
	
	self:AddOutput( "Activated", true )
	
end

function ENT:OnUpdateSettings()
	self:CreatePhys("models/portal_custom/underground_floor_button_custom_phy.mdl")
	if !IsValid( self.ButtonPhysEnt ) then
		self:Remove()
		return
	end

	self.PressTriggerHeight = 17
	self.PressTriggerSize = 32
	self.UsePlayerTrigger = true
	self.PressTraceCount = 8
end

function ENT:Filter( ent )
	if !AcceptedModels then return false end
	if !AcceptedModels[ent:GetModel()] then return false end

	return true
end

local StopVector = Vector()

function ENT:OnChangePressEnt(ent_new, ent_old)
	if !AcceptedModels then return end

	if IsValid(ent_old) then
		if !ent_old:IsPlayer() then
			ent_old:PhysWake()
		end
	end
	
	if IsValid(ent_new) then
		self:EnableButtonPhys( false )

		if !ent_new:IsPlayer() then
			ent_new:PhysWake()
		end
	end
end

function ENT:OnTurnOn()
	self:SetAnim(3)
	self:EnableButtonPhys( false )
end

function ENT:OnTurnOFF()
	self:SetAnim(1)
	self:EnableButtonPhys( true )
end