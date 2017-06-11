AddCSLuaFile( )
DEFINE_BASECLASS( "gasl_base_ent" )

ENT.PrintName		= "Ball catcher"
ENT.Category		= "Aperture Science"
ENT.Editable		= true
ENT.Spawnable		= true
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SpawnFunction( ply, trace, ClassName )
	if ( !trace.Hit ) then return end
	local ent = ents.Create( ClassName )
	ent:SetPos(trace.HitPos + trace.HitNormal)
	ent:Spawn()
	ent:SetAngles(trace.HitNormal:Angle())
	ent:GetPhysicsObject():Sleep()
	ent:GetPhysicsObject():EnableMotion(false)
	ent:Activate()
	ent.Owner = ply
	return ent
end

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Active")
end


function ENT:Draw()
	self:DrawModel()
end

function ENT:Initialize()
	self.BaseClass.Initialize( self )
	if CLIENT then return end
	self:SetUseType(3)	-- SIMPLE_USE Defined at garry's mod lua wiki
	self:SetModel( "models/props/combine_ball_catcher.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetActive(false)
	--Wire
	self:AddOutput( "Activated", false )
	if ( !WireAddon ) then return end
	self.Outputs = WireLib.CreateSpecialOutputs( self, { "Activated" }, { "NORMAL" } )
	return true
end

function ENT:Setup()
	if ( !WireAddon ) then return end
	Wire_TriggerOutput( self, "Activated", 0 )
end

function ENT:Think()
	if not IsValid(self) then return end
	self:NextThink(CurTime() + 0.1)
	self.BaseClass.Think(self)
	local combine_ball = self:CheckForBall()
	if self:GetActive() == false and IsValid(combine_ball) then
		self:ConsumeBall(combine_ball)
	end
	if self:GetActive() then
		--self:UpdateOutput( "Activated", true )
		if (WireAddon) then Wire_TriggerOutput( self, "Activated", 1 ) end
	else
		--self:UpdateOutput( "Activated", false )
		if (WireAddon) then Wire_TriggerOutput( self, "Activated", 0 ) end
	end
	return true
end

function ENT:ConsumeBall(combine_ball)
	combine_ball:Remove()
	self:SetActive(true)
	APERTURESCIENCE:PlaySequence(self, "close", 1.0)
end

function ENT:CheckForBall()
	local mins = Vector(-30,-30,-30)
	local maxs = Vector(30,30,30)
	local length = 30
	local trace = util.TraceHull( { 
		start = self:GetPos() + self:GetForward() * 30,
		endpos = self:GetPos() + self:GetForward() * length,
		mins = mins,
		maxs = maxs,
		filter = self
		})
	if IsValid(trace.Entity) and trace.Entity:GetClass() == "prop_combine_ball" then
		return trace.Entity
	else
		return null
	end
end