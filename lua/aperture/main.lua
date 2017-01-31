--[[

	APERTURE API MAIN
	
]]

AddCSLuaFile( )

APERTURESCIENCE = { }

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

include( "aperture/sounds/gel_sounds.lua" )
include( "aperture/sounds/tractor_beam_sounds.lua" )
include( "aperture/sounds/catapult_sounds.lua" )

function APERTURESCIENCE:PlaySequence( self, seq, rate )

	if ( !self:IsValid() ) then return end
	
	local sequence = self:LookupSequence( seq )
	self:ResetSequence( sequence )

	self:SetPlaybackRate( rate )
	self:SetSequence( sequence )
	
	return self:SequenceDuration( sequence )
	
end

function APERTURESCIENCE:IsValidEntity( ent )

	if ( ent:IsValid()
		&& ent:GetClass() != "ent_gel_paint" 
		&& ent:GetClass() != "ent_gel_puddle"
		&& ent:GetClass() != "prop_gel_dropper"
		&& ent:GetClass() != "prop_tractor_beam"
		&& ent:GetClass() != "prop_wall_projector"
		&& ent:GetClass() != "prop_catapult" ) then 
		return true
	end
	
	return false
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

hook.Add( "PreDrawHUD", "GASL_HUDRender", function()

	cam.Start3D()
	
		local ply = LocalPlayer()
	
		if ( ply:GetActiveWeapon():IsValid() && ply:GetActiveWeapon():GetClass() == "gmod_tool" 
			&& ply:GetTool() && ply:GetTool().Mode && ply:GetTool().Mode == "aperture_science_catapult" ) then

			for i, catapult in pairs( ents.FindByClass( "prop_catapult" ) ) do
				
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
				local points, length = APERTURESCIENCE:CalcBezierCurvePoint( startpos, middlepos + Vector( 0, 0, height * 2 ), endpos, 10 )
				local prevBeamPos = points[ 1 ]

				-- Drawing land target
				render.SetMaterial( Material( "effects/wheel_ring" ) )
				render.DrawQuadEasy( catapult:GetPos(), catapult:GetUp(), 200, 200, Color( 255, 255, 255 ), 0 )
				
				-- Drawing land target
				render.SetMaterial( Material( "signage/mgf_overlay_bullseye" ) )
				render.DrawQuadEasy( endpos, Vector( 0, 0, 1 ), 80, 80, Color( 255, 255, 255 ), 0 )

				-- Drawing trajectory
				render.SetMaterial( Material( "effects/trajectory_path" ) )
				for inx, point in pairs( points ) do
				
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

hook.Add( "Think", "GASL_HandlingGel", function()

	if ( CLIENT ) then return end
	
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
		
			if ( ( !ply.GASL_LastTimeOnGel || ply.GASL_LastTimeOnGel && CurTime() > ply.GASL_LastTimeOnGel + 0.25 ) ) then
			
				if ( gel:GetGelType() == 1 ) then
					ply:EmitSound( "GASL.GelBounceEnter" )
				end
				
				if ( gel:GetGelType() == 2 ) then
					ply:EmitSound( "GASL.GelSpeedEnter" )
				end

				ply.GASL_LastStandingGelType = gel:GetGelType()
				
			end
			
			ply.GASL_LastTimeOnGel = CurTime()
		
		end
		
		-- if player hit repulsion gel
		if ( gel:GetGelType() == 1 && !ply:KeyDown( IN_DUCK ) ) then
		
			local plyVelocity = ply:GetVelocity()
			
			-- skip if player stand on the ground
			if ( ply:IsOnGround() && !ply:KeyDown( IN_JUMP ) ) then continue end
			
			local WTL = WorldToLocal( gel:GetPos() + plyVelocity, Angle( ), gel:GetPos(), gel:GetAngles() )
			WTL = Vector( 0, 0, math.max( -WTL.z, 400 ) * 2 )
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

			ply:SetVelocity( Vector( ply.GASL_GelPlayerVelocity.x, ply.GASL_GelPlayerVelocity.y, 0 ) / 2 )
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
			
			if ( dir:Length() < 50 ) then
			
				if ( dir == Vector() ) then dir = Vector( 0, 0, -1 ) end
				dir = dir:GetNormalized() * 50
				
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

end )

local function PlayerPickup( ply, ent )
	if ( ent.GASL_Untouchable ) then return false end
end
hook.Add( "PhysgunPickup", "Allow Player Pickup", PlayerPickup )
