TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_mapmaker.name"

if ( CLIENT ) then

	//language.Add( "aperture_science_mapmaker", "Arm Panel" )
	language.Add( "tool.aperture_science_mapmaker.name", "Map Maker" )
	language.Add( "tool.aperture_science_mapmaker.desc", "Creates Arm Panel" )
	language.Add( "tool.aperture_science_mapmaker.tooldesc", "Makes different poses" )
	language.Add( "tool.aperture_science_mapmaker.0", "Left click to use" )

end

function TOOL:LeftClick( trace )
	
	if ( CLIENT ) then return true end
	if ( !APERTURESCIENCE.ALLOWING.mapmaker && !self:GetOwner():IsSuperAdmin() ) then self:GetOwner():PrintMessage( HUD_PRINTTALK, "This tool is disabled" ) return end
	
	local Pos = trace.HitPos + trace.HitNormal * APERTURESCIENCE.GRID_SIZE
	
	local ply = self:GetOwner()
	if ( !self:GetWeapon():GetNWVector( "GASL:ToolStart" ) || self:GetWeapon():GetNWVector( "GASL:ToolStart" ) == Vector() ) then
		Pos = APERTURESCIENCE:ConvertToGrid( Pos, APERTURESCIENCE.GRID_SIZE * 2 ) + Vector( 1, 1, 1 ) * APERTURESCIENCE.GRID_SIZE / 2
		self:GetWeapon():SetNWVector( "GASL:ToolStart", Pos )
	else
		local Walls = { }
		local LastPos = self:GetWeapon():GetNWVector( "GASL:ToolStart" )
		local DoubledGrid = APERTURESCIENCE.GRID_SIZE * 2
		local directionX = ( ( Pos.x - LastPos.x ) / math.abs( Pos.x - LastPos.x ) )
		local directionY = ( ( Pos.y - LastPos.y ) / math.abs( Pos.y - LastPos.y ) )

		for x = 0, math.abs( Pos.x - LastPos.x ), DoubledGrid do
		for y = 0, math.abs( Pos.y - LastPos.y ), DoubledGrid do
			local wall = MakeBlockWall( ply, LastPos + Vector( x * directionX, y * directionY, 0 ) )
			table.insert( Walls, table.Count( Walls ) + 1, wall )
		end
		end
		
		undo.Create( "Walls" )
			for _, k in pairs( Walls ) do undo.AddEntity( k ) end
			undo.SetPlayer( ply )
		undo.Finish()

		self:GetWeapon():SetNWVector( "GASL:ToolStart", Vector() )
	end

	
	//local mapmaker = MakeBlockWall( ply, pos )
	
	return true
end

function TOOL:RightClick( trace )
	
end

function TOOL:DrawHUD()

	if ( self:GetWeapon():GetNWVector( "GASL:ToolStart" ) != Vector() ) then
		local DoubledGrid = APERTURESCIENCE.GRID_SIZE * 2
		local LastPos = self:GetWeapon():GetNWVector( "GASL:ToolStart" )
		local trace = LocalPlayer():GetEyeTrace()
		local Pos = trace.HitPos + trace.HitNormal * APERTURESCIENCE.GRID_SIZE
		local directionX = ( ( Pos.x - LastPos.x ) / math.abs( Pos.x - LastPos.x ) )
		local directionY = ( ( Pos.y - LastPos.y ) / math.abs( Pos.y - LastPos.y ) )

		cam.Start3D()
			render.ComputeLighting( Vector(), Vector( 0, 0, 1 ) ) 
			render.ComputeDynamicLighting( Vector(), Vector( 0, 0, 1 ) ) 
			//render.ResetModelLighting( 0, 0, 0 ) 
			
			for x = 0, math.abs( Pos.x - LastPos.x ), DoubledGrid do
			for y = 0, math.abs( Pos.y - LastPos.y ), DoubledGrid do
				render.SetMaterial( Material( "models/gasl/panel/panel_white" ) )
				render.MaterialOverride( Material( "models/gasl/panel/panel_white" ) ) 
				-- render.SetLocalModelLights( {
				-- pos = LastPos + Vector( x * directionX, y * directionY, 0 ) + Vector( 0, 1000, 1000 ),
				-- dir = Vector( 0, 0, 1 )
				-- } )
				local cos = math.cos( ( x + y ) / DoubledGrid + CurTime() * 2 ) / 10 + 1.1
				render.DrawBox( 
					LastPos + Vector( x * directionX, y * directionY, 0 ), 
					Angle(), 
					-Vector( 1, 1, 1 ) * APERTURESCIENCE.GRID_SIZE / cos, 
					Vector( 1, 1, 1 ) * APERTURESCIENCE.GRID_SIZE / cos, 
					Color( 255, 0, 255, 100 ),
					false 
				) 
			end
			end

			//for z = 0, ( LastPos.z - Pos.z ), APERTURESCIENCE.GRID_SIZE * 2 do
			//end
		cam.End3D()
	end
	
	local Divs = 10
	local Radius = 10
	local prevPos = Vector( ScrW() / 2 + math.cos( 0 ) * Radius, ScrH() / 2 + math.sin( 0 ) * Radius )
	for i = 0, 1, 1.0 / Divs do
		
		local pos = Vector( ScrW() / 2 + math.cos( i * math.pi * 2 ) * Radius, ScrH() / 2 + math.sin( i * math.pi * 2 ) * Radius )
		render.DrawLine( pos, prevPos, Color( 0, 0, 0 ), false )
		prevPos = pos
		
	end

end

if ( SERVER ) then

	function MakeBlockWall( pl, pos )
		
		local wall = ents.Create( "env_portal_wall" )
		if ( !IsValid( wall ) ) then return end
		wall:SetPos( pos )
		wall:SetAngles( Angle( ) )
		wall:Spawn()
		
		return wall
	end
end

-- function TOOL:UpdateGhostBlockWall( ent, ply )

	-- if ( !IsValid( ent ) ) then return end

	-- local trace = ply:GetEyeTrace()

	-- if ( !trace.Hit || trace.Entity && ( trace.Entity:IsPlayer() || trace.Entity:IsNPC() || APERTURESCIENCE:IsValidEntity( trace.Entity ) ) ) then

		-- ent:SetNoDraw( true )
		-- return

	-- end
	
	-- local CurPos = ent:GetPos()
	
	-- local ang = trace.HitNormal:Angle() + Angle( 0, 0, 0 )
	-- local pos = APERTURESCIENCE:ConvertToGridWithoutZ( trace.HitPos + trace.HitNormal * 70, trace.HitNormal:Angle() + Angle( 90, 0, 0 ), 64 )

	-- ent:SetPos( pos + trace.HitNormal:Angle():Up() * 30 )
	-- ent:SetAngles( ang )
	-- ent:SetNoDraw( false )

-- end

function TOOL:Think()

	-- local mdl = "models/anim_wp/mapmaker/mapmaker.mdl"
	-- if ( !util.IsValidModel( mdl ) ) then self:ReleaseGhostEntity() return end

	-- if ( !IsValid( self.GhostEntity ) || self.GhostEntity:GetModel() != mdl ) then
		-- self:MakeGhostEntity( mdl, Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
	-- end

	-- self:UpdateGhostBlockWall( self.GhostEntity, self:GetOwner() )

end


local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.aperture_science_mapmaker.tooldesc" } )

end
