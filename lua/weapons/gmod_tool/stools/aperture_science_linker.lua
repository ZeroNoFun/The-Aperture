TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_linker.name"

if ( CLIENT ) then

	language.Add( "aperture_science_linker", "Linker" )
	language.Add( "tool.aperture_science_linker.name", "Linker" )
	language.Add( "tool.aperture_science_linker.desc", "Connects Aperture science devices together" )
	language.Add( "tool.aperture_science_linker.0", "Left click to select object" )
	language.Add( "tool.aperture_science_linker.1", "Right Click to connect to selected object" )
	language.Add( "tool.aperture_science_linker.2", "Resets selected key" )
	
	surface.CreateFont( "GASL_LinkerFont", {
		font = "Calibri Light",
		size = 32,
		weight = 100000,
		antialias = true,
	} )

end

function TOOL:LeftClick( trace )

	local traceEnt = trace.Entity
	
	-- Ignore if place target is Alive or non Aperture
	if ( !traceEnt || traceEnt && !APERTURESCIENCE:ConnectableStuff( traceEnt ) ) then return false end
	
	if ( CLIENT ) then return true end

	local ply = self:GetOwner()
	local lastEnt = self:GetWeapon():GetNWEntity( "GASL_Linker_LastEnt" )
	local selectedInputName = self:GetWeapon():GetNWEntity( "GASL_Linker_InputName" )
	local selectedOutputName = self:GetWeapon():GetNWEntity( "GASL_Linker_OutputName" )
	
	if ( !IsValid( lastEnt ) ) then
		
		if ( !APERTURESCIENCE.ALLOWING.linker && !self:GetOwner():IsSuperAdmin() ) then self:GetOwner():PrintMessage( HUD_PRINTTALK, "This tool is disabled" ) return end
		
		-- if inputs doesn't exist skip
		if ( !traceEnt.GASL_LinkInputs || table.Count( traceEnt.GASL_LinkInputs ) == 0 ) then return end
		
		-- if doesn't selected any input selecting first
		if ( traceEnt.GASL_LinkInputs[ selectedInputName ] == nil ) then
			local keys = table.GetKeys( traceEnt.GASL_LinkInputs )
			local inpName = keys[ 1 ]
			
			self:GetWeapon():SetNWEntity( "GASL_Linker_InputName", inpName )
			selectedInputName = inpName
		end
		
		-- selecting input
		if ( traceEnt.GASL_LinkInputs && traceEnt.GASL_LinkInputs[ selectedInputName ] != nil && selectedInputName != "" ) then 
			self:GetWeapon():SetNWEntity( "GASL_Linker_LastEnt", traceEnt )
		end
		
	elseif ( traceEnt.GASL_LinkOutputs && selectedOutputName != "" ) then
	
		-- if outputs doesn't exist skip
		if ( !traceEnt.GASL_LinkOutputs || table.Count( traceEnt.GASL_LinkOutputs ) == 0 ) then return end

		-- if doesn't selected any output selecting first
		if ( traceEnt.GASL_LinkOutputs[ selectedOutputName ] == nil ) then
			local keys = table.GetKeys( traceEnt.GASL_LinkOutputs )
			local outName = keys[ 1 ]
			
			selectedOutputName = outName
		end
		
		-- selecting output
		if ( lastEnt.GASL_LinkConnections[ selectedInputName ] != nil ) then lastEnt:RemoveConnection( selectedInputName ) end
		self:GetWeapon():SetNWEntity( "GASL_Linker_LastEnt", NULL )
		lastEnt:AddConnection( traceEnt, selectedInputName, selectedOutputName )
	end
	
	undo.Create( "Linker" )
		undo.AddEntity( firstLinker )
		undo.AddEntity( secondLinker )
		undo.SetPlayer( ply )
	undo.Finish()
	
	return true
	
end

function TOOL:RightClick( trace )

	local traceEnt = trace.Entity

	-- Ignore if place target is Alive or non Aperture
	if ( traceEnt && !APERTURESCIENCE:ConnectableStuff( traceEnt ) ) then return false end
	
	if ( CLIENT ) then return false end

	if ( !APERTURESCIENCE.ALLOWING.linker && !self:GetOwner():IsSuperAdmin() ) then self:GetOwner():PrintMessage( HUD_PRINTTALK, "This tool is disabled" ) return end
	
	local ply = self:GetOwner()
	local lastEnt = self:GetWeapon():GetNWEntity( "GASL_Linker_LastEnt" )
	if ( !self.GASL_Link_KeyIndex ) then self.GASL_Link_KeyIndex = 0 end

	self.GASL_Link_KeyIndex = self.GASL_Link_KeyIndex + 1
	local lastKeyIndex = self.GASL_Link_KeyIndex

	if ( !IsValid( lastEnt ) ) then
		if ( !traceEnt.GASL_LinkInputs ) then return end
		-- selecting input
		if ( lastKeyIndex > table.Count( traceEnt.GASL_LinkInputs ) ) then
			self.GASL_Link_KeyIndex = 1
			lastKeyIndex = 1
		end

		local keys = table.GetKeys( traceEnt.GASL_LinkInputs )
		self:GetWeapon():SetNWString( "GASL_Linker_InputName", keys[ lastKeyIndex ] )
		
	else
		if ( !traceEnt.GASL_LinkOutputs ) then return end
		-- selecting output
		if ( lastKeyIndex > table.Count( traceEnt.GASL_LinkOutputs ) ) then
			self.GASL_Link_KeyIndex = 1
			lastKeyIndex = 1
		end
		
		local keys = table.GetKeys( traceEnt.GASL_LinkOutputs )
		self:GetWeapon():SetNWString( "GASL_Linker_OutputName", keys[ lastKeyIndex ] )
	end

end

function TOOL:Reload( trace )

	local lastEnt = self:GetWeapon():GetNWEntity( "GASL_Linker_LastEnt" )

	local selectedInputName = self:GetWeapon():GetNWEntity( "GASL_Linker_InputName" )

	if ( !IsValid( lastEnt ) ) then
	
		-- Ignore if place target is Alive or non Aperture
		if ( trace.Entity && !APERTURESCIENCE:ConnectableStuff( trace.Entity ) && !IsValid( lastEnt ) ) then return false end
		if ( CLIENT ) then return true end
		
		if ( !APERTURESCIENCE.ALLOWING.linker && !self:GetOwner():IsSuperAdmin() ) then self:GetOwner():PrintMessage( HUD_PRINTTALK, "This tool is disabled" ) return end
		
		-- clearing input
		if ( trace.Entity.GASL_LinkInputs && trace.Entity.GASL_LinkInputs[ selectedInputName ] != nil && selectedInputName != ""
			&& trace.Entity.GASL_LinkConnections && trace.Entity.GASL_LinkConnections[ selectedInputName ] != nil ) then
			trace.Entity:RemoveConnection( selectedInputName )
		end
		
		trace.Entity:ActiveInput( selectedInputName )
	
	else
		-- drop selection if available
		if ( CLIENT ) then return false end
		self:GetWeapon():SetNWEntity( "GASL_Linker_LastEnt", NULL )
		
	end
	
	return true

end

-- drawing thick line
function TOOL:DrawLineWidth( pos, length, vertical, width )

	if ( !vertical ) then
		if ( length >= 0 ) then
			surface.DrawRect( pos.x - width / 2, pos.y - width / 2, width + length, width )
		else
			surface.DrawRect( pos.x + length - width / 2, pos.y - width / 2, width - length, width )
		end
	else
		if ( length >= 0 ) then
			surface.DrawRect( pos.x - width / 2, pos.y - width / 2, width, width + length )
		else
			surface.DrawRect( pos.x - width / 2, pos.y + length - width / 2, width, width - length )
		end
	end
	
end

-- drawing right 3 dof line
function TOOL:DrawConnection( vec1, vec2, width, offset )
	
	local dir = Vector( vec2.x, vec2.y, 0 ) - Vector( vec1.x, vec1.y, 0 )
	
	if ( math.abs( dir.x ) > math.abs( dir.y ) ) then
		local direction = dir.x / math.abs( dir.x )
		
		self:DrawLineWidth( Vector( vec1.x + direction * offset, vec1.y, 0 ), dir.x / 2 - direction * offset , false, width )
		self:DrawLineWidth( Vector( vec2.x - direction * offset, vec2.y, 0 ), -dir.x / 2 + direction * offset, false, width )
		self:DrawLineWidth( Vector( vec1.x + dir.x / 2, vec1.y, 0 ), dir.y, true, width )
	else
		local direction = dir.y / math.abs( dir.y )
		
		self:DrawLineWidth( Vector( vec1.x, vec1.y + direction * offset, 0 ), dir.y / 2 - direction * offset, true, width )
		self:DrawLineWidth( Vector( vec2.x, vec2.y - direction * offset, 0 ), -dir.y / 2 + direction * offset, true, width )
		self:DrawLineWidth( Vector( vec1.x, vec1.y + dir.y / 2, 0 ), dir.x, false, width )
	end
	
end

-- Drawing context menu
function TOOL:DrawMenu( name, tableElements, funcColor, Offset )

	local height = 0
	local BordersW = 10
	local BordersH = 10
	local BordersMenuH = 0
	local BorderWL = 50
	
	surface.SetFont( "GASL_LinkerFont" )
	local maxWidth, textHeight = surface.GetTextSize( name )

	for k, text in pairs( tableElements ) do
		local w, h = surface.GetTextSize( text )
		if ( w > maxWidth ) then maxWidth = w end
	end
	
	-- Menu name
	surface.SetDrawColor( 50, 50, 50, 225 )
	surface.DrawRect( ScrW() / 2 + Offset - BordersW
		, ScrH() / 2 - ( table.Count( tableElements ) / 2 ) * textHeight - BordersH - textHeight - BordersMenuH
		, maxWidth + BordersW * 2 + BorderWL
		, textHeight + BordersMenuH + table.Count( tableElements )
	)
	-- Menu name text
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos( ScrW() / 2 + Offset + BorderWL
		, ScrH() / 2 - ( table.Count( tableElements ) / 2 - height ) * textHeight - BordersH - textHeight - BordersMenuH / 2
	)
	surface.DrawText( name )

	-- Menu list
	surface.SetDrawColor( 200, 200, 200, 255 )
	surface.DrawRect( ScrW() / 2 + Offset - BordersW + BorderWL
		, ScrH() / 2 - ( table.Count( tableElements ) / 2 ) * textHeight - BordersH
		, maxWidth + BordersW * 2
		, textHeight * table.Count( tableElements ) + BordersH * 2
	)
	surface.SetDrawColor( 150, 150, 150, 255 )
	surface.DrawRect( ScrW() / 2 + Offset - BordersW
		, ScrH() / 2 - ( table.Count( tableElements ) / 2 ) * textHeight - BordersH
		, BorderWL
		, textHeight * table.Count( tableElements ) + BordersH * 2
	)
	
	-- Menu contain text
	for k, text in pairs( tableElements ) do
	
		surface.SetTextColor( 200, 200, 200, 255 )
		funcColor( text )
		
		surface.SetTextPos( ScrW() / 2 + Offset + BorderWL
			, ScrH() / 2 - ( table.Count( tableElements ) / 2 - height ) * textHeight 
		)
		surface.DrawText( text )
		height = height + 1
	
	end

end

function TOOL:DrawOutlinedBox( x, y, w, h, thickness, clr )

	surface.SetDrawColor( clr )
	for i = 0, thickness - 1 do
		surface.DrawOutlinedRect( x + i, y + i, w - i * 2, h - i * 2 )
	end
	
end

function TOOL:DrawHUD()

	local LinkedColor = Color( 0, 200, 255 )
	local LinkedColorAlpha = Color( 0, 200, 255, 50 )
	local LinkedSelect = Color( 255, 200, 0 )
	local NotLinked = Color( 255, 255, 255 )

	local HUDScale = 0.75
	local Offset = 40
	local PointScale = HUDScale * 20
	local LineWidth = HUDScale * 4

	local trace = LocalPlayer():GetEyeTrace()
	local traceEnt = trace.Entity
	local lastEnt = self:GetWeapon():GetNWEntity( "GASL_Linker_LastEnt" )
	local lastInputName = self:GetWeapon():GetNWString( "GASL_Linker_InputName" )
	local outputName = self:GetWeapon():GetNWString( "GASL_Linker_OutputName" )
	
	-- Drawing objects connections
	if ( IsValid( lastEnt ) ) then
		
		local lastEntPos2D = lastEnt:GetPos():ToScreen()
		surface.SetFont( "GASL_SecFont" )
		local dir = ( lastEntPos2D.x - ScrW() / 2 )
		dir = dir / math.abs( dir )
		
		local width, height = surface.GetTextSize( lastInputName )
		
		-- offseting text left or right for more visibility
		local offst = 0
		if ( dir < 0 ) then offst = ( Offset + width ) * dir else offst = Offset * dir  end

		surface.SetTextColor( NotLinked )
		surface.SetTextPos( lastEntPos2D.x + offst, lastEntPos2D.y + height / 2 )
		surface.DrawText( lastInputName )

		local vec1 = Vector( ScrW() / 2, ScrH() / 2, 0 )
		local vec2 = lastEnt:GetPos()
		surface.SetDrawColor( LinkedColor )
		
		self:DrawOutlinedBox( vec1.x - PointScale / 2, vec1.y - PointScale / 2, PointScale, PointScale, LineWidth, LinkedColor )
		self:DrawConnection( vec1, vec2:ToScreen(), LineWidth, PointScale / 2 )
		surface.DrawRect( lastEntPos2D.x - PointScale / 2, lastEntPos2D.y - PointScale / 2, PointScale, PointScale )
		
	end
	
	local showConnectionEnt = NULL
	local showConnectionName = ""
	
	if ( !IsValid( lastEnt ) && IsValid( traceEnt ) && APERTURESCIENCE:ConnectableStuff( traceEnt ) ) then
	
		for k, coonectedEnt in pairs( traceEnt.GASL_LinkConnections ) do
		
			if ( IsValid( coonectedEnt ) && lastInputName == k ) then
				showConnectionEnt = traceEnt
				showConnectionName = k
			end
		end

	end
	
	-- Drawing objects connections
	for _, ent in pairs( ents.GetAll() ) do
		
		if ( APERTURESCIENCE:ConnectableStuff( ent ) ) then
		
			local vec = ent:GetPos():ToScreen()
			
			-- If selected to connect another entity
			if ( IsValid( lastEnt ) && lastEnt == ent ) then
			
				surface.SetDrawColor( LinkedColor )				
				if ( APERTURESCIENCE.DRAW_HALOS ) then
					halo.Add( { ent }, LinkedColor, 4, 4, 1, true, false )
				end
				
			elseif ( traceEnt == ent ) then

				-- if player aiming on it
				surface.SetDrawColor( LinkedSelect )				
				if ( APERTURESCIENCE.DRAW_HALOS ) then
					halo.Add( { ent }, LinkedSelect, 2, 2, 1, true, false )
				end				
			
			else
				-- if nothing is happaning
				surface.SetDrawColor( NotLinked )				
				if ( APERTURESCIENCE.DRAW_HALOS ) then
					halo.Add( { ent }, NotLinked, 2, 2, 1, true, false )
				end				
				
			end
			
			-- Drawing connections
			if ( table.Count( ent.GASL_LinkConnections ) > 0 ) then
			
				for k, linkEnt in pairs( ent.GASL_LinkConnections ) do
				
					-- shows connections of input
					if ( IsValid( showConnectionEnt ) || IsValid( lastEnt ) ) then
					
						if ( showConnectionEnt == ent && showConnectionName == k ) then
							surface.SetDrawColor( LinkedSelect )
						else
							surface.SetDrawColor( LinkedColorAlpha )
						end
					
					else
						surface.SetDrawColor( LinkedColor )
					end
					
					if ( IsValid( linkEnt ) ) then
						local vec1 = ent:GetPos():ToScreen()
						local vec2 = linkEnt:GetPos():ToScreen()
						self:DrawConnection( vec1, vec2, LineWidth, PointScale / 2 )
					end
				end
				
				surface.DrawRect( vec.x - PointScale / 2, vec.y - PointScale / 2, PointScale, PointScale )
			end

		end
		
	end
		
	if ( IsValid( traceEnt ) && APERTURESCIENCE:ConnectableStuff( traceEnt ) ) then
	
		local height = 0
		
		if ( !IsValid( lastEnt ) ) then

			if ( traceEnt.GASL_LinkInputs && table.Count( traceEnt.GASL_LinkInputs ) > 0 ) then
			
				local funcColor = function( name )
					
					if ( traceEnt.GASL_LinkConnections && traceEnt.GASL_LinkConnections[ name ] ) then
						surface.SetTextColor( 100, 150, 100, 255 )
					else
						surface.SetTextColor( 100, 100, 100, 255 )
					end
					
					if ( lastInputName == name ) then
						surface.SetTextColor( 50, 50, 50, 255 )
					end
				end
				
				self:DrawMenu( traceEnt.PrintName.." Inputs", table.GetKeys( traceEnt.GASL_LinkInputs ), funcColor, Offset )
				
			end
			
		else
			
			if ( traceEnt.GASL_LinkOutputs && table.Count( traceEnt.GASL_LinkOutputs ) > 0 ) then

				local funcColor = function( name )
					surface.SetTextColor( 100, 100, 100, 255 )
					if ( traceEnt.GASL_LinkConnections && traceEnt.GASL_LinkConnections[ name ] ) then surface.SetTextColor( 100, 255, 100, 255 ) end
					if ( outputName == name ) then surface.SetTextColor( 50, 50, 50, 255 ) end
				end
				
				self:DrawMenu( traceEnt.PrintName.." Outputs", table.GetKeys( traceEnt.GASL_LinkOutputs ), funcColor, Offset )
			end
			
		end
		
	end
	
end

function TOOL:Think()

end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.aperture_science_linker.desc" } )

end

list.Set( "LinkerModels", "models/props/Linker_dynamic.mdl", {} )
list.Set( "LinkerModels", "models/props_underground/underground_Linker_wall.mdl", {} )