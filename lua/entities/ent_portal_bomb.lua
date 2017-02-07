AddCSLuaFile( )

ENT.Type 			= "anim"
ENT.Base 			= "base_entity"
ENT.RenderGroup 	= RENDERGROUP_BOTH

function ENT:Draw()

	self:DrawModel()

end

-- no more client side
if ( CLIENT ) then return end

function ENT:Initialize()

	self:SetModel( "models/npcs/personality_sphere_angry.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_OBB )
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )

	self.GASL_Bomb_disabled = false
	local TrailWidth = 60
	local TrailWidthEnd = 30

	util.SpriteTrail( self, 1, Color( 255, 150, 150 ), false, TrailWidth, TrailWidthEnd, 0.4, 1 / ( TrailWidth + TrailWidthEnd ) * 0.5, "trails/laser.vmt" ) 
	
end

function ENT:Think()

	self:NextThink( CurTime() + 0.05 )
	
	if ( self.GASL_Bomb_disabled || !util.IsInWorld( self:GetPos() ) ) then return end


	local trace = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:GetPos() + self:GetVelocity() / 5,
		ignoreworld = true,
		filter = function( ent )
			if ( ent:GetClass() == "prop_portal" ) then return true end
			if ( APERTURESCIENCE:IsValidEntity( ent ) ) then return false end
		end
	} )
	
	local traceEnt = trace.Entity
	if ( !traceEnt:IsValid() || traceEnt:IsValid() 
		&& ( traceEnt:GetClass() != "prop_portal" || traceEnt:GetClass() == "prop_portal" && !traceEnt:GetNWBool( "Potal:Other" ) ) ) then
		trace = util.TraceLine( {
			start = self:GetPos(),
			endpos = self:GetPos() + self:GetVelocity() / 5,
			filter = function( ent )
				if ( ent:GetClass() == "ent_gel_paint" || ent:GetClass() == "ent_gel_puddle" || ent:GetClass() == "prop_gel_dropper" ) then return false end
			end
		} )
	else
		self:NextThink( CurTime() + 0.5 )
	end
	
	traceEnt = trace.Entity
	
	if ( trace.Hit && ( !traceEnt:IsValid() || traceEnt:IsValid() && traceEnt:GetClass() != "prop_portal" ) ) then
	
		local effectdata = EffectData()
		effectdata:SetOrigin( trace.HitPos )
		effectdata:SetNormal( trace.HitNormal )
		util.Effect( "Explosion", effectdata )

		util.BlastDamage( self, self, trace.HitPos, 150, 50 ) 
		self:Remove()
		
	end
	
	return true

end
