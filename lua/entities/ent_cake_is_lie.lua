AddCSLuaFile( )

ENT.Base = "base_anim"

ENT.PrintName 		= "Cake is Lie"
ENT.Category 		= "Aperture Science"
ENT.Spawnable 		= true
ENT.Editable		= true
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:Draw()

	self:DrawModel()
	
end

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !trace.Hit ) then return end
	
	if ( !ply.GASL_Counter_CakeSpawned ) then ply.GASL_Counter_CakeSpawned = 0 end
	ply.GASL_Counter_CakeSpawned = ply.GASL_Counter_CakeSpawned + 1

	if ( ply.GASL_Counter_CakeSpawned > 100 ) then
		ply.GASL_Counter_CakeSpawned = 0
		APERTURESCIENCE:GiveAchievement( ply, 4 )
	else
		return
	end
	
	local ent = ents.Create( "prop_physics" )
	ent:SetPos( trace.HitPos )
	ent:SetModel( "models/hunter/plates/plate1x1.mdl" )
	ent:SetAngles( trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
	ent:Spawn()
	ent:Activate()
	ent:SetModel( "models/props/cake/cake.mdl" )

	return ent

end

function ENT:Use( activator, caller, usetype, val )

	if ( IsValid( caller ) && caller:IsPlayer() ) then
		caller:SetHealth( caller:Health() + 1000 )
	end
	
end

-- no more client side
if ( CLIENT ) then return end
