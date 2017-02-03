TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_paint_dropper.name"

TOOL.ClientConVar[ "keyenable" ] = "42"
TOOL.ClientConVar[ "toggle" ] = "0"
TOOL.ClientConVar[ "gel_type" ] = "1"
TOOL.ClientConVar[ "gel_radius" ] = "50"
TOOL.ClientConVar[ "gel_randomize_size" ] = "0"
TOOL.ClientConVar[ "gel_amount" ] = "10"
TOOL.ClientConVar[ "gel_launch_speed" ] = "0"

if ( CLIENT ) then

	language.Add( "aperture_science_paint_dropper", "Gel Dropper" )
	language.Add( "tool.aperture_science_paint_dropper.name", "Gel Dropper" )
	language.Add( "tool.aperture_science_paint_dropper.desc", "Creates Gel Dropper" )
	language.Add( "tool.aperture_science_paint_dropper.0", "Left click to use" )
	language.Add( "tool.aperture_science_paint_dropper.gelType", "Gel Type" )
	language.Add( "tool.aperture_science_paint_dropper.gelRad", "Gel Radius" )
	language.Add( "tool.aperture_science_paint_dropper.gelRandomizeSize", "Gel Randomize Size" )
	language.Add( "tool.aperture_science_paint_dropper.gelAmount", "Gel Amount" )
	language.Add( "tool.aperture_science_paint_dropper.gelLaunchSpeed", "Gel Launch Speed" )
	language.Add( "tool.aperture_science_paint_dropper.enable", "Enable" )
	language.Add( "tool.aperture_science_paint_dropper.toggle", "Toggle" )
	
end

function TOOL:LeftClick( trace )

	-- Ignore if place target is Alive
	if ( trace.Entity && trace.Entity:IsPlayer() ) then return false end
	
	if ( CLIENT ) then return true end

	local ply = self:GetOwner()
	
	local key_enable = self:GetClientNumber( "keyenable" )
	local toggle = self:GetClientNumber( "toggle" )
	local gelType = self:GetClientNumber( "gel_type" )
	
	local gelRad = self:GetClientNumber( "gel_radius" )
	local gelRandomizeSize = self:GetClientNumber( "gel_randomize_size" )
	local gelAmount = self:GetClientNumber( "gel_amount" )
	local gelLaunchSpeed = self:GetClientNumber( "gel_launch_speed" )
	
	local paint_dropper = MakePaintDropper( ply, trace.HitPos, trace.HitNormal:Angle() - Angle( 90, 0, 0 ), gelType, gelRad, gelAmount, gelRandomizeSize, gelLaunchSpeed, toggle, key_enable )
	
	return true
	
end

if ( SERVER ) then

	function MakePaintDropper( pl, pos, ang, gelType, gelRad, gelAmount, gelRandomizeSize, gelLaunchSpeed, toggle, key_enable )
		
		local paint_dropper = ents.Create( "prop_gel_dropper" )
		paint_dropper:SetPos( pos )
		paint_dropper:SetAngles( ang )
		paint_dropper:SetMoveType( MOVETYPE_NONE )
		paint_dropper:Spawn()

		paint_dropper.NumEnableDown = numpad.OnDown( pl, key_enable, "aperture_science_paint_dropper_enable", paint_dropper, 1 )
		paint_dropper.NumEnableUp = numpad.OnUp( pl, key_enable, "aperture_science_paint_dropper_disable", paint_dropper, 1 )
		
		paint_dropper:SetGelType( gelType )
		paint_dropper:SetGelRadius( gelRad )
		paint_dropper:SetGelRandomizeSize( gelRandomizeSize )
		paint_dropper.GASL_GelAmount = gelAmount
		paint_dropper.GASL_GelLaunchSpeed = gelLaunchSpeed

		local toggleB
		if ( toggle == 1 ) then
			toggleB = true
		else
			toggleB = false
		end
		paint_dropper:SetToggle( toggleB )
		
		undo.Create( "Gel Dropper" )
			undo.AddEntity( paint_dropper )
			undo.SetPlayer( pl )
		undo.Finish()
		
		return paint_dropper
		
	end
	
end

function TOOL:RightClick( trace )

end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.aperture_science_paint_dropper.desc" } )

	local combobox = CPanel:ComboBox( "#tool.aperture_science_paint_dropper.gelType", "aperture_science_paint_dropper_gel_type" )
	combobox:AddChoice( "Repulsion", 1 )
	combobox:AddChoice( "Propulsion", 2 )
	combobox:AddChoice( "Conversion", 3 )
	combobox:AddChoice( "Cleansing", 4 )
	
	CPanel:NumSlider( "#tool.aperture_science_paint_dropper.gelRad", "aperture_science_paint_dropper_gel_radius", APERTURESCIENCE.GEL_MINSIZE, APERTURESCIENCE.GEL_MAXSIZE )
	CPanel:NumSlider( "#tool.aperture_science_paint_dropper.gelRandomizeSize", "aperture_science_paint_dropper_gel_randomize_size", 0, 100 )
	CPanel:NumSlider( "#tool.aperture_science_paint_dropper.gelAmount", "aperture_science_paint_dropper_gel_amount", 1, 100 )
	CPanel:NumSlider( "#tool.aperture_science_paint_dropper.gelLaunchSpeed", "aperture_science_paint_dropper_gel_launch_speed", 0, 1000 )

	CPanel:AddControl( "Numpad", { Label = "#tool.aperture_science_paint_dropper.enable", Command = "aperture_science_paint_dropper_keyenable" } )
	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_paint_dropper.toggle", Command = "aperture_science_paint_dropper_toggle" } )

end