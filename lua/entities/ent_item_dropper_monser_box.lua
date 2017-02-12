AddCSLuaFile( )
DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "Dropper (Franken Cube)"
ENT.Category		= "Aperture Science"
ENT.Editable		= true
ENT.Spawnable		= true
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SpawnFunction( ply, trace )

	if ( !trace.Hit ) then return end
	
	local normal = trace.HitNormal
	normal = Vector( math.Round( normal.x ), math.Round( normal.y ), math.Round( normal.z ) )
	if ( normal != Vector( 0, 0, -1 ) ) then return end

	local ent = ents.Create( "ent_item_dropper" )
	ent:SetPos( trace.HitPos + trace.HitNormal * 85 )
	ent:SetAngles( trace.HitNormal:Angle() - Angle( 90, 0, 0 ) )
	ent:Spawn()
	ent:Activate()
	ent:SetDropType( 4 )

	return ent

end