AddCSLuaFile( )

ENT.Type 			= "anim"
ENT.Base 			= "base_entity"

ENT.Editable		= true
ENT.PrintName		= "Aerial Faith Plate"
ENT.Spawnable 		= true
ENT.AdminSpawnable 	= false
ENT.Category		= "Aperture Science"
ENT.AutomaticFrameAdvance = true 

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 5
	local SpawnAng = tr.HitNormal:Angle() + Angle( 90, 0, 0 )
	
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:SetAngles( SpawnAng )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()

	if SERVER then

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		
		self.GASL_Cooldown = 0
		
	end // SERVER

	if ( CLIENT ) then
		
	end // CLIENT
	
end

function ENT:Draw()

	self:DrawModel()
	
end

function ENT:Think()

	self:NextThink( CurTime() + 0.1 )

	if ( SERVER ) then
	
		if ( !self.AFP_LandingPoint ) then return end
		
		local BoxSize = 50
		
		local trace = util.TraceHull( {
			start = self:GetPos(),
			endpos = self:GetPos() + self:GetUp() * BoxSize,
			filter = self,
			ignoreworld = true,
			mins = Vector( -BoxSize, -BoxSize, -BoxSize ),
			maxs = Vector( BoxSize, BoxSize, BoxSize ),
			mask = MASK_SHOT_HULL
		} )
		
		if ( trace.Entity:IsValid() && self.GASL_Cooldown == 0 ) then
			
			APERTURESCIENCE:PlaySequence( self, "straightup" )
			
			self.GASL_Cooldown = 10
			
			if (trace.Entity:IsPlayer()) then
				trace.Entity:SetVelocity( ( self.AFP_LandingPoint - self:GetPos() ) / 4 + Vector( 0, 0, self.AFP_LaunchHight ) - trace.Entity:GetVelocity() )
			else
				trace.Entity:GetPhysicsObject():SetVelocity( ( self.AFP_LandingPoint - trace.Entity:GetPos() ) / 4 + Vector( 0, 0, self.AFP_LaunchHight * 2 ) )
			end
			
		end
		
		if ( self.GASL_Cooldown > 0 ) then self.GASL_Cooldown = self.GASL_Cooldown - 1 end
		
	end // SERVER

	if ( CLIENT ) then
		
	end // CLIENT

	return true
end
