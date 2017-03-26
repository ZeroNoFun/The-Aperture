AddCSLuaFile( )

ENT.Base = "gasl_fizzler_base"
ENT.AutomaticFrameAdvance = true

function ENT:Draw()

	self:DrawModel()
	
	if ( !self:GetEnable() ) then return end

	self:DrawFizzler( Material( "effects/fizzler" ), false )
	
	local secondField = self:GetNWEntity( "GASL_ConnectedField" )
	if ( !IsValid( secondField ) ) then return end

	--aproach object field effect
	local Height = 120
	
	local closesEntities = { }
	local tracer = util.TraceHull( {
		start = self:LocalToWorld( Vector() ),
		endpos = secondField:LocalToWorld( Vector() ),
		filter = function( ent ) 
			if ( !APERTURESCIENCE:GASLStuff( ent ) && ent != self && ent != secondField && !ent:IsPlayer() && !ent:IsNPC() ) then
				table.insert( closesEntities, table.Count( closesEntities ) + 1, ent )
			end

			return false
		end,
		ignoreworld = true,
		mins = -Vector( 1, 1, 1 ) * Height,
		maxs = Vector( 1, 1, 1 ) * Height,
		mask = MASK_SHOT_HULL
	} )
	
	local ClipNormalUp = self:LocalToWorld( Vector( 0, 0, -1 ) ) - self:GetPos()
	local ClipPosUp = ClipNormalUp:Dot( self:LocalToWorld( Vector( 0, 0, Height / 2 ) ) )

	local ClipNormalDown = self:LocalToWorld( Vector( 0, 0, 1 ) ) - self:GetPos()
	local ClipPosDown = ClipNormalDown:Dot( self:LocalToWorld( Vector( 0, 0, -Height / 2 ) ) )
	
	//print( ClipNormalUp, "_", ClipNormalDown, "|", ClipPosDown, "_", ClipPosUp )
	render.SetMaterial( Material( "effects/fizzler_approach" ) )
	
	local oldEC = render.EnableClipping( true )
	render.PushCustomClipPlane( ClipNormalUp, ClipPosUp )
	render.PushCustomClipPlane( ClipNormalDown, ClipPosDown )
	
	for _, ent in pairs( closesEntities ) do
		local localEntPos = self:WorldToLocal( ent:GetPos() )
		local distToField = math.abs( localEntPos.x )
		localEntPos = Vector( 0, localEntPos.y, localEntPos.z )
		
		//if ( localEntPos.y < 0 ) then return end
		
		local rad = math.min( Height, ent:GetModelRadius() * 3 )
		local p1 = self:LocalToWorld( localEntPos + Vector( 0, -1, -1 ) * rad )
		local p2 = self:LocalToWorld( localEntPos + Vector( 0, 1, -1 ) * rad )
		local p3 = self:LocalToWorld( localEntPos + Vector( 0, 1, 1 ) * rad )
		local p4 = self:LocalToWorld( localEntPos + Vector( 0, -1, 1 ) * rad )
		
		local alpha = math.max( 0, math.min( 1, ( 50 + 50 - distToField ) / 50 ) ) * 255
		render.DrawQuad( p1, p2, p3, p4, Color( 255, 255, 255, alpha ) )
	end

	render.PopCustomClipPlane()
	render.PopCustomClipPlane()
	render.EnableClipping( oldEC )

end

if ( CLIENT ) then

	function ENT:Think()
	
		self.BaseClass.Think( self )
		
	end
	
	function ENT:Initialize()

		self.BaseClass.Initialize( self )
		//self.BaseClass.BaseClass.Initialize( self )
		
	end

	return
end

function ENT:Initialize()

	self.BaseClass.Initialize( self )
	self.BaseClass.BaseClass.Initialize( self )
	
	self:AddInput( "Enable", function( value ) self:ToggleEnable( value ) end )
	
end

function ENT:HandleEntityInField( ent )
	if ( ent:IsPlayer() ) then
		local weapon = ent:GetActiveWeapon( )

		if ( IsValid( weapon ) && weapon:GetClass() == "weapon_portalgun" ) then
			weapon:CleanPortals()
			weapon:IdleStuff()
		end
	elseif ( ent:GetClass() == "projectile_portal_ball" || ent:GetClass() == "prop_portal" ) then ent:Remove()
	elseif ( ent:GetPhysicsObject():IsValid() ) then APERTURESCIENCE:DissolveEnt( ent ) end
end

-- no more client size
if ( CLIENT ) then return end

function ENT:Think()
	self.BaseClass.Think( self )
	
	//if ( ent:GetClass() == "projectile_portal_ball" ) then return true end
	
	return true
end
