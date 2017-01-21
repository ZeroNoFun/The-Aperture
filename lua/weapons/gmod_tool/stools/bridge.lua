TOOL.Category = "Aperture science"
TOOL.Name = "Hard Light Bridge"

if ( CLIENT ) then

	language.Add( "bridge", "Hard Light Bridge" )
	language.Add( "Tool.bridge.name", "Hard Light Bridge" )
	language.Add( "Tool.bridge.desc", "Creates Hard Light Bridge" )
	language.Add( "Tool.bridge.0", "Left click to use" )
	
end //CLIENT

if SERVER then

	function TOOL:LeftClick( trace )
	
		if trace.Entity:IsNPC() then return end
		
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
	 
end // SERVER

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.hoverball.help" } )

	//CPanel:AddControl( "PropSelect", { Label = "#tool.hoverball.model", ConVar = "hoverball_model", Models = list.Get( "FaithPanelModels" ), Height = 0 } )

end

function TOOL:DrawToolScreen( width, height )

end