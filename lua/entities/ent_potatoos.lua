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
	ent.Owner = ply

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

	self:NextThink( CurTime() + 1 )
	
	if ( !self:IsOnFire() ) then
	
		if ( !timer.Exists( "GASL_Timer_PotatoOS_Chat"..self:EntIndex() ) ) then
		
			timer.Create( "GASL_Timer_PotatoOS_Chat"..self:EntIndex(), 10.0, 1, function() end )
			self:EmitSound( "GASL.PotatoOSChat" )
			
		end

	else
		APERTURESCIENCE:GiveAchievement( self.Owner, 2 )
	end
	
	return true

end

function ENT:OnRemove()
	
	timer.Remove( "GASL_Timer_PotatoOS_Chat"..self:EntIndex() )
	
end
