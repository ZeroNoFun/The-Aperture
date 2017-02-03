TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_fizzler.name"

TOOL.ClientConVar[ "model" ] = "models/props/fizzler.mdl"
TOOL.ClientConVar[ "maxrad" ] = "20"
TOOL.ClientConVar[ "keyenable" ] = "45"
TOOL.ClientConVar[ "toggle" ] = "0"

if ( CLIENT ) then

	language.Add( "aperture_science_fizzler", "Fizzler" )
	language.Add( "tool.aperture_science_fizzler.name", "Fizzler" )
	language.Add( "tool.aperture_science_fizzler.desc", "Creates Fizzler" )
	language.Add( "tool.aperture_science_fizzler.0", "Left click to use" )
	language.Add( "tool.aperture_science_fizzler.enable", "Enable" )
	language.Add( "tool.aperture_science_fizzler.toggle", "Toggle" )
	language.Add( "tool.aperture_science_fizzler.maxrad", "Maximum Length" )
	
end

function TOOL:LeftClick( trace )

	-- Ignore if place target is Alive
	if ( trace.Entity && trace.Entity:IsPlayer() ) then return false end
	
	if ( CLIENT ) then return true end
	
	local ply = self:GetOwner()
	local model = self:GetClientInfo( "model" )
	local maxrad = self:GetClientNumber( "maxrad" )
	local toggle = self:GetClientNumber( "toggle" )
	local keyenable = self:GetClientNumber( "keyenable" )
	local angle = trace.HitNormal:Angle()

	local firstFizzler = MakeFizzler( ply, model, angle, -90, trace.HitPos, toggle, keyenable )

	trace = util.QuickTrace( firstFizzler:GetPos(), -firstFizzler:GetRight() * maxrad, firstFizzler )

	local secondFizzler = MakeFizzler( ply, model, angle, 90, trace.HitPos, toggle, keyenable )

	firstFizzler:SetNWEntity( "GASL_ConnectedField", secondFizzler )
	secondFizzler:SetNWEntity( "GASL_ConnectedField", firstFizzler )

	undo.Create( "Fizzler" )
		undo.AddEntity( firstFizzler )
		undo.AddEntity( secondFizzler )
		undo.SetPlayer( ply )
	undo.Finish()
	
	return true
	
end

if ( SERVER ) then

	function MakeFizzler( pl, model, ang, addAng, pos, toggle, key_enable )
		
		local fizzler = ents.Create( "ent_fizzler" )
		fizzler:SetPos( pos )
		fizzler:SetAngles( ang )
		fizzler:SetAngles( fizzler:LocalToWorldAngles( Angle( 0, addAng, 0 ) ) )
		fizzler:SetMoveType( MOVETYPE_NONE )
		fizzler:Spawn()

		fizzler.NumEnableDown = numpad.OnDown( pl, key_enable, "aperture_science_fizzler_enable", fizzler, 1 )
		fizzler.NumEnableUp = numpad.OnUp( pl, key_enable, "aperture_science_fizzler_disable", fizzler, 1 )
		fizzler:SetToggle( toggle )
		
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
	if ( !trace.Hit || trace.Entity && ( trace.Entity:GetClass() == "ent_fizzler" || trace.Entity:IsPlayer() ) ) then

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
	CPanel:NumSlider( "#tool.aperture_science_fizzler.maxrad", "aperture_science_fizzler_maxrad", 20, 1000 )
	CPanel:AddControl( "PropSelect", { ConVar = "aperture_science_fizzler_model", Models = list.Get( "FizzlerModels" ), Height = 1 } )
	CPanel:AddControl( "Numpad", { Label = "#tool.aperture_science_fizzler.enable", Command = "aperture_science_fizzler_keyenable" } )
	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_fizzler.toggle", Command = "aperture_science_fizzler_toggle" } )

end

list.Set( "FizzlerModels", "models/props/fizzler.mdl", {} )
list.Set( "FizzlerModels", "models/props/fizzler.mdl", {} )