TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_mapmaker.name"

TOOL.Walls = {}

TOOL.ClientConVar["prop"] = 1

if ( CLIENT ) then
	language.Add( "tool.aperture_science_mapmaker.name", "Map Maker" )
	language.Add( "tool.aperture_science_mapmaker.desc", "Creates Arm Panel" )
	language.Add( "tool.aperture_science_mapmaker.tooldesc", "Makes different poses" )
	language.Add( "tool.aperture_science_mapmaker.0", "Left click to use" )
	language.Add( "tool.aperture_science_mapmaker.prop", "Select prop" )

end

function TOOL:LeftClick( trace )
	
	if ( CLIENT ) then return true end
	
	local Pos = trace.HitPos + trace.HitNormal * APERTURESCIENCE.GRID_SIZE
	
	local ply = self:GetOwner()
	if ( !self:GetWeapon():GetNWVector( "GASL:ToolStart" ) || self:GetWeapon():GetNWVector( "GASL:ToolStart" ) == Vector() ) then
		Pos = APERTURESCIENCE:ConvertToGrid( Pos, APERTURESCIENCE.GRID_SIZE * 2 ) + Vector( 1, 1, 1 ) * APERTURESCIENCE.GRID_SIZE / 2
		self:GetWeapon():SetNWVector( "GASL:ToolStart", Pos )
	else
		local LastPos = self:GetWeapon():GetNWVector( "GASL:ToolStart" )
		local DoubledGrid = APERTURESCIENCE.GRID_SIZE * 2
		local directionX = ( ( Pos.x - LastPos.x ) / math.abs( Pos.x - LastPos.x ) )
		local directionY = ( ( Pos.y - LastPos.y ) / math.abs( Pos.y - LastPos.y ) )

		for x = 0, math.abs( Pos.x - LastPos.x ), DoubledGrid do
		for y = 0, math.abs( Pos.y - LastPos.y ), DoubledGrid do
			local wall = self:MakeBlockWall( ply, LastPos + Vector( x * directionX, y * directionY, 0 ), self:GetClientInfo("prop"))
			table.insert( self.Walls, table.Count( self.Walls ) + 1, wall )
		end
		end
		
		undo.Create( "Walls" )
			for v, k in pairs( self.Walls ) do undo.AddEntity( k ) self.Walls[v] = nil end
			undo.SetPlayer( ply )
		undo.Finish()

		self:GetWeapon():SetNWVector( "GASL:ToolStart", Vector() )
	end	
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
				local mat = "models/gasl/panel/panel_white"
				render.SetMaterial( Material(mat))
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

	function TOOL:MakeBlockWall( pl, pos, index )
		local wall = ents.Create("env_portal_wall")
		if ( !IsValid( wall ) ) then return end
		wall:SetPos( pos )
		wall:SetAngles( Angle( ) )
		wall:Spawn()
		
		return wall
	end
end


local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )
	CPanel:AddControl( "Header", { Description = "#tool.aperture_science_mapmaker.tooldesc" } )
	local combobox = CPanel:ComboBox( "#tool.aperture_science_mapmaker.prop", "aperture_science_mapmaker_prop" )

end
