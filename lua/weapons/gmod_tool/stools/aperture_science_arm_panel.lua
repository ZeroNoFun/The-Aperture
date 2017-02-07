TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_arm_panel.name"

TOOL.ClientConVar[ "keyenable" ] = "42"
TOOL.ClientConVar[ "toggle" ] = "0"
TOOL.ClientConVar[ "startenabled" ] = "0"

if ( CLIENT ) then

	//language.Add( "aperture_science_arm_panel", "Arm Panel" )
	language.Add( "tool.aperture_science_arm_panel.name", "Arm Panel" )
	language.Add( "tool.aperture_science_arm_panel.desc", "Creates Arm Panel" )
	language.Add( "tool.aperture_science_arm_panel.tooldesc", "Makes different poses" )
	language.Add( "tool.aperture_science_arm_panel.0", "Left click to use" )
	language.Add( "tool.aperture_science_arm_panel.startenabled", "Start Enabled" )
	language.Add( "tool.aperture_science_arm_panel.enable", "Enable" )
	language.Add( "tool.aperture_science_arm_panel.toggle", "Toggle" )
	
end

function TOOL:LeftClick( trace )

	-- Ignore if place target is Alive
	if ( trace.Entity && trace.Entity:IsPlayer() && APERTURESCIENCE:IsValidEntity( trace.Entity ) ) then return false end
	
	if ( CLIENT ) then return true end
	
	local ply = self:GetOwner()
	
	local key_enable = self:GetClientNumber( "keyenable" )
	local toggle = self:GetClientNumber( "toggle" )
	local startenabled = self:GetClientNumber( "startenabled" )
	local pos = self:Convert2Grid( trace.HitPos + trace.HitNormal * 10, trace.HitNormal:Angle() + Angle( 90, 0, 0 ), 64 )
	
	MakeArmPanel( ply, pos, trace.HitNormal:Angle() + Angle( 90, 0, 0 ), startenabled, toggle, key_enable )
	
	return true
	
end

function TOOL:RightClick( trace )
	
	-- Ignore if place target is Alive
	if ( trace.Entity && trace.Entity:IsPlayer() && APERTURESCIENCE:IsValidEntity( trace.Entity ) ) then return false end

	if ( CLIENT ) then return true end
	
	if ( !self.GASL_LastPos ) then
		
		self.GASL_LastPos = trace.HitPos
		
	else
	
		local ply = self:GetOwner()
		local key_enable = self:GetClientNumber( "keyenable" )
		local toggle = self:GetClientNumber( "toggle" )
		local startenabled = self:GetClientNumber( "startenabled" )
		
		local boxSize = WorldToLocal( self.GASL_LastPos, Angle(), trace.HitPos, trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
		
		for x = 0, math.abs( math.Round( boxSize.x / 64 ) ) do
		for y = 0, math.abs( math.Round( boxSize.y / 64 ) ) do
			local vec = Vector( x * ( boxSize.x / math.abs( boxSize.x ) ), y * ( boxSize.y / math.abs( boxSize.y ) ), 0 ) * 64
			local pos = LocalToWorld( vec, Angle(), trace.HitPos + trace.HitNormal * 10, trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
			local gridPos = self:Convert2Grid( pos, trace.HitNormal:Angle() + Angle( 90, 0, 0 ), 64 )
			local arm_panel = MakeArmPanel( ply, gridPos, trace.HitNormal:Angle() + Angle( 90, 0, 0 ), startenabled, toggle, key_enable )
		end
		end
		
		self.GASL_LastPos = nil
		
	end
	
end

if ( SERVER ) then

	function MakeArmPanel( pl, pos, ang, startenabled, toggle, key_enable )
			
		local arm_panel = ents.Create( "prop_arm_panel" )
		arm_panel:SetPos( pos )
		arm_panel:SetAngles( ang )
		arm_panel:Spawn()
		
		arm_panel.NumEnableDown = numpad.OnDown( pl, key_enable, "aperture_science_arm_panel_enable", arm_panel, 1 )
		arm_panel.NumEnableUp = numpad.OnUp( pl, key_enable, "aperture_science_arm_panel_disable", arm_panel, 1 )
		
		arm_panel:SetStartEnabled( tobool( startenabled ) )
		arm_panel:ToggleEnable( false )
		arm_panel:SetToggle( tobool( toggle ) )

		undo.Create( "Arm Panel" )
			undo.AddEntity( arm_panel )
			undo.SetPlayer( pl )
		undo.Finish()
		
		return arm_panel
	end
end

function TOOL:Convert2Grid( pos, angle, rad )

	local WTL = WorldToLocal( pos, Angle( ), Vector( ), angle ) 
	WTL = Vector( math.Round( WTL.x / rad ) * rad, math.Round( WTL.y / rad ) * rad, WTL.z )
	pos = LocalToWorld( WTL, Angle( ), Vector( ), angle )
	
	return pos
	
end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.aperture_science_arm_panel.tooldesc" } )
	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_arm_panel.startenabled", Command = "aperture_science_arm_panel_startenabled" } )
	CPanel:AddControl( "Numpad", { Label = "#tool.aperture_science_arm_panel.enable", Command = "aperture_science_arm_panel_keyenable" } )
	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_arm_panel.toggle", Command = "aperture_science_arm_panel_toggle" } )

end
