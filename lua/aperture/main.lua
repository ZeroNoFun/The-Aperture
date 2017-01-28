--[[

	APERTURE API MAIN
	
]]

AddCSLuaFile( )

APERTURESCIENCE = { }

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
	
		if ( ply:GetActiveWeapon() && ply:GetActiveWeapon():GetClass() == "gmod_tool" 
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

hook.Remove( "PostDrawHUD", "GASL_HUDRender" )
