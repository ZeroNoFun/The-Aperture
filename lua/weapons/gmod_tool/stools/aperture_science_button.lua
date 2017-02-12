TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_button.name"

TOOL.ClientConVar[ "model" ] = "models/props/switch001.mdl"
TOOL.ClientConVar[ "timer" ] = "1"

if ( CLIENT ) then

	language.Add( "tool.aperture_science_button.name", "Button" )
	language.Add( "tool.aperture_science_button.desc", "Creates Button" )
	language.Add( "tool.aperture_science_button.tooldesc", "Activate other stuff" )
	language.Add( "tool.aperture_science_button.timer", "Timer" )
	language.Add( "tool.aperture_science_button.0", "Left click to use" )
	
end

function TOOL:LeftClick( trace )

	-- Ignore if place target is Alive
	if ( trace.Entity && ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() || APERTURESCIENCE:IsValidEntity( trace.Entity ) ) ) then return false end
	
	if ( CLIENT ) then return true end

	if ( !APERTURESCIENCE.ALLOWING.button && !self:GetOwner():IsSuperAdmin() ) then MsgC( Color( 255, 0, 0 ), "This tool is disabled" ) return end
	
	local ply = self:GetOwner()
	local model = self:GetClientInfo( "model" )
	local time = self:GetClientInfo( "timer" )
	
	MakePortalButton( ply, model, trace.HitPos, trace.HitNormal:Angle() + Angle( 90, 0, 0 ), time )
	
	return true
	
end

if ( SERVER ) then

	function MakePortalButton( pl, model, pos, ang, time )
		
		local button = ents.Create( "ent_portal_button" )
		button:SetPos( pos )
		button:SetModel( model )
		button:SetAngles( ang )
		button:Spawn()
		button:SetTimer( time )
		
		undo.Create( "Button" )
			undo.AddEntity( button )
			undo.SetPlayer( pl )
		undo.Finish()
		
		return true
		
	end

end

function TOOL:UpdateGhostButton( ent, ply )

	if ( !IsValid( ent ) ) then return end

	local trace = ply:GetEyeTrace()

	if ( !trace.Hit || trace.Entity && ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() || APERTURESCIENCE:IsValidEntity( trace.Entity ) ) ) then

		ent:SetNoDraw( true )
		return

	end
	
	local CurPos = ent:GetPos()
	
	local ang = trace.HitNormal:Angle() + Angle( 90, 0, 0 )
	local pos = trace.HitPos

	ent:SetPos( pos )
	ent:SetAngles( ang )
	ent:SetNoDraw( false )

end

function TOOL:Think()

	local mdl = self:GetClientInfo( "model" )
	if ( !util.IsValidModel( mdl ) ) then self:ReleaseGhostEntity() return end

	if ( !IsValid( self.GhostEntity ) || self.GhostEntity:GetModel() != mdl ) then
		self:MakeGhostEntity( mdl, Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
	end

	self:UpdateGhostButton( self.GhostEntity, self:GetOwner() )

end

function TOOL:RightClick( trace )

end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.aperture_science_button.tooldesc" } )
	CPanel:AddControl( "PropSelect", { ConVar = "aperture_science_button_model", Models = list.Get( "PortalButtonModels" ), Height = 1 } )
	CPanel:NumSlider( "#tool.aperture_science_button.timer", "aperture_science_button_timer", 1, 60 )

end

list.Set( "PortalButtonModels", "models/props_underground/underground_testchamber_button.mdl", {} )
list.Set( "PortalButtonModels", "models/props/switch001.mdl", {} )