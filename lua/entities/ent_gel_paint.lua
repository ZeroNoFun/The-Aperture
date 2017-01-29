AddCSLuaFile( )

ENT.Type 			= "anim"
ENT.Base 			= "base_entity"

local GASL_PaintRadius = 47

function ENT:Initialize()

	if ( SERVER ) then

		self:SetModel( "models/hunter/plates/plate1x1.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		self:GetPhysicsObject():EnableCollisions( false )
		self:DrawShadow( false )

		self.GASL_Type = 0
		self.GASL_Level = 0
	end

	if ( CLIENT ) then
	
		self.GASL_Link = { left = NULL, right = NULL, forward = NULL, back = NULL }
		
		local left = self:CheckForGel( self:LocalToWorld( Vector( 0, -GASL_PaintRadius, 5 ) ), -self:GetUp() * 5 )
		local right = self:CheckForGel( self:LocalToWorld( Vector( 0, GASL_PaintRadius, 5 ) ), -self:GetUp() * 5 )
		local forward = self:CheckForGel( self:LocalToWorld( Vector( -GASL_PaintRadius, 0, 5 ) ), -self:GetUp() * 5 )
		local back = self:CheckForGel( self:LocalToWorld( Vector( GASL_PaintRadius, 0, 5 ) ), -self:GetUp() * 5 )
		
		if ( left ) then
			self.GASL_Link.left = left.Entity
			if ( left.Entity:IsValid() ) then left.Entity.GASL_Link.right = self end
		end

		if ( right ) then
			self.GASL_Link.right = right.Entity
			if ( right.Entity:IsValid() ) then right.Entity.GASL_Link.left = self end
		end

		if ( forward ) then
			self.GASL_Link.forward = forward.Entity
			if ( forward.Entity:IsValid() ) then forward.Entity.GASL_Link.back = self end
		end

		if ( back ) then
			self.GASL_Link.back = back.Entity
			if ( back.Entity:IsValid() ) then back.Entity.GASL_Link.forward = self end
		end
		
	end
	
end

function ENT:CheckForGel( startpos, dir )
	

	local trace = util.TraceLine( {
		start = startpos,
		endpos = startpos + dir,
		ignoreworld = true,
		filter = function( ent ) if ( ent:GetClass() == "ent_gel_paint" ) then return true end end
	} )
	
	return trace
	
end

function ENT:Draw()
	
	local left = false
	local right = false
	local forward = false
	local back = false

	if ( self.GASL_Link.left:IsValid() ) then left = true end
	if ( self.GASL_Link.right:IsValid() ) then right = true end
	if ( self.GASL_Link.forward:IsValid() ) then forward = true end
	if ( self.GASL_Link.back:IsValid() ) then back = true end
	
	local material = "paint/bridge_paint_single"
	local angle = 0
	
	if ( left ) then material = "paint/bridge_paint_end_left" angle = 90 end
	if ( right ) then material = "paint/bridge_paint_end_left" angle = -90 end
	if ( forward ) then material = "paint/bridge_paint_end_left" angle = 0 end
	if ( back ) then material = "paint/bridge_paint_end_left" angle = 180 end

	if ( forward && left ) then material = "paint/bridge_paint_corner" angle = 90 end
	if ( back && right ) then material = "paint/bridge_paint_corner" angle = -90 end
	if ( left && back ) then material = "paint/bridge_paint_corner" angle = 180 end
	if ( right && forward ) then material = "paint/bridge_paint_corner" angle = 0 end
	
	if ( left && right ) then material = "paint/bridge_paint_tile" angle = 90 end
	if ( forward && back ) then material = "paint/bridge_paint_tile" angle = 0 end
	
	if ( forward && back && left ) then material = "paint/bridge_paint_side" angle = 180 end
	if ( forward && back && right ) then material = "paint/bridge_paint_side" angle = 0 end
	if ( left && right && forward ) then material = "paint/bridge_paint_side" angle = 90 end
	if ( left && right && back ) then material = "paint/bridge_paint_side" angle = -90 end

	if ( left && right && forward && back ) then material = "paint/bridge_paint_fill" angle = 0 end
	//print( left, right, forward, back, angle )

	render.SetMaterial( Material( material ) )
	render.DrawQuadEasy( self:GetPos(), self:GetUp(), 47, 47, Color( 255, 255, 255 ), angle )
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
