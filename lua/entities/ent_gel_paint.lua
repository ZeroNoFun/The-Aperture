AddCSLuaFile( )

ENT.Type 			= "anim"
ENT.Base 			= "base_entity"

function ENT:SetupDataTables()

	self:NetworkVar( "Int", 0, "GelType" )
	self:NetworkVar( "Bool", 1, "PLeft" )
	self:NetworkVar( "Bool", 2, "PRight" )
	self:NetworkVar( "Bool", 3, "PForward" )
	self:NetworkVar( "Bool", 4, "PBack" )
	
end

function ENT:Initialize()

	if ( SERVER ) then

		self:SetModel( "models/hunter/plates/plate1x1.mdl" )
		self:PhysicsInit( SOLID_NONE )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_BSP )
		self:DrawShadow( false )
		self:SetCollisionGroup( COLLISION_GROUP_WORLD )
		self.GASL_Untouchable = true
		self:SetPersistent( true )
	end

	if ( CLIENT ) then

		self.GASL_Link = { left = NULL, right = NULL, forward = NULL, back = NULL }
		
	end

	self:SetSubMaterial( 0, "models/debug/debugwhite" )

end

function ENT:UpdateGel()

	if ( SERVER ) then

		self.GASL_Link = { left = NULL, right = NULL, forward = NULL, back = NULL }
		
		local left = APERTURESCIENCE:CheckForGel( self:LocalToWorld( Vector( 0, -APERTURESCIENCE.GEL_BOX_SIZE, 5 ) ), -self:GetUp() * 10 ).Entity
		local right = APERTURESCIENCE:CheckForGel( self:LocalToWorld( Vector( 0, APERTURESCIENCE.GEL_BOX_SIZE, 5 ) ), -self:GetUp() * 10 ).Entity
		local forward = APERTURESCIENCE:CheckForGel( self:LocalToWorld( Vector( -APERTURESCIENCE.GEL_BOX_SIZE, 0, 5 ) ), -self:GetUp() * 10 ).Entity
		local back = APERTURESCIENCE:CheckForGel( self:LocalToWorld( Vector( APERTURESCIENCE.GEL_BOX_SIZE, 0, 5 ) ), -self:GetUp() * 10 ).Entity
		
		if ( left:IsValid() ) then
		
			if ( self:GetGelType() == left:GetGelType() ) then
				self.GASL_Link.left = left
				left.GASL_Link.right = self
				self:SetPLeft( true )
				left:SetPRight( true )
			else
				self:SetPLeft( false )
				left:SetPRight( false )
			end
			
		end

		if ( right:IsValid() ) then

			if ( self:GetGelType() == right:GetGelType() ) then
				self.GASL_Link.right = right
				right.GASL_Link.left = self
				self:SetPRight( true )
				right:SetPLeft( true )
			else
				self:SetPRight( false )
				right:SetPLeft( false )
			end
			
		end

		if ( forward:IsValid() ) then
		
			if ( self:GetGelType() == forward:GetGelType() ) then
				self.GASL_Link.forward = forward
				forward.GASL_Link.back = self
				self:SetPForward( true )
				forward:SetPBack( true )
			else
				self:SetPForward( false )
				forward:SetPBack( false )
			end
			
		end

		if ( back:IsValid() ) then

			if ( self:GetGelType() == back:GetGelType() ) then
				self.GASL_Link.back = back
				back.GASL_Link.forward = self
				self:SetPBack( true )
				back:SetPForward( true )
			else
				self:SetPBack( false )
				back:SetPForward( false )
			end

		end
		
	end
	
	self:SetColor( APERTURESCIENCE:GetColorByGelType( self:GetGelType() ) )
		
end

function ENT:Draw()

	if ( APERTURESCIENCE.GEL_QUALITY == 0 ) then
		
		self:DrawModel()
		
	end
	
	if ( APERTURESCIENCE.GEL_QUALITY == 1 ) then
		
		local left = false
		local right = false
		local forward = false
		local back = false

		if ( self:GetPLeft() ) then left = true end
		if ( self:GetPRight() ) then right = true end
		if ( self:GetPForward() ) then forward = true end
		if ( self:GetPBack() ) then back = true end
		
		local material = "paint/paint_single"
		local angle = 0
		
		if ( left ) then material = "paint/paint_end" angle = 90 end
		if ( right ) then material = "paint/paint_end" angle = -90 end
		if ( forward ) then material = "paint/paint_end" angle = 0 end
		if ( back ) then material = "paint/paint_end" angle = 180 end

		if ( forward && left ) then material = "paint/paint_corner" angle = 90 end
		if ( back && right ) then material = "paint/paint_corner" angle = -90 end
		if ( left && back ) then material = "paint/paint_corner" angle = 180 end
		if ( right && forward ) then material = "paint/paint_corner" angle = 0 end
		
		if ( left && right ) then material = "paint/paint_tile" angle = 90 end
		if ( forward && back ) then material = "paint/paint_tile" angle = 0 end
		
		if ( forward && back && left ) then material = "paint/paint_side" angle = 180 end
		if ( forward && back && right ) then material = "paint/paint_side" angle = 0 end
		if ( left && right && forward ) then material = "paint/paint_side" angle = 90 end
		if ( left && right && back ) then material = "paint/paint_side" angle = -90 end

		if ( left && right && forward && back ) then material = "paint/paint_fill" angle = 0 end

		local color = APERTURESCIENCE:GetColorByGelType( self:GetGelType() )
		
		render.SetMaterial( Material( material ) )
		render.DrawQuadEasy( self:GetPos(), self:GetUp(), APERTURESCIENCE.GEL_BOX_SIZE + 1, APERTURESCIENCE.GEL_BOX_SIZE + 1, color, angle )
		
	end
	
end

if ( CLIENT ) then

	function ENT:OnRemove()
	
		self:UpdateGel( )
	
	end
end
