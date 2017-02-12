--[[

	GMOD APERTURE SCIENCE CONTROL PANEL
	
]]


if ( SERVER ) then return end

surface.CreateFont( "GASL_SecFont", {
	font = "Arial",
	size = 26,
	weight = 100000,
	antialias = true,
} )

local function GASL_AllowingPanel( Panel )

	Panel:ClearControls()
	
	if LocalPlayer():IsSuperAdmin() then
		
		Panel:CheckBox( "Allow Arm Panel", "aperture_science_allow_arm_panel" )
		Panel:CheckBox( "Allow Button", "aperture_science_allow_button" )
		Panel:CheckBox( "Allow Arial Faith Plate", "aperture_science_allow_catapult" )
		Panel:CheckBox( "Allow Fizzler", "aperture_science_allow_fizzler" )
		Panel:CheckBox( "Allow Item Dropper", "aperture_science_allow_item_dropper" )
		Panel:CheckBox( "Allow Laser Catcher", "aperture_science_allow_laser_catcher" )
		Panel:CheckBox( "Allow Laser Emiter", "aperture_science_allow_laser" )
		Panel:CheckBox( "Allow Laser Field", "aperture_science_allow_laser_field" )
		Panel:CheckBox( "Allow Linker", "aperture_science_allow_linker" )
		Panel:CheckBox( "Allow Gel Dropper", "aperture_science_allow_paint" )
		Panel:CheckBox( "Allow Excursion Funnel", "aperture_science_allow_tractor_beam" )
		Panel:CheckBox( "Allow Hard Light Bridge", "aperture_science_allow_wall_projector" )
		Panel:CheckBox( "Allow Turrets", "aperture_science_allow_turret" )
		Panel:CheckBox( "Allow Floor Button", "aperture_science_allow_floor_button" )

	end
	
	if ( !GASL_Panel ) then
		GASL_Panel = Panel
	end
end


function GASL_SMO()

	if GASL_Panel then
		GASL_AllowingPanel( GASL_Panel )
	end
	
end

hook.Add("SpawnMenuOpen","GASL_SpawnMenuOpen", GASL_SMO )

hook.Add( "PopulateToolMenu", "GASL_PopulateToolMenu", function()

	spawnmenu.AddToolMenuOption( "Utilities", "GMOD Aperture Science Laboratories", "GASLMenu", "Allowing", "", "", GASL_AllowingPanel )
	spawnmenu.AddToolMenuOption( "Utilities", "GMOD Aperture Science Laboratories", "GASLMenu", "Draw Settings", "", "", GASL_DrawPanel )
	
end )

/// ULX Integr 
/// Don't remove this if you not use ULX !
for name, data in pairs( hook.GetTable() ) do
	if ( name == "UCLChanged" ) then
		hook.Add( "UCLChanged", "GASL_Update", GASL_SMO )
		break
	end
end