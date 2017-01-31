AddCSLuaFile( )

ENT.Base 			= "base_entity"

ENT.Editable		= true
ENT.PrintName		= "Frankenturret"
ENT.Category		= "Aperture Science"
ENT.Spawnable 		= true
ENT.AdminSpawnable 	= false
ENT.AutomaticFrameAdvance = true

function ENT:Initialize()

	if ( SERVER ) then
		
		self:SetModel( "models/npcs/monsters/monster_a.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		
	end

	if ( CLIENT ) then
	
	end
	
end

function ENT:Draw()

	self:DrawModel()
	
end

function ENT:Think()

	self:NextThink( CurTime() + 0.1 )

	if ( SERVER ) then
	
		if ( !timer.Exists( "GASL_Monsterbox_straight"..self:EntIndex() ) ) then 
			timer.Create( "GASL_Monsterbox_straight"..self:EntIndex(), APERTURESCIENCE:PlaySequence( self, "straight0"..math.random( 1, 3 ), 1.0 ), 1, function() end )
			self:GetPhysicsObject():SetVelocity( self:GetForward() * 200 + Vector( 0, 0, 100 ) )
		end
		
	end

	if ( CLIENT ) then
		
	end

	return true
	
end