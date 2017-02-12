TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_tractor_beam.name"

TOOL.ClientConVar[ "startenabled" ] = "0"
TOOL.ClientConVar[ "startreversed" ] = "0"

if ( CLIENT ) then

	language.Add( "aperture_science_tractor_beam", "Exursion Funnel" )
	language.Add( "tool.aperture_science_tractor_beam.name", "Exursion Funnel" )
	language.Add( "tool.aperture_science_tractor_beam.desc", "Creates Exursion Funnel" )
	language.Add( "tool.aperture_science_tractor_beam.0", "Left click to use" )
	language.Add( "tool.aperture_science_tractor_beam.enable", "Enable" )
	language.Add( "tool.aperture_science_tractor_beam.reverse", "Reverse" )
	language.Add( "tool.aperture_science_tractor_beam.startenabled", "Start Enabled" )
	language.Add( "tool.aperture_science_tractor_beam.startreversed", "Start Reversed" )
	language.Add( "tool.aperture_science_tractor_beam.toggle", "Toggle" )
	
end

function TOOL:LeftClick( trace )

	-- Ignore if place target is Alive
	if ( trace.Entity && trace.Entity:IsPlayer() ) then return false end
	
	if ( CLIENT ) then return true end
	
	if ( !APERTURESCIENCE.ALLOWING.tractor_beam && !self:GetOwner():IsSuperAdmin() ) then MsgC( Color( 255, 0, 0 ), "This tool is disabled" ) return end

	local ply = self:GetOwner()
	local startenabled = self:GetClientNumber( "startenabled" )
	local startreverse = self:GetClientNumber( "startreversed" )
	
	local tractor_beam = MakeTractorBeam( ply, trace.HitNormal:Angle(), trace.HitPos + trace.HitNormal * 31, startenabled, startreverse, toggle, key_enable, key_reverse )
	
	return true
	
end

if ( SERVER ) then

	function MakeTractorBeam( pl, ang, pos, startenabled, startreverse )
		
		local tractor_beam = ents.Create( "ent_tractor_beam" )
		tractor_beam:SetPos( pos )
		tractor_beam:SetAngles( ang )
		tractor_beam:SetMoveType( MOVETYPE_NONE )
		tractor_beam:Spawn()

		tractor_beam:SetStartEnabled( tobool( startenabled ) )
		tractor_beam:ToggleEnable( false )
		tractor_beam:SetStartReversed( tobool( startreverse ) )
		tractor_beam:ToggleReverse( false )
		
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
	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_tractor_beam.startenabled", Command = "aperture_science_tractor_beam_startenabled" } )
	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_tractor_beam.startreversed", Command = "aperture_science_tractor_beam_startreversed" } )

end