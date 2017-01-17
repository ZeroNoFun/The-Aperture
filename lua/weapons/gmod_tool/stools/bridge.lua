TOOL.Category = "Aperture science"
TOOL.Name = "Hard Light Bridge"

if CLIENT then
	language.Add("bridge", "Hard Light Bridge")
	language.Add("Tool.bridge.name", "Hard Light Bridge")
	language.Add("Tool.bridge.desc", "Creates light bridge from 'portal'")
	language.Add("Tool.bridge.0", "Left click to use")
end //CLIENT

if SERVER then

function TOOL:LeftClick( trace )
	if trace.Entity:IsNPC() then return end
	
	ent = ents.Create("prop_wall_projector")
	ent:SetPos(trace.HitPos)
	ent:SetAngles(trace.HitNormal:Angle())
	ent:SetMoveType(MOVETYPE_NONE)
	ent:Spawn()

	undo.Create("Hard Light Bridge")
		undo.AddEntity( ent )
		undo.SetPlayer( self:GetOwner() )
	undo.Finish()
	return true
end

function TOOL:RightClick( trace )
end
 
end //SERVER

function TOOL.BuildCPanel( panel )


end