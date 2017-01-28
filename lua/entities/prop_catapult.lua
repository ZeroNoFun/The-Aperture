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
		self.GASL_LaunchedEntities = { }
		self.GASL_TrajectoryCurve = { }
		self.GASL_CatapultUpdate = Vector( )
		
	end

	if ( CLIENT ) then
	
	end
	
end

function ENT:Draw()

	self:DrawModel()
	
end

function ENT:Think()

	self:NextThink( CurTime() )

	if ( SERVER ) then
	
		if ( self:GetLandPoint() == Vector() ) then return end
		
		local FlyingSpeedMult = 4
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
		
		-- Handling catapult location change
		if ( self.GASL_CatapultUpdate != self:GetPos() ) then
			
			self.GASL_CatapultUpdate = self:GetPos()
			
			local startpos = self:GetPos()
			local endpos = self:GetLandPoint()
			local middlepos = ( startpos + endpos ) / 2 + Vector( 0, 0, self:GetLaunchHeight() * 2 )
			
			local dist = startpos:Distance( endpos )
			
			self.GASL_TrajectoryCurve = APERTURESCIENCE:CalcBezierCurvePoint( startpos, middlepos, endpos, 20 )
			
		end
		
		-- launch init
		if ( trace.Entity:IsValid() && ( trace.Entity:IsNPC() || trace.Entity:IsPlayer() || trace.Entity:GetPhysicsObject():IsValid() ) && self.GASL_Cooldown == 0 ) then

			local ent = trace.Entity
			
			APERTURESCIENCE:PlaySequence( self, "straightup", 1.0 )
			
			self:EmitSound( "GASL.CatapultLaunch" )
			EmitSound( "door/heavy_metal_stop1.wav", self:LocalToWorld( Vector( 0, 0, 100 ) ), self:EntIndex(), CHAN_AUTO, 1, 75, 0, 100 )
			
			self.GASL_Cooldown = 10
			if ( !self.GASL_LaunchedEntities[ ent:EntIndex() ] ) then
			
				if ( ent.GASL_CatapultEnt && ent.GASL_CatapultEnt:IsValid() ) then
				
					ent.GASL_CatapultEnt.GASL_LaunchedEntities[ ent:EntIndex() ] = nil
					
				end

				table.insert( self.GASL_LaunchedEntities, ent:EntIndex(), ent )
				ent.GASL_TrajectoryStep = 1
				ent.GASL_CatapultEnt = self
				
			end
			
		end
		
		-- Launch process
		for k, ent in pairs( self.GASL_LaunchedEntities ) do
			
			-- if entity was removed skipping this tick or it enter a tractor beam
			if ( !ent:IsValid() or ent.GASL_TractorBeamEnter ) then
				self.GASL_LaunchedEntities[ k ] = nil
				continue
			end
			
			if ( ent.GASL_TrajectoryStep < table.Count( self.GASL_TrajectoryCurve ) ) then
				
				local vec = self.GASL_TrajectoryCurve[ ent.GASL_TrajectoryStep ]

				local nextVec
				if ( ent.GASL_TrajectoryStep + 1 < table.Count( self.GASL_TrajectoryCurve ) ) then
					nextVec = self.GASL_TrajectoryCurve[ ent.GASL_TrajectoryStep + 1 ]
				else
					nextVec = self:GetLandPoint()
				end
				
				local distBetweenVecs = vec:Distance( nextVec )
				
				local centerPos = Vector()
				if ( ent:GetPhysicsObject() ) then
				
					local vPhysObject = ent:GetPhysicsObject()
					centerPos = ent:LocalToWorld( vPhysObject:GetMassCenter() )
					
				else
					centerPos = ent:GetPos()
				end
				
				local dir = ( vec - centerPos )
				dir:Normalize()
				dir = dir * math.max( 200, math.min( 100, distBetweenVecs ) )
				
				if ( ent:IsPlayer() || ent:IsNPC() ) then
					
					local addingHeight = Vector( )
					if ( ent:IsPlayer() ) then
						 addingHeight = Vector( 0, 0, math.max( 100, distBetweenVecs / 4 ) )
					end
					
					-- releases objects	
					if ( ent.GASL_TrajectoryStep > 1 && ( ent:GetVelocity():Distance( ent.GASL_PrevVel ) > ent.GASL_PrevVel:Length() * 2
					|| ( ent:IsPlayer() && ( ent:KeyDown( IN_DUCK ) || ent:GetVelocity() == Vector() ) ) ) ) then
						ent.GASL_CatapultEnt = nil
						self.GASL_LaunchedEntities[ k ] = nil
					end
					
					dir = Vector( dir.x * 2, dir.y * 2, dir.z * 1.5 )
					ent:SetVelocity( dir * FlyingSpeedMult + addingHeight - ent:GetVelocity() )
					ent.GASL_PrevVel = dir * FlyingSpeedMult + addingHeight
					
				elseif ( ent:GetPhysicsObject() ) then
					
					-- releases objects	
					if ( ent.GASL_TrajectoryStep > 1 && ent:GetPhysicsObject():GetVelocity():Distance( ent.GASL_PrevVel ) > ent.GASL_PrevVel:Length() * 2 ) then
						ent.GASL_CatapultEnt = nil
						self.GASL_LaunchedEntities[ k ] = nil
					end
					
					ent:GetPhysicsObject():SetVelocity( dir * FlyingSpeedMult * 1.75 )
					ent.GASL_PrevVel = ent:GetPhysicsObject():GetVelocity()
					
				end

				-- Changing to next step when reached point in this step
				if ( ent:GetPos():Distance( vec ) < math.max( distBetweenVecs, 200 ) ) then
					
					ent.GASL_TrajectoryStep = ent.GASL_TrajectoryStep + 1
					
				end
			
			else
				-- releases objects	
				ent.GASL_CatapultEnt = nil
				self.GASL_LaunchedEntities[ k ] = nil
			end
		
		end
		
		-- Reseting cooldown
		if ( self.GASL_Cooldown > 0 ) then self.GASL_Cooldown = self.GASL_Cooldown - 1
		elseif ( self.GASL_Cooldown < 0 ) then  self.GASL_Cooldown = 0 end
		
	end

	if ( CLIENT ) then
		
	end

	return true
	
end