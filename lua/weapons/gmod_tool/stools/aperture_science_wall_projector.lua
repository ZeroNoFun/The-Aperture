TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_wall_projector.name"

TOOL.ClientConVar[ "startenabled" ] = "0"

if ( CLIENT ) then

	//language.Add( "aperture_science_wall_projector", "Hard Light Bridge" )
	language.Add( "tool.aperture_science_wall_projector.name", "Hard Light Bridge" )
	language.Add( "tool.aperture_science_wall_projector.desc", "Creates Hard Light Bridge" )
	language.Add( "tool.aperture_science_wall_projector.tooldesc", "Makes Bridges when enabled" )
	language.Add( "tool.aperture_science_wall_projector.0", "Left click to use" )
	language.Add( "tool.aperture_science_wall_projector.startenabled", "Start Enabled" )
	
end

function TOOL:LeftClick( trace )

	-- Ignore if place target is Alive
	if ( IsValid( trace.Entity ) && ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() || IsValid( trace.Entity ) && !APERTURESCIENCE:IsValidEntity( trace.Entity ) ) ) then return false end
	
	if ( CLIENT ) then return true end

	if ( !APERTURESCIENCE.ALLOWING.wall_projector && !self:GetOwner():IsSuperAdmin() ) then self:GetOwner():PrintMessage( HUD_PRINTTALK, "This tool is disabled" ) return end

	local ply = self:GetOwner()
	local startenabled = self:GetClientNumber( "startenabled" )
	
	MakeWallProjector( ply, trace.HitPos, trace.HitNormal:Angle(), startenabled )
	
	return true
	
end

if ( SERVER ) then

	function MakeWallProjector( pl, pos, ang, startenabled )
		
		local wall_projector = ents.Create( "ent_wall_projector" )
		wall_projector:SetPos( pos )
		wall_projector:SetAngles( ang )
		wall_projector:Spawn()
		
		wall_projector:SetStartEnabled( tobool( startenabled ) )
		wall_projector:ToggleEnable( false )
		
		undo.Create( "Hard Light Bridge" )
			undo.AddEntity( wall_projector )
			undo.SetPlayer( pl )
		undo.Finish()
		
		return true
	end
end


function TOOL:UpdateGhostWallProjector( ent, ply )

	if ( !IsValid( ent ) ) then return end

	local trace = ply:GetEyeTrace()

	if ( !trace.Hit || trace.Entity && ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() || APERTURESCIENCE:GASLStuff( trace.Entity ) ) ) then

		ent:SetNoDraw( true )
		return

	end
	
	local CurPos = ent:GetPos()
	
	local ang = trace.HitNormal:Angle()
	local pos = trace.HitPos

	ent:SetPos( pos )
	ent:SetAngles( ang )
	ent:SetNoDraw( false )

end

function TOOL:Think()

	local mdl = "models/props/wall_emitter.mdl"
	if ( !util.IsValidModel( mdl ) ) then self:ReleaseGhostEntity() return end

	if ( !IsValid( self.GhostEntity ) || self.GhostEntity:GetModel() != mdl ) then
		self:MakeGhostEntity( mdl, Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
	end

	self:UpdateGhostWallProjector( self.GhostEntity, self:GetOwner() )

end

function TOOL:RightClick( trace )

end

function TOOL:DrawHUD()

	local trace = self:GetOwner():GetEyeTrace()
	
	local BridgeDrawWidth = 35
	local BorderBeamWidth = 10
	local MatBridgeBorder = Material( "effects/projected_wall_rail" )

	local normal = trace.HitNormal
	local normalAngle = normal:Angle()
	local right = normalAngle:Right()
	
	local traceEnd = util.TraceLine( {
		start = trace.HitPos,
		endpos = trace.HitPos + normal * 1000000,
		filter = function( ent ) if ( ent:GetClass() == "player" || ent:GetClass() == "prop_physics" ) then return false end end
	} )
	
	if ( !trace.Hit || trace.Entity && ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() || APERTURESCIENCE:GASLStuff( trace.Entity ) ) ) then
		return
	end
	
	cam.Start3D()
		render.SetMaterial( MatBridgeBorder )
		render.DrawBeam( trace.HitPos + right * BridgeDrawWidth, traceEnd.HitPos + right * BridgeDrawWidth, BorderBeamWidth, 0, 1, Color( 100, 200, 255 ) )
		render.DrawBeam( trace.HitPos + right * -BridgeDrawWidth, traceEnd.HitPos + right * -BridgeDrawWidth, BorderBeamWidth, 0, 1, Color( 100, 200, 255 ) )
	cam.End3D()
	
end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.aperture_science_wall_projector.tooldesc" } )
	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_wall_projector.startenabled", Command = "aperture_science_wall_projector_startenabled" } )

end
