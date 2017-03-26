TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_arm_panel.name"

TOOL.ClientConVar[ "startenabled" ] = "0"
TOOL.ClientConVar[ "armangle" ] = "0"
TOOL.ClientConVar[ "armforward" ] = "-45"
TOOL.ClientConVar[ "armup" ] = "100"

if ( CLIENT ) then

	//language.Add( "aperture_science_arm_panel", "Arm Panel" )
	language.Add( "tool.aperture_science_arm_panel.name", "Arm Panel" )
	language.Add( "tool.aperture_science_arm_panel.desc", "Creates Arm Panel" )
	language.Add( "tool.aperture_science_arm_panel.tooldesc", "Makes different poses" )
	language.Add( "tool.aperture_science_arm_panel.0", "Left click to use" )
	language.Add( "tool.aperture_science_arm_panel.startenabled", "Start Enabled" )
	language.Add( "tool.aperture_science_arm_panel.armangle", "Arm Angle" )
	language.Add( "tool.aperture_science_arm_panel.armforward", "Arm Forward" )
	language.Add( "tool.aperture_science_arm_panel.armup", "Arm Up" )

end

function TOOL:LeftClick( trace )
	
	if ( CLIENT ) then return true end

	if ( !IsValid( self.GASL_ArmPanel ) ) then
	
		-- Ignore if place target is Alive
		if ( trace.Entity && ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() || APERTURESCIENCE:IsValidEntity( trace.Entity ) ) ) then return false end

		if ( !APERTURESCIENCE.ALLOWING.arm_panel && !self:GetOwner():IsSuperAdmin() ) then self:GetOwner():PrintMessage( HUD_PRINTTALK, "This tool is disabled" ) return end
		
		local ply = self:GetOwner()
		
		local startenabled = self:GetClientNumber( "startenabled" )
		local armangle = math.max( -90, math.min( 90, self:GetClientNumber( "armangle" ) ) )
		local armforward = math.max( -100, math.min( 100, self:GetClientNumber( "armforward" ) ) )
		local armup = math.max( 0, math.min( 140, self:GetClientNumber( "armup" ) ) )
		local pos = APERTURESCIENCE:ConvertToGridWithoutZ( trace.HitPos + trace.HitNormal * 70, trace.HitNormal:Angle() + Angle( 90, 0, 0 ), APERTURESCIENCE.GRID_SIZE )
		
		local arm_panel = MakeArmPanel( ply, pos, trace.HitNormal:Angle() + Angle( 90, 0, 0 ), startenabled, armangle, armforward, armup )
		local normal = trace.HitNormal
		normal = Vector( math.Round( normal.x ), math.Round( normal.y ), math.Round( normal.z ) )
		
		undo.Create( "Arm Panel" )
			undo.AddEntity( arm_panel )
			undo.SetPlayer( ply )
		undo.Finish()
		
		if ( normal == Vector( 0, 0, 1 ) || normal == Vector( 0, 0, -1 ) ) then
		
			self.GASL_ArmPanel = arm_panel
			self.GASL_ArmPanelPos = trace.HitPos
			self.GASL_ArmPanelNormal = trace.HitNormal
			
		end
		
	else
	
		self.GASL_ArmPanel = NULL
	
	end
	
	return true
	
end

function TOOL:RightClick( trace )
	
	-- Ignore if place target is Alive
	if ( CLIENT ) then return true end
	if ( trace.Entity && ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() || APERTURESCIENCE:IsValidEntity( trace.Entity ) ) ) then return false end
	if ( !self.GASL_LastPos ) then
		if ( !APERTURESCIENCE.ALLOWING.arm_panel && !self:GetOwner():IsSuperAdmin() ) then self:GetOwner():PrintMessage( HUD_PRINTTALK, "This tool is disabled" ) return end
		self.GASL_LastPos = trace.HitPos
	else
		local ply = self:GetOwner()
		local startenabled = self:GetClientNumber( "startenabled" )
		local armangle = math.max( -90, math.min( 90, self:GetClientNumber( "armangle" ) ) )
		local armforward = math.max( -100, math.min( 100, self:GetClientNumber( "armforward" ) ) )
		local armup = math.max( 0, math.min( 140, self:GetClientNumber( "armup" ) ) )
		local boxSize = WorldToLocal( self.GASL_LastPos, Angle(), trace.HitPos, trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
		local Panels = { }
		
		for x = 0, math.abs( math.Round( boxSize.x / 64 ) ) do
		for y = 0, math.abs( math.Round( boxSize.y / 64 ) ) do
			local vec = Vector( x * ( boxSize.x / math.abs( boxSize.x ) ), y * ( boxSize.y / math.abs( boxSize.y ) ), 0 ) * 64
			local pos = LocalToWorld( vec, Angle(), trace.HitPos + trace.HitNormal * 10, trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
			local gridPos = APERTURESCIENCE:ConvertToGridWithoutZ( pos, trace.HitNormal:Angle() + Angle( 90, 0, 0 ), 64 )
			local arm_panel = MakeArmPanel( ply, gridPos + trace.HitNormal * 70, trace.HitNormal:Angle() + Angle( 90, 0, 0 ), startenabled, armangle, armforward, armup )
			table.insert( Panels, table.Count( Panels ) + 1, arm_panel )
		end
		end
		
		undo.Create( "Arm Panels" )
			for _, k in pairs( Panels ) do undo.AddEntity( k ) end
			undo.SetPlayer( ply )
		undo.Finish()
		
		self.GASL_LastPos = nil
	end
	
end

if ( SERVER ) then

	function MakeArmPanel( pl, pos, ang, startenabled, armang, armforward, armup )
		
		local arm_panel = ents.Create( "ent_arm_panel" )
		arm_panel:SetPos( pos )
		arm_panel:SetAngles( ang )
		arm_panel:Spawn()
		arm_panel:SetArmPos( Vector( -30 + armforward, 0, 45 + armup ) )
		arm_panel:SetArmAng( Angle( armang, 0, 0 ) )
		if ( tobool( startenabled ) ) then arm_panel:ToggleEnable( true ) end
		
		return arm_panel
	end
end

function TOOL:UpdateGhostArmPanel( ent, ply )

	if ( !IsValid( ent ) ) then return end

	local trace = ply:GetEyeTrace()

	if ( !trace.Hit || trace.Entity && ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() || APERTURESCIENCE:IsValidEntity( trace.Entity ) ) ) then

		ent:SetNoDraw( true )
		return

	end
	
	local CurPos = ent:GetPos()
	
	local ang = trace.HitNormal:Angle() + Angle( 0, 0, 0 )
	local pos = APERTURESCIENCE:ConvertToGridWithoutZ( trace.HitPos + trace.HitNormal * 70, trace.HitNormal:Angle() + Angle( 90, 0, 0 ), 64 )

	ent:SetPos( pos + trace.HitNormal:Angle():Up() * 30 )
	ent:SetAngles( ang )
	ent:SetNoDraw( false )

end

function TOOL:Think()

	if ( SERVER ) then
	
		if ( IsValid( self.GASL_ArmPanel ) ) then
			
			local aimPos = self:GetOwner():GetEyeTrace().HitPos
			local localAng = Angle( )
			
			if ( aimPos:Distance( self.GASL_ArmPanel:GetPos() ) > 100 ) then
				local localAimPos = WorldToLocal( self.GASL_ArmPanelPos, self.GASL_ArmPanelNormal:Angle() + Angle( 90, 0, 0 ), aimPos, Angle() )
				localAng = localAimPos:Angle()
				localAng = Angle( 0, math.Round( localAng.y / 90 ) * 90 + 180, 0 )
			else
				localAng = Angle( )
			end
			
			self.GASL_ArmPanel:SetAngles( self.GASL_ArmPanelNormal:Angle() + Angle( 90, localAng.y, 0 ) )
		end
		
	end

	local mdl = "models/anim_wp/arm_panel/arm_panel.mdl"
	if ( !util.IsValidModel( mdl ) ) then self:ReleaseGhostEntity() return end

	if ( !IsValid( self.GhostEntity ) || self.GhostEntity:GetModel() != mdl ) then
		self:MakeGhostEntity( mdl, Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
	end

	self:UpdateGhostArmPanel( self.GhostEntity, self:GetOwner() )

end


local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.aperture_science_arm_panel.tooldesc" } )
	CPanel:NumSlider( "#tool.aperture_science_arm_panel.armangle", "aperture_science_arm_panel_armangle", -90, 90 )
	CPanel:NumSlider( "#tool.aperture_science_arm_panel.armforward", "aperture_science_arm_panel_armforward", -100, 100 )
	CPanel:NumSlider( "#tool.aperture_science_arm_panel.armup", "aperture_science_arm_panel_armup", 0, 140 )
	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_arm_panel.startenabled", Command = "aperture_science_arm_panel_startenabled" } )

end
