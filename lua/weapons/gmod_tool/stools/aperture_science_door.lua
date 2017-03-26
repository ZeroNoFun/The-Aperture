TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_door.name"

TOOL.ClientConVar[ "model" ] = "models/props/switch001.mdl"
TOOL.ClientConVar[ "timer" ] = "1"

if ( CLIENT ) then

	language.Add( "tool.aperture_science_door.name", "Door" )
	language.Add( "tool.aperture_science_door.desc", "Creates Door" )
	language.Add( "tool.aperture_science_door.0", "Left click to use" )
	
end

function TOOL:LeftClick( trace )

	-- Ignore if place target is Alive
	if ( CLIENT ) then return true end
	if ( trace.Entity && ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() || APERTURESCIENCE:IsValidEntity( trace.Entity ) ) ) then return false end
	if ( !APERTURESCIENCE.ALLOWING.door && !self:GetOwner():IsSuperAdmin() ) then self:GetOwner():PrintMessage( HUD_PRINTTALK, "This tool is disabled" ) return end
	
	local ply = self:GetOwner()
	local model = self:GetClientInfo( "model" )
	
	MakePortalDoor( ply, model, trace.HitPos, trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
	
	return true
	
end

if ( SERVER ) then

	function MakePortalDoor( pl, model, pos, ang )
		
		local door = ents.Create( "ent_portal_door" )
		door:SetPos( pos )
		door:SetAngles( ang )
		door:Spawn()
		
		undo.Create( "Door" )
			undo.AddEntity( door )
			undo.SetPlayer( pl )
		undo.Finish()
		
		return true
		
	end

end

function TOOL:UpdateGhostDoor( ent, ply )

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

	self:UpdateGhostDoor( self.GhostEntity, self:GetOwner() )

end

function TOOL:RightClick( trace )

end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.aperture_science_door.tooldesc" } )
	//CPanel:AddControl( "PropSelect", { ConVar = "aperture_science_door_model", Models = list.Get( "PortalDoorModels" ), Height = 1 } )

end

-- list.Set( "PortalDoorModels", "models/props_underground/underground_testchamber_door.mdl", {} )
-- list.Set( "PortalDoorModels", "models/props/switch001.mdl", {} )