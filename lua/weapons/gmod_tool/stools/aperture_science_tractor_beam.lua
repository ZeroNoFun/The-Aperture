TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_tractor_beam.name"

TOOL.ClientConVar[ "keyenable" ] = "45"
TOOL.ClientConVar[ "keyreverse" ] = "42"
TOOL.ClientConVar[ "toggle" ] = "0"

if ( CLIENT ) then

	language.Add( "aperture_science_tractor_beam", "Exursion Funnel" )
	language.Add( "tool.aperture_science_tractor_beam.name", "Exursion Funnel" )
	language.Add( "tool.aperture_science_tractor_beam.desc", "Creates Exursion Funnel" )
	language.Add( "tool.aperture_science_tractor_beam.0", "Left click to use" )
	language.Add( "tool.aperture_science_tractor_beam.enable", "Enable" )
	language.Add( "tool.aperture_science_tractor_beam.reverse", "Reverse" )
	language.Add( "tool.aperture_science_tractor_beam.toggle", "Toggle" )
	
end

function TOOL:LeftClick( trace )

	-- Ignore if place target is Alive
	if ( trace.Entity && trace.Entity:IsPlayer() ) then return false end
	
	if ( CLIENT ) then return true end

	local ply = self:GetOwner()
	local key_enable = self:GetClientNumber( "keyenable" )
	local key_reverse = self:GetClientNumber( "keyreverse" )
	local toggle = self:GetClientNumber( "toggle" )
	
	local tractor_beam = MakeTractorBeam( ply, trace.HitNormal:Angle(), trace.HitPos + trace.HitNormal * 31, toggle, key_enable, key_reverse )
	
	return true
	
end

if ( SERVER ) then

	function MakeTractorBeam( pl, ang, pos, toggle, key_enable, key_reverse )
		
		local tractor_beam = ents.Create( "prop_tractor_beam" )
		tractor_beam:SetPos( pos )
		tractor_beam:SetAngles( ang )
		tractor_beam:SetMoveType( MOVETYPE_NONE )
		tractor_beam:Spawn()

		tractor_beam.NumEnableDown = numpad.OnDown( pl, key_enable, "aperture_science_tractor_beam_enable", tractor_beam, 1 )
		tractor_beam.NumEnableUp = numpad.OnUp( pl, key_enable, "aperture_science_tractor_beam_disable", tractor_beam, 1 )
		tractor_beam.NumReverseDown = numpad.OnDown( pl, key_reverse, "aperture_science_tractor_beam_reverse_back", tractor_beam, 1 )
		tractor_beam.NumReverseUp = numpad.OnUp( pl, key_reverse, "aperture_science_tractor_beam_reverse_forward", tractor_beam, 1 )
		
		local toggleB
		if ( toggle == 1 ) then
			toggleB = true
		else
			toggleB = false
		end

		tractor_beam:SetToggle( toggleB )
		
		undo.Create( "Excursion Funnel" )
			undo.AddEntity( tractor_beam )
			undo.SetPlayer( pl )
		undo.Finish()
		
		return tractor_beam
		
	end
	
end

function TOOL:RightClick( trace )

end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.aperture_science_tractor_beam.desc" } )
	CPanel:AddControl( "Numpad", { Label = "#tool.aperture_science_tractor_beam.enable", Command = "aperture_science_tractor_beam_keyenable", Label2 = "#tool.aperture_science_tractor_beam.reverse", Command2 = "aperture_science_tractor_beam_keyreverse" } )
	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_tractor_beam.toggle", Command = "aperture_science_tractor_beam_toggle" } )

end