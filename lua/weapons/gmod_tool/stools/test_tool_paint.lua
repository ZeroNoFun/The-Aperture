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
	
	local ent = ents.Create( "ent_gel_puddle" )
	ent:SetPos( trace.HitPos + trace.HitNormal * 100 )
	ent:SetMoveType( MOVETYPE_NONE )
	ent:Spawn()
	ent:GetPhysicsObject():EnableCollisions( false )
	ent:GetPhysicsObject():Wake()
	ent:GetPhysicsObject():SetVelocity( Vector( 0, 0, -100 ) )
	
	ent.GASL_GelSplatRadius = 80
	ent.GASL_GelType = 1

	local color = Color( 0, 0, 0 )
	if ( ent.GASL_GelType == 1 ) then color = APERTURESCIENCE.GEL_BOUNCE_COLOR end
	if ( ent.GASL_GelType == 2 ) then color = APERTURESCIENCE.GEL_SPEED_COLOR end
	ent:SetColor( color )
	
	return true
	
end

function TOOL:RightClick( trace )

	if ( CLIENT ) then return true end
	
	local ent = ents.Create( "ent_gel_puddle" )
	ent:SetPos( trace.HitPos + trace.HitNormal * 100 )
	ent:SetMoveType( MOVETYPE_NONE )
	ent:Spawn()
	ent:GetPhysicsObject():Wake()
	ent:GetPhysicsObject():SetVelocity( Vector( 0, 0, -100 ) )
	
	ent.GASL_GelSplatRadius = 80
	ent.GASL_GelType = 2
	
	local color = Color( 0, 0, 0 )
	if ( ent.GASL_GelType == 1 ) then color = APERTURESCIENCE.GEL_BOUNCE_COLOR end
	if ( ent.GASL_GelType == 2 ) then color = APERTURESCIENCE.GEL_SPEED_COLOR end
	ent:SetColor( color )

	return true
end

local ConVarsDefault = TOOL:BuildConVarList()
