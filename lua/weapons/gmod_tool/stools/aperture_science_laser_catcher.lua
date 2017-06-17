TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_laser_catcher.name"

TOOL.ClientConVar[ "model" ] = "models/props/laser_catcher.mdl"

if ( CLIENT ) then

	//language.Add( "aperture_science_laser_catcher", "Laser Catcher" )
	language.Add( "tool.aperture_science_laser_catcher.name", "Laser Catcher" )
	language.Add( "tool.aperture_science_laser_catcher.desc", "Creates Laser Catcher" )
	language.Add( "tool.aperture_science_laser_catcher.tooldesc", "Activates when laser hit it" )
	language.Add( "tool.aperture_science_laser_catcher.0", "Left click to use" )
	
end

function TOOL:LeftClick( trace )

	-- Ignore if place target is Alive
	if ( trace.Entity && ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() || APERTURESCIENCE:IsValidEntity( trace.Entity ) ) ) then return false end

	if ( CLIENT ) then return true end
	
	if ( !APERTURESCIENCE.ALLOWING.laser_catcher && !self:GetOwner():IsSuperAdmin() ) then self:GetOwner():PrintMessage( HUD_PRINTTALK, "This tool is disabled" ) return end

	local ply = self:GetOwner()
	local model = self:GetClientInfo( "model" )
	
	MakeLaserCatcher( ply, model, trace.HitPos, trace.HitNormal:Angle() + self:ModelToAngles( model ) )
	
	return true
	
end

function TOOL:ModelToAngles( model )

	local modelToAngles = {
		["models/props/laser_catcher.mdl"] = Angle( 0, 0, 0 ),
		["models/props/laser_catcher_center.mdl"] = Angle( 0, 0, 0 ),
		["models/props/laser_receptacle.mdl"] = Angle( 90, 0, 0 ),
	}
	
	return modelToAngles[ model ]

end

if ( SERVER ) then

	function MakeLaserCatcher( pl, model, pos, ang )
		
		local entclass = ""
		if ( model == "models/props/laser_receptacle.mdl" ) then
			entclass = "ent_laser_relay"
		else
			entclass = "ent_laser_catcher"
		end
		
		local laser_catcher = ents.Create( entclass )
		laser_catcher:SetPos( pos )
		laser_catcher:SetModel( model )
		laser_catcher:SetAngles( ang )
		laser_catcher:Spawn()

		undo.Create( "Laser Catcher" )
			undo.AddEntity( laser_catcher )
			undo.SetPlayer( pl )
		undo.Finish()
		
		return true
		
	end
end

function TOOL:UpdateGhostLaserField( ent, ply )

	if ( !IsValid( ent ) ) then return end

	local trace = ply:GetEyeTrace()
	if ( !trace.Hit || trace.Entity && ( trace.Entity:GetClass() == "ent_laser_cather" || trace.Entity:IsPlayer() ) ) then

		ent:SetNoDraw( true )
		return

	end
	
	local CurPos = ent:GetPos()
	local mdl = self:GetClientInfo( "model" )
	local ang = trace.HitNormal:Angle() + self:ModelToAngles( mdl )
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

	self:UpdateGhostLaserField( self.GhostEntity, self:GetOwner() )

end

function TOOL:RightClick( trace )

end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.aperture_science_laser_catcher.tooldesc" } )
	CPanel:AddControl( "PropSelect", { ConVar = "aperture_science_laser_catcher_model", Models = list.Get( "LaserCatcherModels" ), Height = 1 } )

end

list.Set( "LaserCatcherModels", "models/props/laser_catcher.mdl", {} )
list.Set( "LaserCatcherModels", "models/props/laser_catcher_center.mdl", {} )
list.Set( "LaserCatcherModels", "models/props/laser_receptacle.mdl", {} )
