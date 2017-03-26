
// ================================ PAINT STUFF ============================

APERTURESCIENCE.GEL_QUALITY		= 1

PORTAL_GEL_NONE 		= 0
PORTAL_GEL_BOUNCE 		= 1
PORTAL_GEL_SPEED 		= 2
PORTAL_GEL_PORTAL 		= 3
PORTAL_GEL_WATER 		= 4
PORTAL_GEL_STICKY 		= 5
PORTAL_GEL_REFLECTION 	= 6

PORTAL_GEL_COUNT		= 6

APERTURESCIENCE.GEL_BOX_SIZE 			= 64
APERTURESCIENCE.GEL_MAXSIZE 			= 150
APERTURESCIENCE.GEL_MINSIZE 			= 40
APERTURESCIENCE.GEL_MAX_LAUNCH_SPEED 	= 1000

APERTURESCIENCE.GEL_BOUNCE_COLOR 		= Color( 50, 125, 255 )
APERTURESCIENCE.GEL_SPEED_COLOR 		= Color( 255, 100, 0 )
APERTURESCIENCE.GEL_PORTAL_COLOR 		= Color( 150, 150, 150 )
APERTURESCIENCE.GEL_WATER_COLOR 		= Color( 200, 230, 255 )
APERTURESCIENCE.GEL_STICKY_COLOR 		= Color( 125, 25, 220 )
APERTURESCIENCE.GEL_REFLECTION_COLOR 	= Color( 255, 255, 255 )

APERTURESCIENCE.GELLED_ENTITIES 	= { }
APERTURESCIENCE.CONNECTED_PAINTS 	= { }

function APERTURESCIENCE:GetColorByGelType( paintType )

	local color = Color( 0, 0, 0 )
	if ( paintType == PORTAL_GEL_BOUNCE ) then color = APERTURESCIENCE.GEL_BOUNCE_COLOR end
	if ( paintType == PORTAL_GEL_SPEED ) then color = APERTURESCIENCE.GEL_SPEED_COLOR end
	if ( paintType == PORTAL_GEL_PORTAL ) then color = APERTURESCIENCE.GEL_PORTAL_COLOR end
	if ( paintType == PORTAL_GEL_WATER ) then color = APERTURESCIENCE.GEL_WATER_COLOR end
	if ( paintType == PORTAL_GEL_STICKY ) then color = APERTURESCIENCE.GEL_STICKY_COLOR end
	if ( paintType == PORTAL_GEL_REFLECTION ) then color = APERTURESCIENCE.GEL_REFLECTION_COLOR end

	return color
	
end

function APERTURESCIENCE:PaintTypeToName( index )
	
	local indexToName = {
		[PORTAL_GEL_BOUNCE] = "Repulsion"
		, [PORTAL_GEL_SPEED] = "Propulsion"
		, [PORTAL_GEL_PORTAL] = "Conversion"
		, [PORTAL_GEL_WATER] = "Cleansing"
		, [PORTAL_GEL_STICKY] = "Adhesion"
		, [PORTAL_GEL_REFLECTION] = "Reflection"
	}
	
	return indexToName[ index ]
	
end

if ( CLIENT ) then

	// STICKY gel camera orientation
	hook.Add( "Think", "GASL_CamOrient", function()
	
		local eyeAngles = LocalPlayer():EyeAngles()
		local newEyeAngle = Angle()
		local orientation = LocalPlayer():GetNWVector( "GASL:Orientation" )

		if ( !LocalPlayer():GetNWAngle( "GASL:OrientationAng" ) ) then LocalPlayer():SetNWAngle( "GASL:OrientationAng", eyeAngles ) end
		if ( !LocalPlayer():GetNWAngle( "GASL:PlayerAng" ) ) then LocalPlayer():SetNWAngle( "GASL:PlayerAng", eyeAngles ) end
		if ( !LocalPlayer():GetNWAngle( "GASL:PlayerEyeAngle" ) ) then LocalPlayer():SetNWAngle( "GASL:PlayerEyeAngle", eyeAngles ) end
		local playerEyeAngle = LocalPlayer():GetNWAngle( "GASL:PlayerEyeAngle" )

		if ( orientation == Vector( 0, 0, 1 ) ) then
		
			if ( math.abs( playerEyeAngle.r ) > 0.1 ) then
				playerEyeAngle.r = math.ApproachAngle( playerEyeAngle.r, 0, FrameTime() * math.min( playerEyeAngle.r * 10, 160 ) )
			elseif ( playerEyeAngle.r != 0 ) then
				playerEyeAngle.r = 0
			end
			
		end
		
		if ( newEyeAngle != eyeAngles ) then
			
			local orientationAng = LocalPlayer():GetNWAngle( "GASL:OrientationAng" )
			local playerAng = LocalPlayer():GetNWAngle( "GASL:PlayerAng" )

			if ( playerAng != eyeAngles ) then
				local angOffset = ( eyeAngles - playerAng )
				
				playerEyeAngle.p = math.max( -88, math.min( 88, playerEyeAngle.p ) )
				if ( playerEyeAngle.y > 360 ) then playerEyeAngle.y = playerEyeAngle.y - 360 end
				if ( playerEyeAngle.y < -360 ) then playerEyeAngle.y = playerEyeAngle.y + 360 end
				
				LocalPlayer():SetNWAngle( "GASL:PlayerEyeAngle", playerEyeAngle + angOffset )
				playerAng = eyeAngles
				LocalPlayer():SetNWAngle( "GASL:PlayerAng", playerAng )
			end
			
			local orientAng = orientation:Angle() + Angle( 90, 0, 0 )
			orientationAng.p = math.ApproachAngle( orientationAng.p, orientAng.p, FrameTime() * 150 )
			orientationAng.y = math.ApproachAngle( orientationAng.y, orientAng.y, FrameTime() * 150 )
			orientationAng.r = math.ApproachAngle( orientationAng.r, orientAng.r, FrameTime() * 150 )
			LocalPlayer():SetNWAngle( "GASL:OrientationAng", orientationAng )
			
			_, newEyeAngle = LocalToWorld( Vector(), playerEyeAngle, Vector(), orientationAng )
			
			local plyAng = -LocalPlayer():GetAngles()
			local _, orientAngToPly = WorldToLocal( Vector( ), plyAng, Vector( ), orientationAng )

			// changing cam orientation when player is have different orientation or roll is inccorect
			if ( orientation != Vector( 0, 0, 1 ) || orientation == Vector( 0, 0, 1 ) && math.abs( LocalPlayer():EyeAngles().r ) > 0.1 ) then
				LocalPlayer():ManipulateBoneAngles( 0, Angle( 0, 0, 0 ) )
				LocalPlayer():SetEyeAngles( newEyeAngle )
				LocalPlayer():SetNWAngle( "GASL:PlayerAng", newEyeAngle )
			end
		end
	end )
	
end

function APERTURESCIENCE:IsPlayerOnGround( ply )

	local orientation = ply:GetNWVector( "GASL:Orientation" )
	return orientation && orientation != Vector( 0, 0, 1 ) || ply:IsOnGround()
	
end

function APERTURESCIENCE:InvertNormal( normal )

	if ( normal.x != 0 ) then normal.x = normal.x * -1 end
	if ( normal.y != 0 ) then normal.y = normal.y * -1 end
	if ( normal.z != 0 ) then normal.z = normal.z * -1 end
	
end

function APERTURESCIENCE:NormalFlipZeros( normal )

	local lower = 0.000001
	if ( math.abs( normal.x ) < lower ) then normal.x = 0 end
	if ( math.abs( normal.y ) < lower ) then normal.y = 0 end
	if ( math.abs( normal.z ) < lower ) then normal.z = 0 end
	
end

function APERTURESCIENCE:CheckForGel( startpos, dir, ignoreGelledProps, excludeNormalDifferents, sufraceNormalToCompare )
	
	local trace = util.TraceLine( {
		start = startpos,
		endpos = startpos + dir,
		ignoreworld = true,
		filter = function( ent )
			if ( !excludeNormalDifferents && ent:GetClass() == "env_portal_paint" 
				|| !ignoreGelledProps && ent.GASL_GelledType
				|| excludeNormalDifferents && ent:GetClass() == "env_portal_paint" && sufraceNormalToCompare:Distance( ent:GetUp() ) < 1 ) then return true end
		end
	} )
	if ( !IsValid( trace.Entity ) ) then return NULL end
	
	local paintType = PORTAL_GEL_NONE
	local normal = Vector( 0, 0, 1 )
	local hitPosLoc = trace.Entity:WorldToLocal( trace.HitPos )
	
	if ( trace.Entity:GetClass() == "env_portal_paint" ) then
		paintType = trace.Entity:GetGelType()
		normal = trace.Entity:GetUp()
	else
		paintType = trace.Entity.GASL_GelledType
		normal = trace.HitNormal
	end
	
	return trace.Entity, paintType, normal, trace.HitPos
	
end

// no more client side
if ( CLIENT ) then return end

function APERTURESCIENCE:PaintProp( ent, paintType )
	
	local paint_model = ent.GASL_ENT_PAINT
	
	if ( IsValid( paint_model ) ) then
		paint_model:SetColor( APERTURESCIENCE:GetColorByGelType( paintType ) )
		return
	end
	
	paint_model = ents.Create( "prop_physics" )
	if ( !IsValid( paint_model ) ) then return end
	
	paint_model:SetModel( ent:GetModel() )
	paint_model:SetPos( ent:GetPos() )
	paint_model:SetAngles( ent:GetAngles() )
	paint_model:SetParent( ent )
	paint_model:PhysicsInit( SOLID_NONE )
	paint_model:SetMoveType( MOVETYPE_NONE )
	paint_model:Spawn()
	paint_model:SetNotSolid( true )
	paint_model:SetRenderMode( RENDERMODE_TRANSALPHA )
	
	paint_model:SetColor( APERTURESCIENCE:GetColorByGelType( paintType ) )
	
	local mats = paint_model:GetMaterials()
	for mInx, mat in pairs( mats ) do
		paint_model:SetSubMaterial( mInx - 1, "paint/prop_paint" )
	end
	
	paint_model.GASL_Ignore = true
	ent.GASL_ENT_PAINT = paint_model

end

function APERTURESCIENCE:ClearPaintProp( ent )

	local paint_model = ent.GASL_ENT_PAINT

	if ( !IsValid( paint_model ) ) then return end
	paint_model:Remove()
	
end

function APERTURESCIENCE:MakePaintPuddle( paintType, pos, radius )
	
	local ent = ents.Create( "ent_paint_puddle" )
	
	if ( !IsValid( ent ) ) then return end
	
	ent:SetPos( pos )
	ent:SetMoveType( MOVETYPE_NONE )
	ent:Spawn()

	ent:GetPhysicsObject():EnableCollisions( false )
	ent:GetPhysicsObject():Wake()

	ent.GASL_GelType = paintType
	ent:SetGelRadius( radius )
	
	local color = APERTURESCIENCE:GetColorByGelType( paintType )
	ent:SetColor( color )
	if ( paintType == PORTAL_GEL_WATER ) then ent:SetMaterial( "models/gasl/portal_gel_bubble/gel_water" ) end

	return ent
	
end

local function PlayerChangeOrient( ply, orientation, paint, PaintHitPos )
	
	// Handling changing orientation
	local CurrentOrient = ply:GetNWVector( "GASL:Orientation" )
	local PlyOrientCenter = ply:GetPos() + CurrentOrient * ply:GetModelRadius() / 2
	local OrientPlyRad = orientation * ply:GetModelRadius()
	local plyAngle = ply:EyeAngles()
	if( !IsValid( paint ) ) then paint, _, _, PaintHitPos = APERTURESCIENCE:CheckForGel( PlyOrientCenter, -OrientPlyRad ) end
	
	// changing camera orientation
	ply:SetCurrentViewOffset( Vector( OrientPlyRad.x, OrientPlyRad.y, 0 ) )
	ply:SetViewOffset( Vector( 0, 0, OrientPlyRad.z ) )
	-- local orientAngOld = ply:GetNWVector( "GASL:Orientation" ):Angle() + Angle( 90, 0, 0 )
	-- local orientAngNew = orientation:Angle() + Angle( 90, 0, 0 )
	-- local _, localangle = WorldToLocal( Vector(), plyAngle, Vector(), orientAngOld )
	-- localangle = Angle( 0, localangle.yaw, 0 )
	-- local _, worldangle = LocalToWorld( Vector(), localangle, Vector(), orientAngNew )
	-- ply:SetEyeAngles( worldangle )
	
	ply:SetNWVector( "GASL:Orientation", orientation )
	
	if ( orientation != CurrentOrient ) then
		
		if ( orientation == Vector( 0, 0, 1 ) ) then
			if ( IsValid( ply:GetNWEntity( "GASL:Avatar" ) ) ) then
				ply:GetNWEntity( "GASL:Avatar" ):Remove()
				local Colr = ply:GetColor()
				Colr.a = 255
				ply:SetColor( Colr )
				ply:SetRenderMode( RENDERMODE_NORMAL )
			end
		elseif ( !IsValid( ply:GetNWEntity( "GASL:Avatar" ) ) ) then
			ply:SetRenderMode( RENDERMODE_TRANSALPHA )
			local Colr = ply:GetColor()
			Colr.a = 0
			ply:SetColor( Colr )
			
			local avatar = ents.Create( "gasl_player_avatar" )
			if ( !IsValid( avatar ) ) then return end
			avatar:SetPlayer( ply )
			avatar:SetPos( ply:GetPos() )
			avatar:SetAngles( orientation:Angle() + Angle( 90, 0, 0 ) )
			avatar:Spawn()
		end
		
	end
	
	if ( !IsValid( paint ) || orientation == Vector( 0, 0, 1 ) ) then return end
	ply:SetNWVector( "GASL:OrientationWalk", PaintHitPos )
	ply:SetPos( PaintHitPos )
	ply:SetVelocity( -ply:GetVelocity() )

	// cooldown for changing
	timer.Create( "GASL_Player_Changed"..ply:EntIndex(), 0.1, 1, function() end ) // disable changeabling for a second
end

hook.Add( "Think", "GASL:HandlingGel", function()	

	for i, ply in pairs( player.GetAll() ) do
		
		-- Checking if player stands or hit paint
		if ( ply:GetNWVector( "GASL:Orientation" ) == Vector() ) then ply:SetNWVector( "GASL:Orientation", Vector( 0, 0, 1 ) ) end
		if ( !ply:GetNWVector( "GASL:OrientationWalk" ) ) then ply:SetNWVector( "GASL:OrientationWalk", Vector( 0, 0, 0 ) ) end
		if ( !ply.GASL_Player_PrevOrient ) then ply.GASL_Player_PrevOrient = Angle() end

		local orientation 	= ply:GetNWVector( "GASL:Orientation" )
		local eyeAngle 		= ply:EyeAngles()
		local dir 			= Vector( )
		
		if ( APERTURESCIENCE:IsPlayerOnGround( ply ) || orientation != Vector( 0, 0, 1 ) ) then dir = -orientation * ( ply:GetModelRadius() + 50 )
		else
			dir = ply:GetVelocity() / 20
			if ( dir:Length() < ply:GetModelRadius() ) then dir = dir:GetNormalized() * ply:GetModelRadius() end
		end
		local paint, paintType, PaintNormal, PaintHitPos = APERTURESCIENCE:CheckForGel( ply:GetPos() + orientation * ply:GetModelRadius() / 2, dir )

		// getting player moving direction including his orientation
		local Speed = ply:GetWalkSpeed()
		if ( ply:KeyDown( IN_WALK ) ) then Speed = ply:GetWalkSpeed() / 2 end
		if ( ply:KeyDown( IN_SPEED ) ) then Speed = ply:GetRunSpeed() end
		Speed = Speed * FrameTime() * 50
		
		local moveDirection = Vector( 0, 0, 0 )
		local plyOrientCenter = ply:GetPos() + orientation * ply:GetModelRadius() / 2
		
		if ( ply:KeyDown( IN_FORWARD ) ) then moveDirection.x = 1 end
		if ( ply:KeyDown( IN_BACK ) ) then moveDirection.x = -1 end
		if ( ply:KeyDown( IN_MOVELEFT ) ) then moveDirection.y = 1 end
		if ( ply:KeyDown( IN_MOVERIGHT ) ) then moveDirection.y = -1 end
		moveDirection:Normalize() 
		
		local orientAng = orientation:Angle() + Angle( 90, 0, 0 )
		local _, localangle = WorldToLocal( Vector(), eyeAngle, Vector(), orientAng )
		localangle = Angle( 0, localangle.yaw, 0 )
		local _, worldangle = LocalToWorld( Vector(), localangle, Vector(), orientAng )
		moveDirection:Rotate( worldangle )

		-- Checking for gel infront of player current position
		-- if doesn't found then tring to do this againg but with conner on floor
		local p, pT, pN, pV = APERTURESCIENCE:CheckForGel( plyOrientCenter, moveDirection * 40 )
		if ( !IsValid( p ) ) then
			for i = 1, 10 do
				p, pT, pN, pV = APERTURESCIENCE:CheckForGel( 
					plyOrientCenter + moveDirection * ply:GetModelRadius() / 2 - orientation * ( ply:GetModelRadius() / 2 + i * 2 ), 
					-moveDirection * ply:GetModelRadius() / 2
				)
				if ( IsValid( p ) ) then break end
			end
		end
		
		if ( IsValid( p ) && pT == PORTAL_GEL_STICKY && !timer.Exists( "GASL_Player_Changed"..ply:EntIndex() ) ) then
			paint 			= p
			paintType 		= pT
			orientation 	= pN
			PaintNormal 	= pN
			PaintHitPos 	= pV
			PlayerChangeOrient( ply, orientation, p, PaintHitPos )
		end
		
		-- Handling exiting gel
		if ( ply.GASL_LastStandingGelType && CurTime() > ply.GASL_LastTimeOnGel + 0.25 ) then
		
			if ( ply.GASL_LastStandingGelType == PORTAL_GEL_BOUNCE ) then ply:EmitSound( "GASL.GelBounceExit" ) end
			
			if ( ply.GASL_LastStandingGelType == PORTAL_GEL_SPEED ) then ply:EmitSound( "GASL.GelSpeedExit" ) end
			
			if ( ply.GASL_LastStandingGelType == PORTAL_GEL_STICKY ) then
				local offset = orientation * ( orientation - Vector( 0, 0, 1 ) ):Length() * ply:GetModelRadius() / 1.5
				local TraceFloor = util.QuickTrace( ply:GetPos() + offset, Vector( 0, 0, -ply:GetModelRadius() ), ply )
				offset = offset - Vector( 0, 0, TraceFloor.Fraction * ply:GetModelRadius() )
				ply:SetPos( ply:GetPos() + offset )
				ply:EmitSound( "GASL.GelStickExit" )

				orientation = Vector( 0, 0, 1 )
				PaintNormal = orientation
				PlayerChangeOrient( ply, Vector( 0, 0, 1 ) )
			end

			ply.GASL_LastStandingGelType = 0
		end

		if ( ( !IsValid( paint ) && ply.GASL_LastTimeOnGel && CurTime() > ply.GASL_LastTimeOnGel + 0.25 || IsValid( paint ) && paintType != PORTAL_GEL_STICKY ) && orientation != Vector( 0, 0, 1 ) ) then
			local offset = orientation * ( orientation - Vector( 0, 0, 1 ) ):Length() * ply:GetModelRadius() / 1.5
			local TraceFloor = util.QuickTrace( ply:GetPos() + offset, Vector( 0, 0, -ply:GetModelRadius() ), ply )
			offset = offset - Vector( 0, 0, TraceFloor.Fraction * ply:GetModelRadius() )
			ply:SetPos( ply:GetPos() + offset )
			
			orientation = Vector( 0, 0, 1 )
			PaintNormal = orientation
			PlayerChangeOrient( ply, Vector( 0, 0, 1 ) )
		end

		if ( !IsValid( paint ) ) then
			
			-- Skip if paint doesn't found
			continue
		end
		APERTURESCIENCE:NormalFlipZeros( PaintNormal )
		
		-- Footsteps sounds
		if ( APERTURESCIENCE:IsPlayerOnGround( ply ) && !timer.Exists( "GASL_GelFootsteps"..ply:EntIndex() )
			&& ( ply:KeyDown( IN_FORWARD ) || ply:KeyDown( IN_BACK ) || ply:KeyDown( IN_MOVERIGHT ) || ply:KeyDown( IN_MOVELEFT ) ) ) then
			ply:EmitSound( "GASL.GelFootsteps" )

			local tick = ply:KeyDown( IN_SPEED ) and 0.2 or 0.4
			timer.Create( "GASL_GelFootsteps"..ply:EntIndex(), tick, 1, function() end )
			
		end
		
		-- Handling entering gel
		if ( APERTURESCIENCE:IsPlayerOnGround( ply ) ) then
			
			if ( !ply.GASL_LastTimeOnGel || ply.GASL_LastTimeOnGel && CurTime() > ply.GASL_LastTimeOnGel + 0.25 ) then
			
				if ( paintType == PORTAL_GEL_BOUNCE ) then ply:EmitSound( "GASL.GelBounceEnter" ) end
				
				if ( paintType == PORTAL_GEL_SPEED ) then ply:EmitSound( "GASL.GelSpeedEnter" ) end
				
				if ( paintType == PORTAL_GEL_STICKY ) then
					ply:EmitSound( "GASL.GelStickEnter" )
					if ( PaintNormal:Distance( orientation ) > 0.000001 ) then PlayerChangeOrient( ply, PaintNormal ) end
				end
				
				-- doesn't change if player ran on repulsion paint when he was on propulsion paint
				if ( paintType != PORTAL_GEL_BOUNCE || ply.GASL_LastStandingGelType != PORTAL_GEL_SPEED || plyVelocity:Length() < 400 ) then
					ply.GASL_LastStandingGelType = paintType
				end
				
			end
			
			ply.GASL_LastTimeOnGel = CurTime()
		
		end
		
		-- if player stand on repulsion paint
		if ( paintType == PORTAL_GEL_BOUNCE && !ply:KeyDown( IN_DUCK ) ) then
			local plyVelocity = ply:GetVelocity()
			
			-- skip if player stand on the ground
			-- doesn't skip if player ran on repulsion paint when he was on propulsion paint
			if ( !APERTURESCIENCE:IsPlayerOnGround( ply ) || ply.GASL_LastStandingGelType == PORTAL_GEL_SPEED && plyVelocity:Length() > 400 ) then
				
				local WTL = WorldToLocal( plyVelocity, Angle( ), Vector( ), PaintNormal:Angle() + Angle( 90, 0, 0 ) )
				WTL = Vector( 0, 0, math.max( math.abs( WTL.z ) * 2, 800 ) )
				local LTW = LocalToWorld( WTL, Angle( ), Vector( ), PaintNormal:Angle() + Angle( 90, 0, 0 ) )
				LTW.z = math.max( 200, LTW.z / 2 )
				
				ply:SetVelocity( LTW + Vector( 0, 0, math.abs( ply:GetVelocity().z ) ) )
				ply:EmitSound( "GASL.GelBounce" )
			end
		end
		
		-- if player stand on propulsion paint
		if ( paintType == PORTAL_GEL_SPEED ) then
			local plyVelocity = ply:GetVelocity()

			if ( !ply.GASL_GelPlayerVelocity || ply.GASL_GelPlayerVelocity:Length() == math.huge ) then ply.GASL_GelPlayerVelocity = Vector( ) end
			if ( plyVelocity:Length() > ply.GASL_GelPlayerVelocity:Length() ) then ply.GASL_GelPlayerVelocity = ply.GASL_GelPlayerVelocity + plyVelocity / 10 end
			
			// When player moving towards increese speed
			if ( ply:KeyDown( IN_FORWARD ) ) then
				ply.GASL_GelPlayerVelocity = ply.GASL_GelPlayerVelocity + Vector( ply:GetForward().x, ply:GetForward().y, 0 ) * 30
			end

			//print( ply.GASL_GelPlayerVelocity )
			ply:SetVelocity( Vector( ply.GASL_GelPlayerVelocity.x, ply.GASL_GelPlayerVelocity.y, 0 ) * FrameTime() * 40 )
			ply.GASL_GelPlayerVelocity = ply.GASL_GelPlayerVelocity / 2
		end
		
		-- if player stand on sticky paint
		if ( paintType == PORTAL_GEL_STICKY && ply:GetNWVector( "GASL:OrientationWalk" ) != Vector() ) then

			-- if ( !timer.Exists( "GASL_Player_Changed"..ply:EntIndex() ) && PaintNormal:Distance( orientation ) > 0.000001 ) then
				-- orientation = PaintNormal

				-- //APERTURESCIENCE:NormalFlipZeros( orientation )
				-- PlayerChangeOrient( ply, PaintNormal )
				
			-- end
			
			local localPos = ply:GetNWVector( "GASL:OrientationWalk" )
			
			if ( localPos != Vector( ) && orientation != Vector( 0, 0, 1 ) ) then
				
				local MoveDirection = moveDirection * Speed / 50

				if ( ply:KeyDown( IN_JUMP ) ) then
					local traceFloor = util.QuickTrace( ply:GetPos(), Vector( 0, 0, -ply:GetModelRadius() ), ply )
					MoveDirection = orientation * ( orientation - Vector( 0, 0, 1 ) ):Length() * ply:GetModelRadius() / 1.5 - Vector( 0, 0, ply:GetModelRadius() * traceFloor.Fraction )
					PlayerChangeOrient( ply, Vector( 0, 0, 1 ) )
					ply:SetVelocity( orientation * ply:GetJumpPower() )
				end

				local plyWidth = 30
				local traceForward = util.QuickTrace( ply:GetPos() + orientation * ply:GetModelRadius() / 2, orientAng:Forward() * plyWidth, ply )
				local traceBack = util.QuickTrace( ply:GetPos() + orientation * ply:GetModelRadius() / 2, -orientAng:Forward() * plyWidth, ply )
				local traceRight = util.QuickTrace( ply:GetPos() + orientation * ply:GetModelRadius() / 2, orientAng:Right() * plyWidth, ply )
				local traceLeft = util.QuickTrace( ply:GetPos() + orientation * ply:GetModelRadius() / 2, -orientAng:Right() * plyWidth, ply )
				
				if ( traceForward.Hit ) then MoveDirection = MoveDirection - orientAng:Forward() * ( 1 - traceForward.Fraction ) * plyWidth end
				if ( traceBack.Hit ) then MoveDirection = MoveDirection + orientAng:Forward() * ( 1 - traceBack.Fraction ) * plyWidth end
				if ( traceRight.Hit ) then MoveDirection = MoveDirection - orientAng:Right() * ( 1 - traceRight.Fraction ) * plyWidth end
				if ( traceLeft.Hit ) then MoveDirection = MoveDirection + orientAng:Right() * ( 1 - traceLeft.Fraction ) * plyWidth end
				
				local walk = localPos + MoveDirection
				ply:SetNWVector( "GASL:OrientationWalk", walk )
				ply:SetPos( walk )
				if ( !ply:KeyDown( IN_JUMP ) ) then
					ply:SetVelocity( -ply:GetVelocity() )
				end
			end
			
		end
	end
	
	-- Handling paintled entities
	for k, v in pairs( APERTURESCIENCE.GELLED_ENTITIES ) do
	
		-- skip and remove if entity is not exist
		if ( !IsValid( v ) ) then
			APERTURESCIENCE.GELLED_ENTITIES[ k ] = nil
			continue
		end

		-- skip if props is freezed or it is holding by the player
		if ( IsValid( v:GetPhysicsObject() ) && !v:GetPhysicsObject():IsMotionEnabled( ) || v:IsPlayerHolding() ) then continue end
		
		local vPhys = v:GetPhysicsObject()
		local dir = vPhys:GetVelocity() / 10
		
		local trace = util.TraceEntity( { 
			start = v:GetPos()
			, endpos = v:GetPos() + dir
			, filter = v 
		}, v )

		if ( v.GASL_GelledType == PORTAL_GEL_BOUNCE ) then
			if ( trace.Hit ) then
				v:EmitSound( "GASL.GelBounceProp" )
				-- makes negative z for local hitnormal
				local WTL = WorldToLocal( vPhys:GetVelocity(), Angle( ), Vector( ), trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
				WTL.z = math.max( -WTL.z, 400 )
				WTL = WTL + VectorRand() * 100
				local LTW = LocalToWorld( WTL, Angle( ), Vector( ), trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
				
				vPhys:SetVelocity( LTW )
				
				v:GetPhysicsObject():AddAngleVelocity( VectorRand() * 400 )
			end
		end
		
		if ( v.GASL_GelledType == PORTAL_GEL_STICKY ) then
		
			if ( trace.Hit && ( !IsValid( trace.Entity ) || IsValid( trace.Entity ) && !IsValid( constraint.Find( v, trace.Entity, "Weld", 0, 0 ) ) ) ) then
				timer.Simple( dir:Length() / 1000, function()
					if ( IsValid( v ) && IsValid( v:GetPhysicsObject() ) ) then
						if ( trace.HitWorld ) then
							v:GetPhysicsObject():EnableMotion( false )
						elseif( IsValid( trace.Entity ) ) then
							constraint.Weld( v, trace.Entity, 0, trace.PhysicsBone, 5000, collision == 0, false )
						end
					end
				end )
			end
		end
	end

end )