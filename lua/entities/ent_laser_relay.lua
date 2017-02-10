AddCSLuaFile( )

ENT.Base 			= "gasl_base_ent"

ENT.PrintName 		= "Laser Relay"
ENT.Category 		= "Aperture Science"
ENT.Spawnable 		= true
ENT.Editable		= true
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !trace.Hit ) then return end
	
	local ent = ents.Create( ClassName )
	ent:SetPos( trace.HitPos )
	ent:SetModel( "models/props/laser_receptacle.mdl" )
	ent:SetAngles( trace.HitNormal:Angle() )
	ent:Spawn()

	return ent

end

function ENT:SetupDataTables()
	
	self:NetworkVar( "Bool", 0, "EnableUpdate" )
	
end

if ( CLIENT ) then

	function ENT:Initialize()
		
		self.BaseClass.Initialize( self )

	end
	
	function ENT:Think()
		
		self:NextThink( CurTime() )
		return true
		
	end
	
end

function ENT:Draw()

	self:DrawModel()
	
	if ( self:GetEnableUpdate() ) then
	
		local radius = 64
		radius = radius * math.Rand( 0.9, 1.1 )
		render.SetMaterial( Material( "particle/laser_beam_glow" ) )
		render.DrawSprite( self:LocalToWorld( Vector( 0, 0, 20 ) ), radius, radius, Color( 255, 255, 255 ) )
	
	end
	
end

-- no more client side
if ( CLIENT ) then return end

function ENT:Initialize()

	self.BaseClass.Initialize( self )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:GetPhysicsObject():EnableMotion( false )
	
	self.GASL_Actiaved = false
	self.GASL_LastHittedByLaser = 0

	self:AddOutput( "Actiaved", false )

	if ( !WireAddon ) then return end
	self.Outputs = WireLib.CreateSpecialOutputs( self, { "Enabled" }, { "NORMAL" } )

end

function ENT:Think()

	self:NextThink( CurTime() )
	
	if ( CurTime() < self.GASL_LastHittedByLaser + 0.2 ) then
	
		if ( !self:GetEnableUpdate() ) then
			self:SetEnableUpdate( true )
			self:SetSkin( 1 )
			self:EmitSound( "GASL.LaserCatcherOn" )
			self:EmitSound( "GASL.LaserCatcherLoop" )
			APERTURESCIENCE:PlaySequence( self, "spin", 1.0 )
			
			self:UpdateOutput( "Actiaved", true )
			
			Wire_TriggerOutput( self, "Enabled", 1 )
		end
		
	elseif ( self:GetEnableUpdate() ) then
		self:SetEnableUpdate( false )
		self:SetSkin( 0 )
		self:EmitSound( "GASL.LaserCatcherOff" )
		self:StopSound( "GASL.LaserCatcherLoop" )
		APERTURESCIENCE:PlaySequence( self, "idle", 1.0 )
		
		self:UpdateOutput( "Actiaved", false )
		
		Wire_TriggerOutput( self, "Enabled", 0 )
	end

	return true
	
end

function ENT:Setup()

	Wire_TriggerOutput( self, "Enabled", 0 )
	
end

numpad.Register( "aperture_science_laser_emitter_enable", function( pl, ent, keydown, idx )

	if ( !IsValid( ent ) ) then return false end

	if ( keydown ) then ent:ToggleEnable( true ) end
	return true

end )

numpad.Register( "aperture_science_laser_emitter_disable", function( pl, ent, keydown )

	if ( !IsValid( ent ) ) then return false end

	if ( keydown ) then ent:ToggleEnable( false ) end
	return true

end )

function ENT:OnRemove()

	self:StopSound( "GASL.LaserCatcherLoop" )
	
end
