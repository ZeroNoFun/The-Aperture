TOOL.Category = "Aperture Science"
TOOL.Name = "Hard Light Bridge"

if ( CLIENT ) then

	language.Add( "aperture_science_bridge", "Hard Light Bridge" )
	language.Add( "tool.aperture_science_bridge.name", "Hard Light Bridge" )
	language.Add( "tool.aperture_science_bridge.desc", "Creates Hard Light Bridge" )
	language.Add( "tool.aperture_science_bridge.0", "Left click to use" )
	
end

function TOOL:LeftClick( trace )

	-- Ignore if place target is Alive
	if ( trace.Entity && trace.Entity:IsPlayer() ) then return false end
	
	if ( CLIENT ) then return true end
	
	ent = ents.Create( "prop_wall_projector" )
	ent:SetPos( trace.HitPos )
	ent:SetAngles( trace.HitNormal:Angle() )
	ent:SetMoveType( MOVETYPE_NONE )
	ent:Spawn()

	undo.Create( "Hard Light Bridge" )
		undo.AddEntity( ent )
		undo.SetPlayer( self:GetOwner() )
	undo.Finish()
	
	return true
	
end

function TOOL:RightClick( trace )

end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Name", { Text = "#tool.aperture_science_bridge.name", Description = "#tool.aperture_science_bridge.desc" } )

end
