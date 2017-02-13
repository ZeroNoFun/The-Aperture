TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_fizzler.name"

TOOL.ClientConVar[ "model" ] = "models/props/fizzler.mdl"
TOOL.ClientConVar[ "maxrad" ] = "20"
TOOL.ClientConVar[ "startenabled" ] = "0"

if ( CLIENT ) then

	language.Add( "aperture_science_fizzler", "Fizzler" )
	language.Add( "tool.aperture_science_fizzler.name", "Fizzler" )
	language.Add( "tool.aperture_science_fizzler.desc", "Creates Fizzler" )
	language.Add( "tool.aperture_science_fizzler.0", "Left click to use" )
	language.Add( "tool.aperture_science_fizzler.startenabled", "Start Enabled" )
	language.Add( "tool.aperture_science_fizzler.maxrad", "Maximum Length" )
	
end

function TOOL:LeftClick( trace )

	-- Ignore if place target is Alive
	if ( trace.Entity && ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() || APERTURESCIENCE:IsValidEntity( trace.Entity ) ) ) then return false end
	
	if ( CLIENT ) then return true end
	
	if ( !APERTURESCIENCE.ALLOWING.fizzler && !self:GetOwner():IsSuperAdmin() ) then self:GetOwner():PrintMessage( HUD_PRINTTALK, "This tool is disabled" ) return end

	local ply = self:GetOwner()
	local model = self:GetClientInfo( "model" )
	local maxrad = self:GetClientNumber( "maxrad" )
	local toggle = self:GetClientNumber( "toggle" )
	local keyenable = self:GetClientNumber( "keyenable" )
	local startenabled = self:GetClientNumber( "startenabled" )
	local angle = trace.HitNormal:Angle()

	local firstFizzler = MakeFizzler( ply, model, angle, -90, trace.HitPos, startenabled, toggle, keyenable )

	trace = util.QuickTrace( firstFizzler:GetPos(), -firstFizzler:GetRight() * maxrad, firstFizzler )

	local secondFizzler = MakeFizzler( ply, model, angle, 90, trace.HitPos, startenabled, toggle, keyenable )
	
	firstFizzler:SetNWEntity( "GASL_ConnectedField", secondFizzler )
	secondFizzler:SetNWEntity( "GASL_ConnectedField", firstFizzler )

	constraint.Weld( secondFizzler, firstFizzler, 0, 0, 0, true, true )

	undo.Create( "Fizzler" )
		undo.AddEntity( firstFizzler )
		undo.AddEntity( secondFizzler )
		undo.SetPlayer( ply )
	undo.Finish()
	
	return true
	
end

if ( SERVER ) then

	function MakeFizzler( pl, model, ang, addAng, pos, startenabled, toggle, key_enable )
		
		local fizzler = ents.Create( "ent_fizzler" )
		fizzler:SetPos( pos )
		fizzler:SetAngles( ang )
		fizzler:SetModel( model )
		fizzler:SetAngles( fizzler:LocalToWorldAngles( Angle( 0, addAng, 0 ) ) )
		fizzler:SetMoveType( MOVETYPE_NONE )
		fizzler:Spawn()

		fizzler.NumEnableDown = numpad.OnDown( pl, key_enable, "aperture_science_fizzler_enable", fizzler, 1 )
		fizzler.NumEnableUp = numpad.OnUp( pl, key_enable, "aperture_science_fizzler_disable", fizzler, 1 )
		
		fizzler:SetStartEnabled( tobool( startenabled ) )
		fizzler:ToggleEnable( false )
		fizzler:SetToggle( tobool( toggle ) )
		
		return fizzler
		
	end
	
end

function TOOL:GetPlacingHeight( fizzler )

	local owner = self:GetOwner()
	local angle = fizzler:WorldToLocalAngles( owner:EyeAngles() )
	
	local vector = fizzler:WorldToLocal( owner:GetShootPos() )
	local playerToFizzlerDist = Vector( vector.x, 0, vector.z ):Length()
	
	local height = playerToFizzlerDist * math.tan( -angle.yaw * math.pi / 180 ) + vector.y
	
	return height
	
end

function TOOL:UpdateGhostFizzler( ent, ply )

	if ( !IsValid( ent ) ) then return end

	local trace = ply:GetEyeTrace()
	if ( !trace.Hit || trace.Entity && ( trace.Entity:GetClass() == "ent_fizzler" || trace.Entity:IsNPC() || trace.Entity:IsPlayer() ) ) then

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

	self:UpdateGhostFizzler( self.GhostEntity, self:GetOwner() )

end

function TOOL:RightClick( trace )

end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.aperture_science_fizzler.desc" } )
	CPanel:NumSlider( "#tool.aperture_science_fizzler.maxrad", "aperture_science_fizzler_maxrad", 80, 1000 )
	CPanel:AddControl( "PropSelect", { ConVar = "aperture_science_fizzler_model", Models = list.Get( "FizzlerModels" ), Height = 1 } )
	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_fizzler.startenabled", Command = "aperture_science_fizzler_startenabled" } )

end

list.Set( "FizzlerModels", "models/props/fizzler_dynamic.mdl", {} )