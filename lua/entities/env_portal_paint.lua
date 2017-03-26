AddCSLuaFile( )

ENT.Type 			= "anim"

function ENT:SetupDataTables()

	self:NetworkVar( "Int", 0, "GelType" )
	self:NetworkVar( "Bool", 1, "PLeft" )
	self:NetworkVar( "Bool", 2, "PRight" )
	self:NetworkVar( "Bool", 3, "PForward" )
	self:NetworkVar( "Bool", 4, "PBack" )
	self:NetworkVar( "Int", 5, "MatType" )

end

if ( SERVER ) then
	function ENT:CheckSides( dir )

		// Checking for wall if it exist return true 
		local PosDir = self:LocalToWorld( dir * ( APERTURESCIENCE.GEL_BOX_SIZE / 1.75 ) + Vector( 0, 0, 2 ) )
		local TraceHitSide = util.TraceLine( {
			start = self:GetPos() + self:GetUp() * 2,
			endpos = PosDir,
			ignoreworld = false,
			filter = function( ent ) if ( ent:GetClass() == "env_portal_wall" ) then return true end end
		} )
		if ( TraceHitSide.Hit ) then return true end

		// checking for floor if it exist return false
		// if it's not founding a conner
		local TraceHitFloor = util.TraceLine( {
			start = PosDir,
			endpos = PosDir - self:GetUp() * 3,
			ignoreworld = false,
			filter = function( ent ) if ( ent:GetClass() == "env_portal_wall" ) then return true end end
		} )
		if ( TraceHitFloor.Hit ) then return false end
		
		local Trace = util.TraceLine( {
			start = PosDir - self:GetUp() * 3,
			endpos = PosDir - self:GetUp() * 3 -( PosDir - self:GetPos() ),
			ignoreworld = false,
			filter = function( ent ) if ( ent:GetClass() == "env_portal_wall" ) then return true end end
		} )
		if ( Trace.Fraction < 0.0001 || !Trace.Hit ) then return false end
		
		return true
	end
end

if ( CLIENT ) then
	function ENT:AddCut( dir )

		local PosDir = self:LocalToWorld( dir * APERTURESCIENCE.GEL_BOX_SIZE / 2 )
		local TraceHitFloor = util.TraceLine( {
			start = PosDir,
			endpos = PosDir - self:GetUp() * 2,
			ignoreworld = false,
			filter = function( ent ) if ( ent:GetClass() == "env_portal_wall" ) then return true end end
		} )
		if ( TraceHitFloor.Hit ) then return false end
		
		// checking for floor if it exist returning false
		// if it's not founding a conner and adding it to clip
		local Trace = util.TraceLine( {
			start = PosDir - self:GetUp() * 2,
			endpos = PosDir - self:GetUp() * 2 -( PosDir - self:GetPos() ),
			ignoreworld = false,
			filter = function( ent ) if ( ent:GetClass() == "env_portal_wall" ) then return true end end
		} )

		//local Trace = util.QuickTrace( PosDir - self:GetUp() * 2, -( PosDir - self:GetPos() ), ents.FindByClass( "env_portal_paint" ) )
		if ( Trace.Fraction < 0.0001 || !Trace.Hit ) then return false end
			local Normal = -Trace.HitNormal
			local HitPos = Trace.HitPos + ( PosDir - self:GetPos() ):GetNormalized()
			table.insert( self.ClipPoses, table.Count( self.ClipPoses ), { pos = Normal:Dot( HitPos ), normal = Normal } )
		
		return true
	end
end

function ENT:Initialize()
	if ( SERVER ) then
		self:SetModel( "models/gasl/paint.mdl" )
		self:PhysicsInit( SOLID_NONE )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		self:DrawShadow( false )
		self:SetCollisionGroup( COLLISION_GROUP_WORLD )
		self.GASL_Untouchable = true
		self:SetPersistent( true )
		
		self.GASL_Blocks = { 
			left = false, 
			right = false, 
			forward = false, 
			back = false 
		}
		
		if ( self:CheckSides( Vector( -1, 0, 0 ) ) ) then self.GASL_Blocks.forward = true self:SetPForward( true ) end
		if ( self:CheckSides( Vector( 1, 0, 0 ) ) ) then self.GASL_Blocks.back = true self:SetPBack( true ) end
		if ( self:CheckSides( Vector( 0, -1, 0 ) ) ) then self.GASL_Blocks.left = true self:SetPLeft( true ) end
		if ( self:CheckSides( Vector( 0, 1, 0 ) ) ) then self.GASL_Blocks.right = true self:SetPRight( true ) end
	end

	if ( CLIENT ) then
		self.GASL_Gel_Angles = self:GetAngles()
		self.GASL_Link = { 
			left = NULL, 
			right = NULL, 
			forward = NULL, 
			back = NULL 
		}
		self.ClipPoses = { }
		
		self:AddCut( Vector( -1, 0, 0 ) )
		self:AddCut( Vector( 1, 0, 0 ) )
		self:AddCut( Vector( 0, -1, 0 ) )
		self:AddCut( Vector( 0, 1, 0 ) )
	end

	self:UpdateGel()
end

function ENT:UpdateGel()

	if ( CLIENT ) then return end

	self.GASL_Link = { left = NULL, right = NULL, forward = NULL, back = NULL }
	
	local left = APERTURESCIENCE:CheckForGel( self:LocalToWorld( Vector( 0, -APERTURESCIENCE.GEL_BOX_SIZE, 5 ) ), -self:GetUp() * 10, true )
	local right = APERTURESCIENCE:CheckForGel( self:LocalToWorld( Vector( 0, APERTURESCIENCE.GEL_BOX_SIZE, 5 ) ), -self:GetUp() * 10, true )
	local forward = APERTURESCIENCE:CheckForGel( self:LocalToWorld( Vector( -APERTURESCIENCE.GEL_BOX_SIZE, 0, 5 ) ), -self:GetUp() * 10, true )
	local back = APERTURESCIENCE:CheckForGel( self:LocalToWorld( Vector( APERTURESCIENCE.GEL_BOX_SIZE, 0, 5 ) ), -self:GetUp() * 10, true )
	
	if ( IsValid( left ) && !self.GASL_Blocks.left ) then
		if ( self:GetGelType() != PORTAL_GEL_NONE ) then
			self.GASL_Link.left = left
			left.GASL_Link.right = self
			self:SetPLeft( true )
			left:SetPRight( true )
		else
			self:SetPLeft( false )
			left:SetPRight( false )
		end
	end

	if ( IsValid( right ) && !self.GASL_Blocks.right ) then
		if ( self:GetGelType() != PORTAL_GEL_NONE ) then
			self.GASL_Link.right = right
			right.GASL_Link.left = self
			self:SetPRight( true )
			right:SetPLeft( true )
		else
			self:SetPRight( false )
			right:SetPLeft( false )
		end
	end

	if ( IsValid( forward ) && !self.GASL_Blocks.forward ) then
		if ( self:GetGelType() != PORTAL_GEL_NONE ) then
			self.GASL_Link.forward = forward
			forward.GASL_Link.back = self
			self:SetPForward( true )
			forward:SetPBack( true )
		else
			self:SetPForward( false )
			forward:SetPBack( false )
		end
	end

	if ( IsValid( back ) && !self.GASL_Blocks.back ) then
		if ( self:GetGelType() != PORTAL_GEL_NONE ) then
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

function ENT:Draw()
	
	local left = self:GetPLeft()
	local right = self:GetPRight()
	local forward = self:GetPForward()
	local back = self:GetPBack()
	
	local material = "paint/paint_single"
	local angle = 0

	if ( left && right && forward && back ) then material = "paint/paint_fill" angle = 0
	
	elseif ( forward && back && left ) then material = "paint/paint_side" angle = 90
	elseif ( forward && back && right ) then material = "paint/paint_side" angle = -90
	elseif ( left && right && forward ) then material = "paint/paint_side" angle = 0
	elseif ( left && right && back ) then material = "paint/paint_side" angle = 180

	elseif ( left && right ) then material = "paint/paint_tile" angle = 0
	elseif ( forward && back ) then material = "paint/paint_tile" angle = 90

	elseif ( forward && left ) then material = "paint/paint_corner" angle = 0
	elseif ( back && right ) then material = "paint/paint_corner" angle = 180
	elseif ( left && back ) then material = "paint/paint_corner" angle = 90
	elseif ( right && forward ) then material = "paint/paint_corner" angle = -90

	elseif ( left ) then material = "paint/paint_end" angle = 0
	elseif ( right ) then material = "paint/paint_end" angle = 180
	elseif ( forward ) then material = "paint/paint_end" angle = -90
	elseif ( back ) then material = "paint/paint_end" angle = 90 end
	
	local color = APERTURESCIENCE:GetColorByGelType( self:GetGelType() )
	self:SetSubMaterial( 0, material, true )
	
	//render.SetLightmapTexture( Material( material ):GetTexture( "$basetexture" ) ) 
	self:SetAngles( self.GASL_Gel_Angles )
	self:SetAngles( self:LocalToWorldAngles( Angle( 0, angle - 90, 0 ) ) )
	
	local oldEC = render.EnableClipping( true )
	for k, v in pairs( self.ClipPoses ) do render.PushCustomClipPlane( v.normal, v.pos ) end
	self:DrawModel()
	for i = 0, table.Count( self.ClipPoses ) do render.PopCustomClipPlane() end
	render.EnableClipping( oldEC )
	
end

function ENT:Think()

end

if ( CLIENT ) then

	function ENT:OnRemove()
	
		self:UpdateGel( )
	
	end
end
