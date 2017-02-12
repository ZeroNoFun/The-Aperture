AddCSLuaFile( )
DEFINE_BASECLASS( "gasl_base_ent" )

ENT.PrintName		= "Radio"
ENT.Category		= "Aperture Science"
ENT.Editable		= true
ENT.Spawnable		= true
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !trace.Hit ) then return end
	
	local ent = ents.Create( ClassName )
	ent:SetPos( trace.HitPos + trace.HitNormal * 10 )
	ent:SetAngles( trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
	ent:Spawn()
	ent:Activate()
	ent.Owner = ply
	
	return ent

end

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Enable" )

end

if ( CLIENT ) then

	function ENT:Initialize() 
	
		self.BaseClass.Initialize( self )
		
	end

	function ENT:Think() 
		
	end

end

function ENT:Draw()

	self:DrawModel()
	
end

function ENT:Initialize()

	self.BaseClass.Initialize( self )
	
	if ( CLIENT ) then return end
	
	self:SetModel( "models/props/radio_reference.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:GetPhysicsObject():Wake()
	self.GASL_Radio_Counter = 0
	
	return true
	
end

-- no more client side
if ( CLIENT ) then return end

function ENT:Use( activator, caller, usetype, val )

	if ( IsValid( caller ) && caller:IsPlayer() ) then
	
		if ( timer.Exists( "GASL_Radio_Block"..self:EntIndex() ) ) then return end
		timer.Create( "GASL_Radio_Block"..self:EntIndex(), 1, 1, function() end )
		
		self:SetEnable( !self:GetEnable() )
		
		if ( self:GetEnable() ) then
		
			if ( math.random( 1, 20 - self.GASL_Radio_Counter ) == 1 ) then
				self:EmitSound( "GASL.RadioStrangeNoice" )
				self.GASL_Radio_Counter = 0
				APERTURESCIENCE:GiveAchievement( self.Owner, 5 )
			else
				self:EmitSound( "GASL.RadioLoop" )
			end
			
			self.GASL_Radio_Counter = self.GASL_Radio_Counter + 1
		else
			self:StopSound( "GASL.RadioLoop" )
			self:StopSound( "GASL.RadioStrangeNoice" )
		end

	end
	
end

function ENT:Setup()

	if ( !WireAddon ) then return end
	Wire_TriggerOutput( self, "Activated", 0 )
	
end

function ENT:Think()
	
	self:NextThink( CurTime() + 0.1 )
	
	self.BaseClass.Think( self )

	return true
	
end

function ENT:OnRemove()

	timer.Remove( "GASL_Radio_Block"..self:EntIndex() )
	self:StopSound( "GASL.RadioLoop" )
	self:StopSound( "GASL.RadioStrangeNoice" )
	
end
