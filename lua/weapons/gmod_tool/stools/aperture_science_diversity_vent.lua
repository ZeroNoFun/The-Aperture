TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_diversity_vent.name"

TOOL.ClientConVar[ "startenabled" ] = "0"
TOOL.ClientConVar[ "model" ] = "models/props_bts/vactube_128_straight.mdl"

if ( CLIENT ) then

	//language.Add( "aperture_science_diversity_vent", "Pneumatic Diversity Vent" )
	language.Add( "tool.aperture_science_diversity_vent.name", "Pneumatic Diversity Vent" )
	language.Add( "tool.aperture_science_diversity_vent.desc", "Creates Pneumatic Diversity Vent" )
	language.Add( "tool.aperture_science_diversity_vent.tooldesc", "Makes Bridges when enabled" )
	language.Add( "tool.aperture_science_diversity_vent.0", "Left click to use" )
	language.Add( "tool.aperture_science_diversity_vent.startenabled", "Start Enabled" )
	
end

local function ModelToCoords( model )

	local modelToCoords = {
		["models/props_backstage/vacum_scanner_b.mdl"] = { { pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ) } },
		["models/props_bts/vactube_128_straight.mdl"] = { { pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ) }, { pos = Vector( 0, 128, 0 ), ang = Angle( 0, 0, 0 ) } },
		["models/props_bts/vactube_90deg_01.mdl"] = { { pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ) }, { pos = Vector( 0, 65, -63 ), ang = Angle( 0, 0, -90 ) } },
		["models/props_bts/vactube_90deg_02.mdl"] = { { pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ) }, { pos = Vector( 0, 128, -126 ), ang = Angle( 0, 0, -90 ) } },
		["models/props_bts/vactube_90deg_03.mdl"] = { { pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ) }, { pos = Vector( 0, 192, -192 ), ang = Angle( 0, 0, -90 ) } },
		["models/props_bts/vactube_90deg_04.mdl"] = { { pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ) }, { pos = Vector( 0, 256, -256 ), ang = Angle( 0, 0, -90 ) } },
		["models/props_bts/vactube_90deg_05.mdl"] = { { pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ) }, { pos = Vector( 0, 320, -320 ), ang = Angle( 0, 0, -90 ) } },
		["models/props_bts/vactube_90deg_06.mdl"] = { { pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ) }, { pos = Vector( 0, 384, -384 ), ang = Angle( 0, 0, -90 ) } },
		["models/props_bts/vactube_tjunction.mdl"] = { 
			{ pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ) },
			{ pos = Vector( 0, 128, 0 ), ang = Angle( 0, 0, 0 ) },
			{ pos = Vector( -192, 64, 0 ), ang = Angle( 0, 90, 0 ) } 
		},
		["models/props_bts/vactube_crossroads.mdl"] = { 
			{ pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ) },
			{ pos = Vector( 0, 128, 0 ), ang = Angle( 0, 0, 0 ) },
			{ pos = Vector( -192, 64, 0 ), ang = Angle( 0, 90, 0 ) },
			{ pos = Vector( 192, 64, 0 ), ang = Angle( 0, -90, 0 ) } 
		},
	}
	
	return modelToCoords[ model ]
	
end

local function DistanceFromLineToPoint( pos, dir, point )

	local distToPoint = pos:Distance( point )
	local distFromLineToPoint = point:Distance( pos + dir * distToPoint )
	
	return distFromLineToPoint
	
end

local function GetClosestVentPoint( ply )

	local closestPoint = -1
	local Ent, Pos, Ang
	
	for k, v in pairs( ents.FindByClass( "ent_diversity_vent" ) ) do
	
		local plyDisPos = ply:GetShootPos() + ply:EyeAngles():Forward() * ( ply:GetShootPos():Distance( v:GetPos() ) )
		
		if ( plyDisPos:Distance( v:GetPos() ) < v:GetModelRadius() * 2 ) then
		
			for inx, coord in pairs( ModelToCoords( v:GetModel() ) ) do
			
				local coordWorld = v:LocalToWorld( coord.pos )
				local distToPoint = ply:GetShootPos():Distance( coordWorld )
				local distFromLineToPoint = DistanceFromLineToPoint( ply:GetShootPos(), ply:EyeAngles():Forward(), coordWorld )
				
				if ( distFromLineToPoint < 50 &&
					( closestPoint == -1 || distToPoint < closestPoint ) ) then
					
					closestPoint = distToPoint
					Ent = v
					Pos = coord.pos
					Ang = coord.ang
					
				end
			end
		end
	end

	return Ent, Pos, Ang
	
end

function TOOL:LeftClick( trace )
	
	if ( CLIENT ) then return true end

	//if ( !APERTURESCIENCE.ALLOWING.diversity_vent && !self:GetOwner():IsSuperAdmin() ) then self:GetOwner():PrintMessage( HUD_PRINTTALK, "This tool is disabled" ) return end
	
	local model = self:GetClientInfo( "model" )

	local ply = self:GetOwner()
	local startenabled = self:GetClientNumber( "startenabled" )
	
	local vent, ventPPos, ventPAng = GetClosestVentPoint( ply )
	
	local divvent = NULL

	if ( !IsValid( vent ) ) then
	
		divvent = MakeDiversityVent( ply, "models/props_backstage/vacum_scanner_b.mdl", trace.HitPos + trace.HitNormal * 200, trace.HitNormal:Angle() + Angle( 90, 0, 90 ), startenabled )
		if ( !IsValid( divvent ) ) then return end

		divvent:SetNotSolid( true )
		
	else
	
		local angle = self:GetWeapon():GetNWInt( "GASL_DIVVENT_Rotation" )
		local ventInfo = ModelToCoords( model )[ 1 ]
		local GhotPosOffset = ventInfo.pos

		GhotPosOffset:Rotate( ventInfo.ang )
		GhotPosOffset:Rotate( ventPAng )
		
		local Pos = vent:LocalToWorld( GhotPosOffset + ventPPos )
		local Ang = vent:LocalToWorldAngles( ventPAng + ventInfo.ang )
		_, Ang = LocalToWorld( Vector(), Angle( angle, 0, 0 ), Vector(), Ang )

		divvent = MakeDiversityVent( ply, model, Pos, Ang, startenabled )
		if ( !IsValid( divvent ) ) then return end

		table.insert( vent.GASL_DIVVENT_Connections, 1, divvent )

	end
	
	divvent:SetPersistent( true )
	divvent.GASL_Ignore = true
	divvent.GASL_Untouchable = true

	return true
	
end

if ( SERVER ) then

	function MakeDiversityVent( pl, model, pos, ang, startenabled )
		
		local diversity_vent = ents.Create( "ent_diversity_vent" )
		diversity_vent:SetPos( pos )
		diversity_vent:SetModel( model )
		diversity_vent:SetAngles( ang )
		diversity_vent:Spawn()
		
		diversity_vent:SetStartEnabled( tobool( startenabled ) )
		diversity_vent:ToggleEnable( false )
		
		undo.Create( "Pneumatic Diversity Vent" )
			undo.AddEntity( diversity_vent )
			undo.SetPlayer( pl )
		undo.Finish()
		
		return diversity_vent
	end
end

function TOOL:Reload()

	self:GetWeapon():SetNWInt( "GASL_DIVVENT_Rotation", self:GetWeapon():GetNWInt( "GASL_DIVVENT_Rotation" ) + 90 )

end


function TOOL:UpdateGhostDiversityVent( ent, ply )

	if ( !IsValid( ent ) ) then return end

	local trace = ply:GetEyeTrace()

	if ( !trace.Hit || trace.Entity && ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() || APERTURESCIENCE:GASLStuff( trace.Entity ) ) ) then

		ent:SetNoDraw( true )
		return

	end
	
	local CurPos = ent:GetPos()
	
	local ang = trace.HitNormal:Angle()
	local pos = trace.HitPos

	local vent, ventPPos, ventPAng = GetClosestVentPoint( ply )

	if ( !IsValid( vent ) ) then
	
		pos = pos + trace.HitNormal * 200
		ang = ang + Angle( 90, 0, 90 )
		ent:SetModel( "models/props_backstage/vacum_scanner_b.mdl" )
		
	else

		local angle = self:GetWeapon():GetNWInt( "GASL_DIVVENT_Rotation" )
		local model = self:GetClientInfo( "model" )
		local ventInfo = ModelToCoords( model )[ 1 ]
		local GhotPosOffset = ventInfo.pos

		GhotPosOffset:Rotate( ventInfo.ang )
		GhotPosOffset:Rotate( ventPAng )
		
		pos = vent:LocalToWorld( GhotPosOffset + ventPPos )
		ang = vent:LocalToWorldAngles( ventPAng + ventInfo.ang )
		_, ang = LocalToWorld( Vector(), Angle( angle, 0, 0 ), Vector(), ang )

		ent:SetModel( model )
		
	end

	ent:SetPos( pos )
	ent:SetAngles( ang )
	ent:SetNoDraw( false )

end

function TOOL:Think()

	if ( !self:GetWeapon():GetNWInt( "GASL_DIVVENT_Rotation" ) ) then self:GetWeapon():SetNWInt( "GASL_DIVVENT_GASL_DIVVENT_Rotation", 0 ) end
	if ( !self:GetWeapon():GetNWInt( "GASL_DIVVENT_CoordIndex" ) ) then self:GetWeapon():SetNWInt( "GASL_DIVVENT_CoordIndex", 1 ) end

	local model = self:GetClientInfo( "model" )
	if ( !util.IsValidModel( model ) ) then self:ReleaseGhostEntity() return end

	if ( !IsValid( self.GhostEntity ) ) then
		self:MakeGhostEntity( model, Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
	end

	self:UpdateGhostDiversityVent( self.GhostEntity, self:GetOwner() )

end

function TOOL:RightClick( trace )

end

function TOOL:DrawHUD()

	-- local trace = self:GetOwner():GetEyeTrace()
	
	-- local BridgeDrawWidth = 35
	-- local BorderBeamWidth = 10
	-- local MatBridgeBorder = Material( "effects/projected_wall_rail" )

	-- local normal = trace.HitNormal
	-- local normalAngle = normal:Angle()
	-- local right = normalAngle:Right()
	
	-- local traceEnd = util.TraceLine( {
		-- start = trace.HitPos,
		-- endpos = trace.HitPos + normal * 1000000,
		-- filter = function( ent ) if ( ent:GetClass() == "player" || ent:GetClass() == "prop_physics" ) then return false end end
	-- } )
	
	-- if ( !trace.Hit || trace.Entity && ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() || APERTURESCIENCE:GASLStuff( trace.Entity ) ) ) then
		-- return
	-- end
	
	local model = self:GetClientInfo( "model" )

	render.SetMaterial( Material( "sprites/sent_ball" ) )
	
	cam.Start3D()
	for k, v in pairs( ents.FindByClass( "ent_diversity_vent" ) ) do
	
		local plyDisPos = LocalPlayer():GetShootPos() + LocalPlayer():EyeAngles():Forward() * ( LocalPlayer():GetShootPos():Distance( v:GetPos() ) )
		
		if ( plyDisPos:Distance( v:GetPos() ) < v:GetModelRadius() * 2 ) then
		
			for inx, coord in pairs( ModelToCoords( v:GetModel() ) ) do
			
				local coordWorld = v:LocalToWorld( coord.pos )
				local distToPoint = DistanceFromLineToPoint( LocalPlayer():GetShootPos(), LocalPlayer():EyeAngles():Forward(), coordWorld )
				
				local color = Color( 255, 0, 0 )
				if ( distToPoint < 50 ) then color = Color( 0, 255, 0 ) end
				
				render.DrawSprite( coordWorld, 20, 20, color )
			end
		
		end
	
	end
	cam.End3D()	
	
end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.aperture_science_diversity_vent.tooldesc" } )
	CPanel:AddControl( "PropSelect", { ConVar = "aperture_science_diversity_vent_model", Models = list.Get( "DiversityVentModels" ), Height = 3 } )
	CPanel:AddControl( "CheckBox", { Label = "#tool.aperture_science_diversity_vent.startenabled", Command = "aperture_science_diversity_vent_startenabled" } )

end

list.Set( "DiversityVentModels", "models/props_bts/vactube_128_straight.mdl", {} )
list.Set( "DiversityVentModels", "models/props_bts/vactube_90deg_01.mdl", {} )
list.Set( "DiversityVentModels", "models/props_bts/vactube_90deg_02.mdl", {} )
list.Set( "DiversityVentModels", "models/props_bts/vactube_90deg_03.mdl", {} )
list.Set( "DiversityVentModels", "models/props_bts/vactube_90deg_04.mdl", {} )
list.Set( "DiversityVentModels", "models/props_bts/vactube_90deg_05.mdl", {} )
list.Set( "DiversityVentModels", "models/props_bts/vactube_90deg_06.mdl", {} )
list.Set( "DiversityVentModels", "models/props_bts/vactube_tjunction.mdl", {} )
list.Set( "DiversityVentModels", "models/props_bts/vactube_crossroads.mdl", {} )
list.Set( "DiversityVentModels", "models/props_bts/vactube_90deg_01.mdl", {} )
