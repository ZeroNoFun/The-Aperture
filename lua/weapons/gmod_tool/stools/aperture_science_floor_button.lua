TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_floor_button.name"

TOOL.ClientConVar[ "model" ] = "models/portal_custom/ball_button_custom.mdl"

if ( CLIENT ) then

	language.Add( "tool.aperture_science_floor_button.name", "Floor Button" )
	language.Add( "tool.aperture_science_floor_button.desc", "Creates Button" )
	language.Add( "tool.aperture_science_floor_button.tooldesc", "Activate other stuff" )
	language.Add( "tool.aperture_science_floor_button.0", "Left click to use" )
	
end

function TOOL:LeftClick( trace )

	-- Ignore if place target is Alive
	if ( trace.Entity && ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() || APERTURESCIENCE:IsValidEntity( trace.Entity ) ) ) then return false end
	
	if ( CLIENT ) then return true end

	if ( !APERTURESCIENCE.ALLOWING.floor_button && !self:GetOwner():IsSuperAdmin() ) then self:GetOwner():PrintMessage( HUD_PRINTTALK, "This tool is disabled" ) return end
	
	local ply = self:GetOwner()
	local model = self:GetClientInfo( "model" )
	local class = self:ModelToEntity( model )
	MakePortalFloorButton( ply, class, trace.HitPos, trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
	
	return true
	
end

function TOOL:ModelToEntity( mdl )

	local modelToEntity = {
		["models/portal_custom/ball_button_custom.mdl"] = "sent_portalbutton_ball",
		["models/portal_custom/box_socket_custom.mdl"] = "sent_portalbutton_box",
		["models/portal_custom/portal_button_custom.mdl"] = "sent_portalbutton_normal",
		["models/portal_custom/underground_floor_button_custom.mdl"] = "sent_portalbutton_old"
	}
	
	return modelToEntity[ mdl ]

end

if ( SERVER ) then

	function MakePortalFloorButton( pl, class, pos, ang )
		
		local floor_button = ents.Create( class )
		floor_button:SetPos( pos )
		floor_button:SetAngles( ang )
		floor_button.Owner = pl
		floor_button.CanUpdateSettings = true
		floor_button:Spawn()
		floor_button:Activate()
		floor_button:GetPhysicsObject():EnableMotion( false )
		undo.Create( "Floor Button" )
			undo.AddEntity( floor_button )
			undo.SetPlayer( pl )
		undo.Finish()
		
		return true
		
	end

end

function TOOL:UpdateGhostFloorButton( ent, ply )

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

	self:UpdateGhostFloorButton( self.GhostEntity, self:GetOwner() )

end

function TOOL:RightClick( trace )

end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.aperture_science_floor_button.tooldesc" } )
	CPanel:AddControl( "PropSelect", { ConVar = "aperture_science_floor_button_model", Models = list.Get( "PortalFloorButtonModels" ), Height = 1 } )

end

list.Set( "PortalFloorButtonModels", "models/portal_custom/ball_button_custom.mdl", {} )
list.Set( "PortalFloorButtonModels", "models/portal_custom/box_socket_custom.mdl", {} )
list.Set( "PortalFloorButtonModels", "models/portal_custom/portal_button_custom.mdl", {} )
list.Set( "PortalFloorButtonModels", "models/portal_custom/underground_floor_button_custom.mdl", {} )