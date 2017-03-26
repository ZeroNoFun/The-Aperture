AddCSLuaFile( )

ENT.Type 			= "anim"

function ENT:Initialize()
	if ( SERVER ) then
		self:SetModel( "models/gasl/panel.mdl" )
		self:PhysicsInitBox( -Vector( 1, 1, 1 ) * APERTURESCIENCE.GRID_SIZE, Vector( 1, 1, 1 ) * APERTURESCIENCE.GRID_SIZE )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		self:DrawShadow( false )
		self:GetPhysicsObject():EnableMotion( false )
		//self:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE_DEBRIS )
	end
end

function ENT:Draw()
	self:DrawModel()	
end

function ENT:Think()

end