--[[

	APERTURE API MAIN
	
]]

AddCSLuaFile( )

APERTURESCIENCE = { }

-- Main 
APERTURESCIENCE.DRAW_HALOS = true

-- Funnel
APERTURESCIENCE.FUNNEL_MOVE_SPEED = 173
APERTURESCIENCE.FUNNEL_COLOR = Color( 0, 150, 255 )
APERTURESCIENCE.FUNNEL_REVERSE_COLOR = Color( 255, 150, 0 )

-- Gel
APERTURESCIENCE.GEL_QUALITY = 1
APERTURESCIENCE.GEL_BOX_SIZE = 47
APERTURESCIENCE.GEL_MAXSIZE = 150
APERTURESCIENCE.GEL_MINSIZE = 40
APERTURESCIENCE.GEL_BOUNCE_COLOR = Color( 0, 100, 255 )
APERTURESCIENCE.GEL_SPEED_COLOR = Color( 255, 100, 0 )
APERTURESCIENCE.GEL_PORTAL_COLOR = Color( 180, 190, 200 )
APERTURESCIENCE.GEL_WATER_COLOR = Color( 200, 230, 255 )
APERTURESCIENCE.GELLED_ENTITIES = { }

-- Fizzle
APERTURESCIENCE.DISSOLVE_SPEED = 150
APERTURESCIENCE.DISSOLVE_ENTITIES = { }

include( "aperture/sounds/gel_sounds.lua" )
include( "aperture/sounds/tractor_beam_sounds.lua" )
include( "aperture/sounds/catapult_sounds.lua" )
include( "aperture/sounds/wall_projector_sounds.lua" )
include( "aperture/sounds/monster_box_sounds.lua" )
include( "aperture/sounds/fizzler_sounds.lua" )
include( "aperture/sounds/laser_sounds.lua" )
include( "aperture/sounds/item_dropper_sounds.lua" )
include( "aperture/sounds/portal_button_sounds.lua" )

function APERTURESCIENCE:PlaySequence( self, seq, rate )

	if ( !self:IsValid() ) then return end
	
	local sequence = self:LookupSequence( seq )
	self:ResetSequence( sequence )

	self:SetPlaybackRate( rate )
	self:SetSequence( sequence )
	
	return self:SequenceDuration( sequence )
	
end

function APERTURESCIENCE:ConnectableStuff( ent )

	if ( IsValid( ent ) &&
		( ent:GetClass() == "ent_paint_dropper"
		|| ent:GetClass() == "ent_tractor_beam"
		|| ent:GetClass() == "ent_wall_projector"
		|| ent:GetClass() == "ent_laser_field"
		|| ent:GetClass() == "ent_fizzler"
		|| ent:GetClass() == "ent_portal_laser"
		|| ent:GetClass() == "ent_laser_catcher"
		|| ent:GetClass() == "ent_laser_relay"
		|| ent:GetClass() == "ent_item_dropper"
		|| ent:GetClass() == "ent_portal_button"
		|| ent:GetClass() == "sent_portalbutton_box"
		|| ent:GetClass() == "sent_portalbutton_ball"
		|| ent:GetClass() == "sent_portalbutton_normal"
		|| ent:GetClass() == "sent_portalbutton_old" ) ) then return true end
		
	return false
end

function APERTURESCIENCE:IsValidEntity( ent )

	if ( IsValid( ent ) && !ent.GASL_Ignore 
		&& ( !IsValid( ent:GetPhysicsObject() ) || IsValid( ent:GetPhysicsObject() ) && ent:GetPhysicsObject():IsMotionEnabled() )
		&& ent:GetClass() != "env_paint_paint" 
		&& ent:GetClass() != "env_paint_puddle"
		&& ent:GetClass() != "ent_paint_dropper"
		&& ent:GetClass() != "ent_tractor_beam"
		&& ent:GetClass() != "ent_wall_projector"
		&& ent:GetClass() != "ent_laser_field"
		&& ent:GetClass() != "ent_fizzler"
		&& ent:GetClass() != "ent_portal_laser"
		&& ent:GetClass() != "ent_laser_catcher"
		&& ent:GetClass() != "ent_laser_relay"
		&& ent:GetClass() != "ent_item_dropper"
		&& ent:GetClass() != "ent_portal_button"
		&& ent:GetClass() != "ent_portal_bomb"
		&& ent:GetClass() != "ent_catapult" ) then  return true end
	
	return false
end

function APERTURESCIENCE:DissolveEnt( ent )

	local phys = ent:GetPhysicsObject()
	ent:SetSolid( SOLID_NONE )
	if ( phys:GetVelocity():Length() < 10 ) then
		phys:SetVelocity( Vector( 0, 0, 10 ) + VectorRand() * 2 )
		phys:AddAngleVelocity( VectorRand() * 100 )
	else
		phys:SetVelocity( phys:GetVelocity() / 4 )
	end
	phys:EnableGravity( false )
	ent:EmitSound( "GASL.FizzlerDissolve" )
	table.insert( APERTURESCIENCE.DISSOLVE_ENTITIES, table.Count( APERTURESCIENCE.DISSOLVE_ENTITIES ) + 1, ent )

end

function APERTURESCIENCE:GetColorByGelType( gelType )

	local color = Color( 0, 0, 0 )
	if ( gelType == 1 ) then color = APERTURESCIENCE.GEL_BOUNCE_COLOR end
	if ( gelType == 2 ) then color = APERTURESCIENCE.GEL_SPEED_COLOR end
	if ( gelType == 3 ) then color = APERTURESCIENCE.GEL_PORTAL_COLOR end
	if ( gelType == 4 ) then color = APERTURESCIENCE.GEL_WATER_COLOR end
	
	return color
	
end

function APERTURESCIENCE:CalcBezierCurvePoint( startpos, middlepos, endpos, segmentsCount )

	local points = { }
	local totalLength = 0
	
	table.insert( points, table.Count( points ) + 1, startpos )

	local prevPos = startpos
	for inx = 1, segmentsCount do

		local i = inx / segmentsCount
		
		local NX = math.pow( 1 - i, 2 ) * startpos.x + 2 * i * ( 1 - i ) * middlepos.x + math.pow( i, 2 ) * endpos.x
		local NY = math.pow( 1 - i, 2 ) * startpos.y + 2 * i * ( 1 - i ) * middlepos.y + math.pow( i, 2 ) * endpos.y
		local NZ = math.pow( 1 - i, 2 ) * startpos.z + 2 * i * ( 1 - i ) * middlepos.z + math.pow( i, 2 ) * endpos.z
		
		table.insert( points, table.Count( points ) + 1, Vector( NX, NY, NZ ) )
		
		totalLength = totalLength + Vector( NX, NY, NZ ):Distance( prevPos )
		prevPos = Vector( NX, NY, NZ )
		
	end
	
	return points, totalLength
	
end

function APERTURESCIENCE:CalcParabolCurve(  )

	

end

hook.Add( "Initialize", "GASL_Initialize", function()

	if ( SERVER ) then
		util.AddNetworkString( "GASL_LinkConnection" ) 
	end

end )

hook.Add( "PreDrawHUD", "GASL_HUDRender", function()

	cam.Start3D()
	
		local ply = LocalPlayer()
	
		if ( ply:GetActiveWeapon():IsValid() && ply:GetActiveWeapon():GetClass() == "gmod_tool" 
			&& ply:GetTool() && ply:GetTool().Mode && ply:GetTool().Mode == "aperture_science_catapult" ) then

			for i, catapult in pairs( ents.FindByClass( "ent_catapult" ) ) do
				
				local tool = ply:GetTool( "aperture_science_catapult" )
				
				-- Draw trajectory if player holding air faith plate tool
				if ( catapult:GetLandPoint() == Vector() || catapult:GetLaunchHeight() == 0 ) then continue end
				
				local startpos = Vector( )

				if ( tool.GASL_MakePoint && tool.GASL_Catapult == catapult ) then 
					startpos = LocalPlayer():GetEyeTrace().HitPos
				else
					startpos = catapult:GetPos()
				end
				
				local endpos = catapult:GetLandPoint()
				local height = catapult:GetLaunchHeight()
				local middlepos = ( startpos + endpos ) / 2
				//local points, length = APERTURESCIENCE:CalcBezierCurvePoint( startpos, middlepos + Vector( 0, 0, height * 2 ), endpos, 10 )
				local prevBeamPos = startpos

				-- -- Drawing Rotation
				-- render.SetMaterial( Material( "effects/wheel_ring" ) )
				-- render.DrawQuadEasy( catapult:GetPos(), catapult:GetUp(), 200, 200, Color( 255, 255, 255 ), 0 )
				
				-- Drawing land target
				render.SetMaterial( Material( "signage/mgf_overlay_bullseye" ) )
				render.DrawQuadEasy( endpos, Vector( 0, 0, 1 ), 80, 80, Color( 255, 255, 255 ), 0 )
				
				-- Drawing trajectory
				render.SetMaterial( Material( "effects/trajectory_path" ) )
				local amount = math.max( 4, startpos:Distance( endpos ) / 200 )
				
				local Iterrations = 20
				
				local timeofFlight = catapult:GetTimeOfFlight()
				local launchVector = catapult:GetLaunchVector()

				local dTime = timeofFlight / ( Iterrations )
				local dVector = launchVector * dTime
				
				local point = catapult:GetPos()
				local Gravity = math.abs( physenv.GetGravity().z ) * timeofFlight / ( Iterrations - 1 )
				
				for i = 1, Iterrations do
				
					point = point + dVector
					dVector = dVector - Vector( 0, 0, Gravity * dTime )
					
					render.DrawBeam( prevBeamPos, point, 120, 0, 1, Color( 255, 255, 255 ) )
					prevBeamPos = point
					
				end
				
				-- Drawing height point
				render.SetMaterial( Material( "sprites/sent_ball" ) )
				render.DrawSprite( middlepos + Vector( 0, 0, height ), 32, 32, Color( 255, 255, 0 ) ) 
			end
		end
		
	cam.End3D()
end )

function APERTURESCIENCE:CheckForGel( startpos, dir )
	
	local trace = util.TraceLine( {
		start = startpos,
		endpos = startpos + dir,
		ignoreworld = true,
		filter = function( ent ) if ( ent:GetClass() == "ent_gel_paint" ) then return true end end
	} )
	
	return trace
	
end

function APERTURESCIENCE:IK_Leg_two_dof( parentAngle, startPos, endPos, dofLength1, dofLength2 )
	
	local distStartEnd = startPos:Distance( endPos )
	local rad2deg = 180 / math.pi
	
	// Getting Angles

	// Dof 1
	local a = math.pow( distStartEnd, 2 ) + math.pow( dofLength1, 2 ) - math.pow( dofLength2, 2 )
	local aa = a / ( 2 * distStartEnd * dofLength1 )
	aa = math.max( -1, math.min( 1, aa ) )
	
	local firstDofAng = math.acos( aa ) * rad2deg
	
	local WTLP, WTLA = WorldToLocal( Vector(), ( endPos - startPos ):Angle(), startPos, parentAngle )
	WTLA1 = Angle( WTLA.pitch - firstDofAng, WTLA.yaw, 0 )
	local LTWP, LTWA1 = LocalToWorld( Vector(), WTLA1, startPos, parentAngle )

	local firstDofPos = startPos + LTWA1:Forward() * dofLength1
	
	// Dof 2
	local b = math.pow( dofLength1, 2 ) + math.pow( dofLength2, 2 ) - math.pow( distStartEnd, 2 )
	local bb = b / ( 2 * dofLength1 * dofLength2 )
	bb = math.max( -1, math.min( 1, bb ) )
	
	local secondDofAng = math.acos( bb ) * rad2deg
	
	WTLA2 = Angle( WTLA.pitch - firstDofAng - secondDofAng + 180, WTLA.yaw, 0 )
	local LTWP, LTWA2 = LocalToWorld( Vector( 0, 0, 0 ), WTLA2, startPos, parentAngle )

	local secondDofPos = firstDofPos + LTWA2:Forward() * dofLength2
	
	local debugBoxSize = Vector( 3, 3, 3 )
	
	// Debug render
	if ( CLIENT ) then
		render.SetMaterial(Material("models/wireframe"))
		render.DrawBox(firstDofPos, LTWA1, -debugBoxSize, debugBoxSize, Color(255, 255, 255), 0) 
		render.DrawBox(secondDofPos, LTWA2, -debugBoxSize, debugBoxSize, Color(255, 255, 255), 0) 
		
		render.DrawBox((startPos + firstDofPos) / 2, LTWA1, -Vector(dofLength1 / 2, 2, 2), Vector(dofLength1 / 2, 2, 2), Color(255, 255, 255), 0) 
		render.DrawBox((firstDofPos + secondDofPos) / 2, LTWA2, -Vector(dofLength2 / 2, 2, 2), Vector(dofLength2 / 2, 2, 2), Color(255, 255, 255), 0) 
	end
	
	return firstDofPos, WTLA1, LTWA1, secondDofPos, WTLA2, LTWA2
	
end

if ( CLIENT ) then return end

hook.Add( "Think", "GASL_HandlingGel", function()
	
	for i, ply in pairs( player.GetAll() ) do
		
		-- Checking if player stands or hit gel
		local gel = { }
		if ( ply:IsOnGround() ) then
			gel = APERTURESCIENCE:CheckForGel( ply:GetPos(), Vector( 0, 0, -100 ) ).Entity
		else
			local dir = ply:GetVelocity() / 20
			
			if ( dir:Length() < 30 ) then
				dir = dir:GetNormalized() * 30
			end
			
			gel = APERTURESCIENCE:CheckForGel( ply:GetPos(), dir ).Entity
		end

		-- Exiting Gel
		if ( ply.GASL_LastStandingGelType && CurTime() > ply.GASL_LastTimeOnGel + 0.25 ) then
		
			if ( ply.GASL_LastStandingGelType == 1 ) then
				ply:EmitSound( "GASL.GelBounceExit" )
			end
			
			if ( ply.GASL_LastStandingGelType == 2 ) then
				ply:EmitSound( "GASL.GelSpeedExit" )
			end

			ply.GASL_LastStandingGelType = 0
		
		end

		-- Skip if gel doesn't found
		if ( !gel:IsValid() ) then continue end
		
		-- Footsteps sounds
		if ( ply:IsOnGround() && !timer.Exists( "GASL_GelFootsteps"..ply:EntIndex() )
			&& ( ply:KeyDown( IN_FORWARD )
			|| ply:KeyDown( IN_BACK )
			|| ply:KeyDown( IN_MOVERIGHT )
			|| ply:KeyDown( IN_MOVELEFT ) ) ) then
		
			ply:EmitSound( "GASL.GelFootsteps" )

			local tick
			if ( ply:KeyDown( IN_SPEED ) ) then
				tick = 0.2
			else
				tick = 0.4
			end
			
			timer.Create( "GASL_GelFootsteps"..ply:EntIndex(), tick, 1, function() end )
			
		end
		
		-- Entering Gel
		if ( ply:IsOnGround() ) then
		
			if ( !ply.GASL_LastTimeOnGel || ply.GASL_LastTimeOnGel && CurTime() > ply.GASL_LastTimeOnGel + 0.25 ) then
			
				if ( gel:GetGelType() == 1 ) then
					ply:EmitSound( "GASL.GelBounceEnter" )
				end
				
				if ( gel:GetGelType() == 2 ) then
					ply:EmitSound( "GASL.GelSpeedEnter" )
				end

				-- doesn't change if player ran on repulsion gel when he was on propulsion gel
				if ( !( gel:GetGelType() == 1 && ply.GASL_LastStandingGelType == 2 && plyVelocity:Length() > 400 ) ) then
					ply.GASL_LastStandingGelType = gel:GetGelType()
				end
				
			end
			
			ply.GASL_LastTimeOnGel = CurTime()
		
		end
		
		-- if player hit repulsion gel
		if ( gel:GetGelType() == 1 && !ply:KeyDown( IN_DUCK ) ) then
		
			local plyVelocity = ply:GetVelocity()
			
			-- skip if player stand on the ground
			-- doesn't skip if player ran on repulsion gel when he was on propulsion gel
			if ( ply:IsOnGround() && !( ply.GASL_LastStandingGelType == 2 && plyVelocity:Length() > 400 ) ) then continue end
			
			local WTL = WorldToLocal( gel:GetPos() + plyVelocity, Angle( ), gel:GetPos(), gel:GetAngles() )
			WTL = Vector( 0, 0, math.max( -WTL.z * 2, 800 ) )
			local LTW = LocalToWorld( WTL, Angle( ), gel:GetPos(), gel:GetAngles() ) - gel:GetPos()
			LTW.z = math.max( 200, LTW.z / 2 )
			
			ply:SetVelocity( LTW - Vector( 0, 0, ply:GetVelocity().z ) )
			ply:EmitSound( "GASL.GelBounce" )

		end
		
		-- if player hit propulsion gel
		if ( gel:GetGelType() == 2 ) then
		
			local plyVelocity = ply:GetVelocity()

			if ( !ply.GASL_GelPlayerVelocity ) then ply.GASL_GelPlayerVelocity = Vector( ) end
			
			if ( plyVelocity:Length() > ply.GASL_GelPlayerVelocity:Length() ) then ply.GASL_GelPlayerVelocity = ply.GASL_GelPlayerVelocity + plyVelocity / 10 end
			
			if ( ply:KeyDown( IN_FORWARD ) ) then
				ply.GASL_GelPlayerVelocity = ply.GASL_GelPlayerVelocity + Vector( ply:GetForward().x, ply:GetForward().y, 0 ) * 30
			end

			ply:SetVelocity( Vector( ply.GASL_GelPlayerVelocity.x, ply.GASL_GelPlayerVelocity.y, 0 ) / 2 * math.max( 1, ply:Ping() / 50 ) )
			ply.GASL_GelPlayerVelocity = ply.GASL_GelPlayerVelocity / 2
			
		end
		
	end
	
	-- Handling gelled entities
	for k, v in pairs( APERTURESCIENCE.GELLED_ENTITIES ) do
	
		-- skip and remove if entity is not exist
		if ( !v:IsValid() ) then
			APERTURESCIENCE.GELLED_ENTITIES[ k ] = nil
			continue
		end
		
		if ( v.GASL_GelledType == 1 ) then
			
			local vPhys = v:GetPhysicsObject()
			local dir = vPhys:GetVelocity() / 50
			
			if ( dir:Length() < 40 ) then
			
				if ( dir == Vector() ) then dir = Vector( 0, 0, -1 ) end
				dir = dir:GetNormalized() * 40
				
			end
			
			local trace = { start = v:GetPos(), endpos = v:GetPos() + dir, filter = v }

			local tr = util.TraceEntity( trace, v )

			if ( tr.Hit ) then
				
				v:EmitSound( "GASL.GelBounceProp" )
				-- makes negative z for local hitnormal
				local WTL = WorldToLocal( vPhys:GetVelocity(), Angle( ), Vector( ), tr.HitNormal:Angle() + Angle( 90, 0, 0 ) )
				WTL.z = math.max( -WTL.z, 400 )
				WTL = WTL + VectorRand() * 100
				local LTW = LocalToWorld( WTL, Angle( ), Vector( ), tr.HitNormal:Angle() + Angle( 90, 0, 0 ) )
				
				vPhys:SetVelocity( LTW )
				
				v:GetPhysicsObject():AddAngleVelocity( VectorRand() * 400 )
				
			end
			
		end
	end
	
	-- Handling dissolved entities
	for k, v in pairs( APERTURESCIENCE.DISSOLVE_ENTITIES ) do
	
		-- skip if entity doesn't exist
		if ( !v:IsValid() ) then
			APERTURESCIENCE.DISSOLVE_ENTITIES[ k ] = nil
			continue
		end
		
		if ( !v.GASL_Dissolve ) then v.GASL_Dissolve = 0 end
		v.GASL_Dissolve = v.GASL_Dissolve + 1
		
		-- turning entity into black and then fadeout alpha
		local colorBlack = ( math.max( 0, APERTURESCIENCE.DISSOLVE_SPEED - v.GASL_Dissolve * 1.75 ) / APERTURESCIENCE.DISSOLVE_SPEED ) * 255
		
		local alpha = math.max( 0, v.GASL_Dissolve - APERTURESCIENCE.DISSOLVE_SPEED / 1.1 ) / ( APERTURESCIENCE.DISSOLVE_SPEED - APERTURESCIENCE.DISSOLVE_SPEED / 1.1 )
		alpha = 255 - alpha * 255
		v:SetColor( Color( colorBlack, colorBlack, colorBlack, alpha ) )
		
		if ( alpha < 255 ) then v:SetRenderMode( RENDERMODE_TRANSALPHA ) end

		local effectdata = EffectData()
		effectdata:SetEntity( v )
		util.Effect( "fizzler_dissolve", effectdata )
		
		if ( v.GASL_Dissolve >= APERTURESCIENCE.DISSOLVE_SPEED ) then
		
			APERTURESCIENCE.DISSOLVE_ENTITIES[ k ] = nil
			v:Remove()
			
		end
		
	end

end )

hook.Add( "PhysgunPickup", "GASL_DisablePhysgunPickup", function( ply, ent )
	if ( ent.GASL_Untouchable ) then return false end
end )

hook.Add( "KeyPress", "GASL_HandlePlayerJump", function( ply, key )

	if ( key != IN_JUMP || !ply:IsOnGround() ) then return end
	
	local trace = { start = ply:GetPos(), endpos = ply:GetPos() - Vector( 0, 0, 100 ), filter = ply }
	local ent = util.TraceEntity( trace, ply ).Entity
	
	if ( !ent:IsValid() ) then
		ent = APERTURESCIENCE:CheckForGel( ply:GetPos(), Vector( 0, 0, -100 ) ).Entity
	end
	-- Skip if it's not bridge or gel
	if ( !ent:IsValid() || ent:IsValid() 
		&& ( ent:GetModel() != "models/wall_projector_bridge/wall.mdl"
		&& ent:GetClass() != "ent_gel_paint" ) ) then return end
		
	if ( ent:GetModel() == "models/wall_projector_bridge/wall.mdl" ) then
		ent:EmitSound( "GASL.WallProjectorFootsteps" )
	elseif ( ent:GetClass() == "ent_gel_paint" ) then
	
		ent:EmitSound( "GASL.GelFootsteps" )
		
		if ( ent:GetGelType() == 1 ) then
			
			ply:SetVelocity( Vector( 0, 0, 400 ) )
			ply:EmitSound( "GASL.GelBounce" )
			
		end
		
	end
	
end )
