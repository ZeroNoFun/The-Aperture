--[[

	APERTURE API MAIN
	
]]

AddCSLuaFile( )

APERTURESCIENCE = { }

include( "aperture/sounds/tractor_beam_sounds.lua" )

function APERTURESCIENCE:PlaySequence( self, seq, rate )

	if ( !self:IsValid() ) then return end
	
	local sequence = self:LookupSequence( seq )
	self:ResetSequence( sequence )

	self:SetPlaybackRate( rate )
	self:SetSequence( sequence )
	
	return self:SequenceDuration( sequence )
	
end

function APERTURESCIENCE:CalcBezierCurvePoint( startpos, middlepos, endpos )

	local points = { }
	
	table.insert( points, table.Count( points ) + 1, startpos )

	for inx = 1, 10 do

		local i = inx / 10
		
		local NX = math.pow( 1 - i, 2 ) * startpos.x + 2 * i * ( 1 - i ) * middlepos.x + math.pow( i, 2 ) * endpos.x
		local NY = math.pow( 1 - i, 2 ) * startpos.y + 2 * i * ( 1 - i ) * middlepos.y + math.pow( i, 2 ) * endpos.y
		local NZ = math.pow( 1 - i, 2 ) * startpos.z + 2 * i * ( 1 - i ) * middlepos.z + math.pow( i, 2 ) * endpos.z
		
		table.insert( points, table.Count( points ) + 1, Vector( NX, NY, NZ ) )
		
	end
	
	return points
	
end

hook.Add( "PostDrawOpaqueRenderables", "GASL_HUDRender", function()

	for k, ply in pairs( player.GetAll() ) do
		
		if ( ply:GetActiveWeapon() && ply:GetActiveWeapon():GetClass() == "gmod_tool" && ply:GetTool( "aperture_science_catapult" ).Mode == "aperture_science_catapult" ) then
			
			for i, catapult in pairs( ents.FindByClass( "prop_catapult" ) ) do
				
				local tool = ply:GetTool( "aperture_science_catapult" )
				
				-- Draw trajectory if Player aim on Faith Plate or if it allready selected
				if ( tool.Selected && tool.Selected == catapult || ply:GetEyeTrace().HitPos:Distance( catapult:GetPos() ) < 100 ) then
				
					if ( catapult:GetLandPoint() == Vector() || catapult:GetLaunchHeight() == 0 ) then continue end
					
					local startpos = catapult:GetPos()
					local middlepos = ( catapult:GetLandPoint() + catapult:GetPos() ) / 2 + Vector( 0, 0, catapult:GetLaunchHeight() )
					local endpos = catapult:GetLandPoint()
					local points = APERTURESCIENCE:CalcBezierCurvePoint( startpos, middlepos, endpos )
					
					render.SetMaterial( Material( "cable/xbeam" ) )
					render.StartBeam( table.Count( points ) )
					
					for inx, point in pairs( points ) do
						
						render.AddBeam( point, 10, 1, Color( 255, 255, 255 ) ) 
						
					end
					
					render.EndBeam() 
					
					render.SetMaterial( Material( "effects/select_dot" ) )
					render.DrawQuadEasy( points[ table.Count( points ) ], Vector( 0, 0, 1 ), 32, 32, Color( 255, 255, 255, 200 ), ( CurTime() * 50 ) % 360 )

				end
			end
		end
	end
end )

hook.Remove( "PostDrawOpaqueRenderables", "GASL_HUDRender" )
