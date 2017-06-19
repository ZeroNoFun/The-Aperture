AddCSLuaFile( )
DEFINE_BASECLASS( "gasl_base_ent" )

ENT.PrintName		= "Crusher"
ENT.Category		= "Aperture Science"
ENT.Editable		= true
ENT.Spawnable		= true
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SpawnFunction( ply, trace, ClassName )
	if ( !trace.Hit ) then return end
	local ent = ents.Create( ClassName )
	ent:SetPos( trace.HitPos + trace.HitNormal / 2 )
	ent:Spawn()
	ent:SetAngles(trace.HitNormal:Angle())
	ent:GetPhysicsObject():Sleep()
	ent:GetPhysicsObject():EnableMotion(false)
	ent:Activate()
	ent.Owner = ply
	return ent
end

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Busy")
	self:NetworkVar("Bool", 1, "Enable")
end


function ENT:Draw()
	self:DrawModel()
end

function ENT:Initialize()
	self.BaseClass.Initialize( self )
	if CLIENT then return end
	self:SetUseType(3)	-- SIMPLE_USE Defined at garry's mod lua wiki
	self:SetModel( "models/aperture/crusher.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetBusy(false)
	if ( !WireAddon ) then return end
	self.Inputs = Wire_CreateInputs( self, { "Enable" } )
	return true
end

function ENT:TriggerInput(iname, value)
	if ( !WireAddon ) then return end
	
	if (iname == "Enable") and tobool(value) then self:StartSmash() end
end

function ENT:Think()
	if not IsValid(self) then return end
	self:NextThink(CurTime() + 0.1)
	self.BaseClass.Think(self)
	return true
end

function ENT:StartSmash()
	if not IsValid(self) then return end
	if self:GetBusy() then return end
	self:SetBusy(true)
	APERTURESCIENCE:PlaySequence(self, "smash_big", 1.0)
	timer.Simple(0.6, function () if IsValid(self) then self:Smash() end end)
	timer.Simple(1.6, function() 
		if IsValid(self) then
			self:SetBusy(false)
			sound.Play("TA.CrusherOpen", self:GetPos() + self:GetForward() * 100, 75, 100, 1) 
		end
	end)
end

function ENT:Smash()
	sound.Play("TA.CrusherSmash", self:GetPos() + self:GetForward() * 100, 75, 100, 1) 
	//self:EmitSound("TA.CrusherSmash")
	util.ScreenShake(self:GetPos(), 100, 10, 1, 1500)
end