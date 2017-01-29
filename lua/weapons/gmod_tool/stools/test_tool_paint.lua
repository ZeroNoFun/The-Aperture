TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.test_tool_paint.name"

if ( CLIENT ) then

	language.Add( "test_tool_paint", "APERTURE Paint" )
	language.Add( "tool.test_tool_paint.name", "APERTURE Paint" )
	language.Add( "tool.test_tool_paint.desc", "APERTURE Paint" )
	language.Add( "tool.test_tool_paint.0", "PAAAAAAAAAAINT" )
	
end

function TOOL:LeftClick( trace )


	if ( CLIENT ) then return true end

	local Rad = 47
	
	local ent = ents.Create( "ent_gel_paint" )
	
	local pos = WorldToLocal( trace.HitPos, Angle( ), Vector( ), trace.HitNormal:Angle() + Angle( 90, 0, 0 ) ) 
	pos = Vector( math.Round( pos.x / Rad ) * Rad, math.Round( pos.y / Rad ) * Rad, pos.z )
	pos = LocalToWorld( pos, Angle( ), Vector( ), trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
	
	ent:SetPos( pos )
	ent:SetAngles( trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
	ent:SetMoveType( MOVETYPE_NONE )
	ent:Spawn()

	return true
	
end

function TOOL:RightClick( trace )

end

local ConVarsDefault = TOOL:BuildConVarList()
