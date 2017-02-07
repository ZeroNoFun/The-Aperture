TOOL.Category = "Aperture Science"
TOOL.Name = "#tool.aperture_science_linker.name"

if ( CLIENT ) then

	language.Add( "aperture_science_linker", "Linker" )
	language.Add( "tool.aperture_science_linker.name", "Linker" )
	language.Add( "tool.aperture_science_linker.desc", "Creates Linker" )
	language.Add( "tool.aperture_science_linker.0", "Left click to link" )
	
	
end

function TOOL:LeftClick( trace )

	-- Ignore if place target is Alive
	if ( trace.Entity && trace.Entity:IsPlayer() ) then return false end
	
	if ( CLIENT ) then return true end
	
	local ply = self:GetOwner()
	
	undo.Create( "Linker" )
		undo.AddEntity( firstLinker )
		undo.AddEntity( secondLinker )
		undo.SetPlayer( ply )
	undo.Finish()
	
	return true
	
end

function TOOL:RightClick( trace )

end

function TOOL:Think()

end


local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.aperture_science_linker.desc" } )

end

list.Set( "LinkerModels", "models/props/Linker_dynamic.mdl", {} )
list.Set( "LinkerModels", "models/props_underground/underground_Linker_wall.mdl", {} )