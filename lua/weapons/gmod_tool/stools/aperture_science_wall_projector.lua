TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_wall_projector.name"

TOOL.ClientConVar[ "keyenable" ] = "42"
TOOL.ClientConVar[ "toggle" ] = "0"
TOOL.ClientConVar[ "startenabled" ] = "0"

if ( CLIENT ) then

	//language.Add( "aperture_science_wall_projector", "Hard Light Bridge" )
	language.Add( "tool.aperture_science_wall_projector.name", "Hard Light Bridge" )
	language.Add( "tool.aperture_science_wall_projector.desc", "Creates Hard Light Bridge" )
	language.Add( "tool.aperture_science_wall_projector.tooldesc", "Makes Bridges when enabled" )
	language.Add( "tool.aperture_science_wall_projector.0", "Left click to use" )
	language.Add( "tool.aperture_science_wall_projector.startenabled", "Start Enabled" )
	language.Add( "tool.aperture_science_wall_projector.enable", "Enable" )
	language.Add( "tool.aperture_science_wall_projector.toggle", "Toggle" )
	
end

function TOOL:LeftClick( trace )

	-- Ignore if place target is Alive
	if ( trace.Entity && trace.Entity:IsPlayer() ) then return false end
	
	if ( CLIENT ) then return true end
	
	local ply = self:GetOwner()
	
	local key_enable = self:GetClientNumber( "keyenable" )
	local toggle = self:GetClientNumber( "toggle" )
	local startenabled = self:GetClientNumber( "startenabled" )
	
	MakeWallProjector( ply, trace.HitPos, trace.HitNormal:Angle(), startenabled, toggle, key_enable )
	
	return true
	
end

if ( SERVER ) then

	function MakeWallProjector( pl, pos, ang, startenabled, toggle, key_enable )
			
		local wall_projector = ents.Create( "prop_wall_projector" )
		wall_projector:SetPos( pos )
		wall_projector:SetAngles( ang )
		wall_projector:Spawn()
		
		wall_projector.NumEnableDown = numpad.OnDown( pl, key_enable, "aperture_science_wall_projector_enable", wall_projector, 1 )
		wall_projector.NumEnableUp = numpad.OnUp( pl, key_enable, "aperture_science_wall_projector_disable", wall_projector, 1 )
		
		wall_projector:SetStartEnabled( tobool( startenabled ) )
		wall_projector:ToggleEnable( false )
		wall_projector:SetToggle( tobool( toggle ) )

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
	CPanel:AddControl( "Numpad", { Label = "#tool.aperture_science_wall_projector.enable", Command = "aperture_science_wall_projector_keyenable" } )
	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_wall_projector.toggle", Command = "aperture_science_wall_projector_toggle" } )

end
