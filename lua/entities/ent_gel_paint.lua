AddCSLuaFile( )

ENT.Type 			= "anim"
ENT.Base 			= "base_entity"

function ENT:Initialize()

	if ( SERVER ) then

		self:SetModel( "models/hunter/plates/plate1x1.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		self:GetPhysicsObject():EnableCollisions( false )
		self.GASL_Type = 0
		self.GASL_Level = 0
		
	end

	if ( CLIENT ) then
		
		self.asd_setMaterial = Material( "paint/bridge_paint_end_left" )
		self.asd_angle = 0
	end
	
end

function ENT:Draw()

	render.SetMaterial( self.asd_setMaterial )
	render.DrawQuadEasy( self:LocalToWorld( Vector( 0, 0, 5 ) ), self:GetUp(), 47, 47, Color( 255, 255, 255 ), self.asd_angle )

end

function ENT:Think()

	self:NextThink( CurTime() + 1 )

	if ( SERVER ) then
	
	end 

	if ( CLIENT ) then
		
	end 
	
	return true
	
end

if ( SERVER ) then

	function ENT:OnRemove()
	
	
	
	end
end
