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

local function GASL_BuildPanel( Panel )

	Panel:ClearControls()
	
	if LocalPlayer():IsSuperAdmin() then
		
		Panel:CheckBox( "Allow Arial Faith Plate", "" )
		Panel:CheckBox( "Allow Arm Panels", "" )
		Panel:CheckBox( "Allow Fizzler", "" )
		Panel:CheckBox( "Allow Laser Field", "" )
		Panel:CheckBox( "Allow Gel Dropper", "" )
		Panel:CheckBox( "Allow Laser Emiter", "" )
		Panel:CheckBox( "Allow Hard Light Bridge", "" )
		Panel:CheckBox( "Allow Excursion Funnel", "" )
		Panel:CheckBox( "Allow Turrets", "" )
		Panel:CheckBox( "Allow Laser", "" )

	end
	
	if ( !GASL_Panel ) then
		GASL_Panel = Panel
	end
end


function GASL_SMO()

	if GASL_Panel then
		GASL_BuildPanel( GASL_Panel )
	end
	
end

hook.Add("SpawnMenuOpen","GASL_SpawnMenuOpen", GASL_SMO )

hook.Add( "PopulateToolMenu", "GASL_PopulateToolMenu", function()

	spawnmenu.AddToolMenuOption( "Utilities", "GMOD Aperture Science Laboratories", "GASLMenu", "Allowing", "", "", GASL_BuildPanel )
	
end )

/// ULX Integr 
/// Don't remove this if you not use ULX !
for name, data in pairs( hook.GetTable() ) do
	if ( name == "UCLChanged" ) then
		hook.Add( "UCLChanged", "GASL_Update", GASL_SMO )
		break
	end
end