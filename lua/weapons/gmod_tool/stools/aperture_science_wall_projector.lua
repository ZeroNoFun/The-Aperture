TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_wall_projector.name"

TOOL.ClientConVar[ "startenabled" ] = "0"

if ( CLIENT ) then

	//language.Add( "aperture_science_wall_projector", "Hard Light Bridge" )
	language.Add( "tool.aperture_science_wall_projector.name", "Hard Light Bridge" )
	language.Add( "tool.aperture_science_wall_projector.desc", "Creates Hard Light Bridge" )
	language.Add( "tool.aperture_science_wall_projector.tooldesc", "Makes Bridges when enabled" )
	language.Add( "tool.aperture_science_wall_projector.0", "Left click to use" )
	language.Add( "tool.aperture_science_wall_projector.startenabled", "Start Enabled" )
	
end

function TOOL:LeftClick( trace )

	-- Ignore if place target is Alive
	if ( trace.Entity && trace.Entity:IsPlayer() ) then return false end
	
	if ( CLIENT ) then return true end

	if ( !APERTURESCIENCE.ALLOWING.wall_projector && !self:GetOwner():IsSuperAdmin() ) then MsgC( Color( 255, 0, 0 ), "This tool is disabled" ) return end
	
	local ply = self:GetOwner()
	local startenabled = self:GetClientNumber( "startenabled" )
	
	MakeWallProjector( ply, trace.HitPos, trace.HitNormal:Angle(), startenabled )
	
	return true
	
end

if ( SERVER ) then

	function MakeWallProjector( pl, pos, ang, startenabled )
		
		local wall_projector = ents.Create( "ent_wall_projector" )
		wall_projector:SetPos( pos )
		wall_projector:SetAngles( ang )
		wall_projector:Spawn()
		
		wall_projector:SetStartEnabled( tobool( startenabled ) )
		wall_projector:ToggleEnable( false )
		
		undo.Create( "Hard Light Bridge" )
			undo.AddEntity( wall_projector )
			undo.SetPlayer( pl )
		undo.Finish()
		
		return true
	end
end

function TOOL:RightClick( trace )

end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.aperture_science_wall_projector.tooldesc" } )
	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_wall_projector.startenabled", Command = "aperture_science_wall_projector_startenabled" } )

end
