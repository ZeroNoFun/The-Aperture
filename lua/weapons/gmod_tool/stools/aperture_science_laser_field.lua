TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_laser_field.name"

TOOL.ClientConVar[ "model" ] = "models/props/fizzler.mdl"
TOOL.ClientConVar[ "maxrad" ] = "20"
TOOL.ClientConVar[ "keyenable" ] = "45"
TOOL.ClientConVar[ "toggle" ] = "0"
TOOL.ClientConVar[ "startenabled" ] = "0"

if ( CLIENT ) then

	language.Add( "aperture_science_laser_field", "Laser Field" )
	language.Add( "tool.aperture_science_laser_field.name", "Laser Field" )
	language.Add( "tool.aperture_science_laser_field.desc", "Creates Laser Field" )
	language.Add( "tool.aperture_science_laser_field.0", "Left click to use" )
	language.Add( "tool.aperture_science_laser_field.enable", "Enable" )
	language.Add( "tool.aperture_science_laser_field.startenabled", "Start Enabled" )
	language.Add( "tool.aperture_science_laser_field.toggle", "Toggle" )
	language.Add( "tool.aperture_science_laser_field.maxrad", "Maximum Length" )
	
end

function TOOL:LeftClick( trace )

	-- Ignore if place target is Alive
	if ( trace.Entity && ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() || APERTURESCIENCE:IsValidEntity( trace.Entity ) ) ) then return false end
	
	if ( CLIENT ) then return true end
	
	local ply = self:GetOwner()
	local model = self:GetClientInfo( "model" )
	local maxrad = self:GetClientNumber( "maxrad" )
	local toggle = self:GetClientNumber( "toggle" )
	local keyenable = self:GetClientNumber( "keyenable" )
	local startenabled = self:GetClientNumber( "startenabled" )
	local angle = trace.HitNormal:Angle()

	local firstLaserField = MakeLaserField( ply, model, angle, -90, trace.HitPos, startenabled, toggle, keyenable )

	trace = util.QuickTrace( firstLaserField:GetPos(), -firstLaserField:GetRight() * maxrad, firstLaserField )

	local secondLaserField = MakeLaserField( ply, model, angle, 90, trace.HitPos, startenabled, toggle, keyenable )

	local Angles = APERTURESCIENCE:FizzlerModelToInfo( firstLaserField ).angle
	firstLaserField:SetAngles( firstLaserField:LocalToWorldAngles( Angles ) )
	secondLaserField:SetAngles( secondLaserField:LocalToWorldAngles( Angles ) )

	firstLaserField:SetNWEntity( "GASL_ConnectedField", secondLaserField )
	secondLaserField:SetNWEntity( "GASL_ConnectedField", firstLaserField )
	
	constraint.Weld( secondLaserField, firstLaserField, 0, 0, 0, true, true )

	undo.Create( "LaserField" )
		undo.AddEntity( firstLaserField )
		undo.AddEntity( secondLaserField )
		undo.SetPlayer( ply )
	undo.Finish()
	
	return true
	
end

if ( SERVER ) then

	function MakeLaserField( pl, model, ang, addAng, pos, startenabled, toggle, key_enable )
		
		local laserField = ents.Create( "ent_laser_field" )
		laserField:SetPos( pos )
		laserField:SetAngles( ang )
		laserField:SetAngles( laserField:LocalToWorldAngles( Angle( 0, addAng, 0 ) ) )
		laserField:SetModel( model )
		laserField:SetMoveType( MOVETYPE_NONE )
		laserField:Spawn()
		laserField:SetSkin( 2 )

		laserField.NumEnableDown = numpad.OnDown( pl, key_enable, "aperture_science_fizzler_enable", laserField, 1 )
		laserField.NumEnableUp = numpad.OnUp( pl, key_enable, "aperture_science_fizzler_disable", laserField, 1 )
		
		laserField:SetStartEnabled( tobool( startenabled ) )
		laserField:ToggleEnable( false )
		laserField:SetToggle( tobool( toggle ) )
		
		return laserField
		
	end
	
end

function TOOL:GetPlacingHeight( laserField )

	local owner = self:GetOwner()
	local angle = laserField:WorldToLocalAngles( owner:EyeAngles() )
	
	local vector = laserField:WorldToLocal( owner:GetShootPos() )
	local playerToLaserFieldDist = Vector( vector.x, 0, vector.z ):Length()
	
	local height = playerToLaserFieldDist * math.tan( -angle.yaw * math.pi / 180 ) + vector.y
	
	return height
	
end

function TOOL:UpdateGhostLaserField( ent, ply )

	if ( !IsValid( ent ) ) then return end

	local trace = ply:GetEyeTrace()
	if ( !trace.Hit || trace.Entity && ( trace.Entity:GetClass() == "ent_laser_field" || trace.Entity:IsPlayer() ) ) then
		ent:SetNoDraw( true )
		return
	end
	
	local CurPos = ent:GetPos()
	local ang = trace.HitNormal:Angle()
	local pos = trace.HitPos
	local skip, rAng = LocalToWorld( Vector(), Angle( 0, -90, 0 ), Vector(), ang )

	ent:SetPos( pos )
	ent:SetAngles( rAng )

	ent:SetNoDraw( false )

end

function TOOL:Think()

	local mdl = self:GetClientInfo( "model" )
	if ( !util.IsValidModel( mdl ) ) then self:ReleaseGhostEntity() return end

	if ( !IsValid( self.GhostEntity ) || self.GhostEntity:GetModel() != mdl ) then
		self:MakeGhostEntity( mdl, Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
	end

	self:UpdateGhostLaserField( self.GhostEntity, self:GetOwner() )

end

function TOOL:RightClick( trace )

end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.aperture_science_laser_field.desc" } )
	CPanel:NumSlider( "#tool.aperture_science_laser_field.maxrad", "aperture_science_laser_field_maxrad", 80, 1000 )
	CPanel:AddControl( "PropSelect", { ConVar = "aperture_science_laser_field_model", Models = list.Get( "LaserFieldModels" ), Height = 1 } )
	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_laser_field.startenabled", Command = "aperture_science_laser_field_startenabled" } )
	CPanel:AddControl( "Numpad", { Label = "#tool.aperture_science_laser_field.enable", Command = "aperture_science_laser_field_keyenable" } )
	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_laser_field.toggle", Command = "aperture_science_laser_field_toggle" } )

end

list.Set( "LaserFieldModels", "models/props/fizzler_dynamic.mdl", {} )
list.Set( "LaserFieldModels", "models/props_underground/underground_fizzler_wall.mdl", {} )