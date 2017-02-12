AddCSLuaFile( )

ENT.Base = "gasl_base_ent"

ENT.PrintName 		= "PotatOS"
ENT.Category 		= "Aperture Science"
ENT.Spawnable 		= true
ENT.Editable		= true
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:Draw()

	self:DrawModel()
	
	local pos = self:LocalToWorld( Vector( 1.8, 4.7, 7 ) )

	render.SetMaterial( Material( "sprites/orangecore2" ) )
	render.DrawSprite( pos, 4, 4, Color( 255, 255, 255, 255 ) ) 

end

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !trace.Hit ) then return end
	
	local ent = ents.Create( ClassName )
	ent:SetPos( trace.HitPos + trace.HitNormal * 10 )
	ent:SetModel( "models/npcs/potatos/world_model/potatos_wmodel.mdl" )
	ent:SetAngles( trace.HitNormal:Angle() )
	ent:Spawn()
	ent:Activate()

	return ent

end

-- no more client side
if ( CLIENT ) then return end

function ENT:Initialize()

	self:SetModel( "models/npcs/potatos/world_model/potatos_wmodel.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:GetPhysicsObject():Wake()

end

function ENT:Think()

	self:NextThink( CurTime() + 0.05 )
	
	return true

end
