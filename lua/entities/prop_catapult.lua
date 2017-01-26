AddCSLuaFile( )

ENT.Base 			= "base_entity"

ENT.Editable		= true
ENT.PrintName		= "Aerial Faith Plate"
ENT.AutomaticFrameAdvance = true


function ENT:SetupDataTables()

	self:NetworkVar( "Vector", 0, "LandPoint" )
	self:NetworkVar( "Float", 1, "LaunchHeight" )

end


function ENT:Initialize()

	if ( SERVER ) then
		
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self.GASL_Cooldown = 0
		
	end

	if ( CLIENT ) then
	
	end
	
end

function ENT:Draw()

	self:DrawModel()
	
end

function ENT:Think()

	self:NextThink( CurTime() + 0.1 )

	if ( SERVER ) then
	
		if ( self:GetLandPoint() == Vector() ) then return end
		
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
			
			APERTURESCIENCE:PlaySequence( self, "straightup", 1.0 )

			self.GASL_Cooldown = 10
			
			if (trace.Entity:IsPlayer()) then
				trace.Entity:SetVelocity( ( self:GetLandPoint() - self:GetPos() ) / 4 + Vector( 0, 0, self:GetLaunchHeight() ) - trace.Entity:GetVelocity() )
			else
				trace.Entity:GetPhysicsObject():SetVelocity( ( self:GetLandPoint() - trace.Entity:GetPos() ) / 4 + Vector( 0, 0, self:LaunchHeight() * 2 ) )
			end
			
		end
		
		if ( self.GASL_Cooldown > 0 ) then self.GASL_Cooldown = self.GASL_Cooldown - 1
		elseif ( self.GASL_Cooldown < 0 ) then  self.GASL_Cooldown = 0 end
		
	end

	if ( CLIENT ) then
		
	end

	return true
	
end
