AddCSLuaFile( )
DEFINE_BASECLASS( "gasl_base_ent" )

ENT.PrintName		= "Ball launcher"
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

function ENT:Use( activator, caller, usetype, val )
	self:LaunchBall()
end

function ENT:Initialize()
	self.BaseClass.Initialize( self )
	if CLIENT then return end
	self:SetUseType(3)	-- SIMPLE_USE Defined at garry's mod lua wiki
	self:SetModel( "models/props/combine_ball_launcher.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetBusy(false)
	if ( !WireAddon ) then return end
	self.Inputs = Wire_CreateInputs( self, { "Enable" } )
	return true
end

function ENT:TriggerInput( iname, value )
	if ( !WireAddon ) then return end
	--if ( iname == "Enable" ) then self:SetEnable(tobool(value)) end
	if (iname == "Enable") and tobool(value) then self:LaunchBall() end
end

function ENT:Think()
	if not IsValid(self) then return end
	self:NextThink(CurTime() + 0.1)
	self.BaseClass.Think(self)
	return true
end

function ENT:LaunchBall()
	if not IsValid(self) then return end
	if self:GetBusy() then return end
	self:SetBusy(true)
	APERTURESCIENCE:PlaySequence(self, "open", 1.0)
	timer.Simple(0.5, function () if IsValid(self) and SERVER then self:SpawnCombineBall() end end)
	timer.Simple(1, function() if IsValid(self) then APERTURESCIENCE:PlaySequence(self, "close", 1.0) end end)
	timer.Simple(2, function() if IsValid(self) then self:SetBusy(false) end end)
end

function ENT:SpawnCombineBall()
	local ent = ents.Create("point_combine_ball_launcher") 
	if not IsValid(ent) then return end
	ent:SetKeyValue( "minspeed",600 )
	ent:SetKeyValue( "maxspeed", 600 )
	ent:SetKeyValue( "ballradius", 12 )
	ent:SetKeyValue( "ballcount", 0 )
	ent:SetKeyValue( "maxballbounces", 2 )
	--ent:SetKeyValue( "launchconenoise", 0 )
	ent:SetPos(self:GetPos() + self:GetForward() * 2)
	ent:SetAngles(self:GetAngles())
	ent:Spawn()
	ent:Activate()
	ent:Fire("LaunchBall")
	ent:Fire("kill","",0)
end
