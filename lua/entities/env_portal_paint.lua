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

		self:SetModel( "models/portal_paint/portal_paint.mdl" )
		self:PhysicsInit( SOLID_NONE )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_BBOX )
		self:DrawShadow( false )
		self:SetCollisionGroup( COLLISION_GROUP_WORLD )
		self.GASL_Untouchable = true
		self:SetPersistent( true )
	end

	if ( CLIENT ) then

		self.GASL_Link = { left = NULL, right = NULL, forward = NULL, back = NULL }
		
	end

	self.GASL_Gel_Angles = self:GetAngles()
	self:UpdateGel()
	
end

function ENT:UpdateGel()

	if ( CLIENT ) then return end

	self.GASL_Link = { left = NULL, right = NULL, forward = NULL, back = NULL }
	
	local left = APERTURESCIENCE:CheckForGel( self:LocalToWorld( Vector( 0, -APERTURESCIENCE.GEL_BOX_SIZE, 5 ) ), -self:GetUp() * 10, true )
	local right = APERTURESCIENCE:CheckForGel( self:LocalToWorld( Vector( 0, APERTURESCIENCE.GEL_BOX_SIZE, 5 ) ), -self:GetUp() * 10, true )
	local forward = APERTURESCIENCE:CheckForGel( self:LocalToWorld( Vector( -APERTURESCIENCE.GEL_BOX_SIZE, 0, 5 ) ), -self:GetUp() * 10, true )
	local back = APERTURESCIENCE:CheckForGel( self:LocalToWorld( Vector( APERTURESCIENCE.GEL_BOX_SIZE, 0, 5 ) ), -self:GetUp() * 10, true )
	
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
	
	self:SetColor( APERTURESCIENCE:GetColorByGelType( self:GetGelType() ) )
	
end

function ENT:DrawTranslucent()

	local left = self:GetPLeft()
	local right = self:GetPRight()
	local forward = self:GetPForward()
	local back = self:GetPBack()
	
	local material = "paint/paint_single"
	local angle = 0
	
	if ( left ) then material = "paint/paint_end" angle = 0 end
	if ( right ) then material = "paint/paint_end" angle = 180 end
	if ( forward ) then material = "paint/paint_end" angle = -90 end
	if ( back ) then material = "paint/paint_end" angle = 90 end

	if ( forward && left ) then material = "paint/paint_corner" angle = 0 end
	if ( back && right ) then material = "paint/paint_corner" angle = 180 end
	if ( left && back ) then material = "paint/paint_corner" angle = 90 end
	if ( right && forward ) then material = "paint/paint_corner" angle = -90 end
	
	if ( left && right ) then material = "paint/paint_tile" angle = 0 end
	if ( forward && back ) then material = "paint/paint_tile" angle = 90 end
	
	if ( forward && back && left ) then material = "paint/paint_side" angle = 90 end
	if ( forward && back && right ) then material = "paint/paint_side" angle = -90 end
	if ( left && right && forward ) then material = "paint/paint_side" angle = 0 end
	if ( left && right && back ) then material = "paint/paint_side" angle = 180 end

	if ( left && right && forward && back ) then material = "paint/paint_fill" angle = 0 end

	local color = APERTURESCIENCE:GetColorByGelType( self:GetGelType() )
	
	self:SetSubMaterial( 0, material )
	self:SetAngles( self.GASL_Gel_Angles )
	self:SetAngles( self:LocalToWorldAngles( Angle( 0, angle + 180, 0 ) ) )
	
	self:DrawModel()
	
end

function ENT:Think()

	return
	
end

if ( CLIENT ) then

	function ENT:OnRemove()
	
		self:UpdateGel( )
	
	end
end
