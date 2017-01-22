AddCSLuaFile( )

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"

ENT.Editable		= true
ENT.PrintName		= "Tractor Beam"
ENT.Spawnable 		= true
ENT.AdminSpawnable 	= false
ENT.Category		= "Aperture Science"
ENT.AutomaticFrameAdvance = true 

local tractor_beam_objects_move_speed = 150

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos
	local SpawnAng = tr.HitNormal:Angle()
	
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:SetAngles( SpawnAng )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()

	if SERVER then

		self:SetModel( "models/props/tractor_beam_emitter.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		
		self.GASL_TractorBeamFields = { }
	end // SERVER

	if CLIENT  then
		self.GASL_ParticleEffect = GASL_ParticleEffect( self:GetPos() )
		self.GASL_ParticleEffectTime = 0
	end // CLIENT
	
	self.GASL_TractorBeamUpdate = { }
end

function ENT:Draw()

	self:DrawModel()
	
	local GASL_FunnelWidth = 60

	local tractorBeamTrace = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:LocalToWorld(Vector(10000, 0, 0)),
		filter = function( ent ) if ( ent == self or ent:GetClass() == "player" or ent:GetClass() == "prop_physics" ) then return false end end
	} )
	
	local totalDistance = self:GetPos():Distance(tractorBeamTrace.HitPos)

	-- Handling changes position or angles 
	if ( self.GASL_TractorBeamUpdate.lastPos != self:GetPos() or self.GASL_TractorBeamUpdate.lastAngle != self:GetAngles() ) then
		self.GASL_TractorBeamUpdate.lastPos = self:GetPos()
		self.GASL_TractorBeamUpdate.lastAngle = self:GetAngles()
		
		local min, max = self:GetRenderBounds() 
		self:SetRenderBounds( min, max + Vector( totalDistance, 0, 0 ) )
	end
	
	-- Tractor beam particle effect 
	local ParticleEffectWidth = 60
	local RotationMultiplier = 2.5
	
	if (CurTime() > self.GASL_ParticleEffectTime) then
		self.GASL_ParticleEffectTime = CurTime() + 0.1
		
		for i = 0, 1, 0.1 do 
			for k = 1, 3 do 
				local cossinValues = CurTime() * RotationMultiplier +  ( ( math.pi * 2 ) / 3 ) * k
				local multWidth = i * ParticleEffectWidth
				local localVec = Vector(10, math.cos( cossinValues ) * multWidth, math.sin( cossinValues ) * multWidth)
				local particlePos = self:LocalToWorld( localVec ) + VectorRand() * 5
				
				local p = self.GASL_ParticleEffect:Add( "sprites/light_glow02_add", particlePos )
				p:SetDieTime( math.random( 1, 2 ) * ( ( 0 - i ) / 2 + 1 ) )
				p:SetStartAlpha( math.random( 0, 50 ) ) 
				p:SetEndAlpha( 255 )
				p:SetStartSize( math.random( 10, 20 ) )
				p:SetEndSize( 0 )
				p:SetVelocity( self:GetForward() * 100 + VectorRand() * 5 )
				p:SetGravity( VectorRand() * 5 )
				p:SetColor( math.random( 0, 50 ), 100 + math.random( 0, 55 ), 200 + math.random( 0, 50 ) )
				p:SetCollide( true )
			end
		end
		
		local randDist = math.min( totalDistance - GASL_FunnelWidth, math.max( GASL_FunnelWidth, math.random( 0, totalDistance ) ) )
		local randVecNormalized = VectorRand()
		randVecNormalized:Normalize()
		
		local particlePos = self:LocalToWorld( Vector( randDist, 0, 0 ) + randVecNormalized * GASL_FunnelWidth )
		
		local p = self.GASL_ParticleEffect:Add( "sprites/light_glow02_add", particlePos )
		p:SetDieTime( math.random( 3, 5 ) )
		p:SetStartAlpha( math.random( 0, 50 ) )
		p:SetEndAlpha( 255 )
		p:SetStartSize( math.random( 1, 5 ) )
		p:SetEndSize( 0 )
		p:SetVelocity( self:GetForward() * 150 )
		
		p:SetColor( math.random( 0, 50 ), 100 + math.random( 0, 55 ), 200 + math.random( 0, 50 ) )
		p:SetCollide( true )
	end
end

function ENT:Think()

	self:NextThink( CurTime() + 0.1 )

	if SERVER then
		
		local PlateLength = 428.5
		local TractorBeamEntities = { }
		local FunnelWidth = 60
			
		local effectdata = EffectData()
		effectdata:SetOrigin( self:LocalToWorld( Vector( 0, 0, 10 ) ) )
		effectdata:SetNormal( self:GetUp() )

		local tractorBeamTrace = util.TraceLine( {
			start = self:GetPos(),
			endpos = self:LocalToWorld( Vector( 10000, 0, 0) ),
			filter = function( ent ) if ( ent == self or ent:GetClass() == "player" or ent:GetClass() == "prop_physics" ) then return false end end
		} )
		
		local totalDistance = self:GetPos():Distance(tractorBeamTrace.HitPos)
		
		local tractorBeamHullFinder = util.TraceHull( {
			start = self:GetPos(),
			endpos = self:LocalToWorld( Vector( totalDistance, 0, 0 ) ),
			ignoreworld = true,
			filter = function( ent ) 
				if ( ent == self ) then return false end
				
				if ( not ent.GASLIgnore 
					and (ent:IsPlayer() or ent:IsNPC() or ent:GetPhysicsObject() ) ) then 
					
					table.insert( TractorBeamEntities, table.Count( TractorBeamEntities ) + 1, ent )
					return false
				end
			end,
			mins = -Vector( FunnelWidth, FunnelWidth, FunnelWidth ),
			maxs = Vector( FunnelWidth, FunnelWidth, FunnelWidth ),
			mask = MASK_SHOT_HULL
		} )
		
		-- Handling entities in field 
		for k, v in pairs( TractorBeamEntities ) do
			if ( not v:IsValid() ) then break end
			
			local centerPos = Vector()
			
			if ( v:GetPhysicsObject() ) then
				local vPhysObject = v:GetPhysicsObject()
				centerPos = v:LocalToWorld( vPhysObject:GetMassCenter() )
			else
				centerPos = v:GetPos()
			end
			
			local WTL = self:WorldToLocal( centerPos )
			local min, max = v:WorldSpaceAABB()
			local entRadius = min:Distance( max )
			
			WTL = Vector( WTL.x, 0, 0 )
			
			local LTW = self:LocalToWorld( WTL )
			local tractorBeamMovingSpeed = tractor_beam_objects_move_speed * math.min( 1, ( totalDistance - ( WTL.x + 50 ) ) / 50 )
			
			if ( v:IsPlayer() or v:IsNPC() ) then
				if ( v:IsPlayer() ) then

					local forward, back, right, left, up, down
					
					if ( v:KeyDown(IN_FORWARD) ) then forward = 1 else forward = 0 end
					if ( v:KeyDown(IN_BACK) ) then back = 1 else back = 0 end
					if ( v:KeyDown(IN_MOVERIGHT) ) then right = 1 else right = 0 end
					if ( v:KeyDown(IN_MOVELEFT) ) then left = 1 else left = 0 end
					if ( v:KeyDown(IN_JUMP) ) then up = 1 else up = 0 end
					if ( v:KeyDown(IN_DUCK) ) then down = 1 else down = 0 end

					local ply_moving = Vector( forward - back, left - right, up - down ) * 100
					ply_moving:Rotate( v:EyeAngles() )
					
					local ply_moving_cutted_local = self:WorldToLocal( self:GetPos() + ply_moving )
					ply_moving_cutted_local = Vector( 0, ply_moving_cutted_local.y, ply_moving_cutted_local.z )
					local ply_moving = self:LocalToWorld( ply_moving_cutted_local ) - self:GetPos()
					
					local vPhysObject = v:GetPhysicsObject()
					
					v:SetVelocity( self:GetForward() * tractorBeamMovingSpeed + ( LTW - centerPos + ply_moving ) * 2 - v:GetVelocity() )
				else
					v:SetVelocity( self:GetForward() * tractor_beam_objects_move_speed + ( LTW - centerPos ) * 2 - v:GetVelocity() )
				end
			elseif ( v:GetPhysicsObject() ) then
				local vPhysObject = v:GetPhysicsObject()
				vPhysObject:SetVelocity( self:GetForward() * tractor_beam_objects_move_speed + ( LTW - ( centerPos + vPhysObject:GetMassCenter() ) ) - v:GetVelocity() / 10 )
				vPhysObject:EnableGravity( false )
			end
		end
		
		-- Handling changes position or angles 
		if ( self.GASL_TractorBeamUpdate.lastPos != self:GetPos() or self.GASL_TractorBeamUpdate.lastAngle != self:GetAngles() ) then
			self.GASL_TractorBeamUpdate.lastPos = self:GetPos()
			self.GASL_TractorBeamUpdate.lastAngle = self:GetAngles()

			-- Spawning field effect 
			for k, v in pairs( self.GASL_TractorBeamFields ) do
				if ( v:IsValid() ) then v:Remove() end
			end
			
			local addingDist = 0
			
			while ( totalDistance > addingDist ) do
			
				local ent = ents.Create( "prop_physics" )
				ent:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )
				ent:SetPos( self:LocalToWorld( Vector( addingDist, 0, -1 ) ) )
				ent:SetAngles( self:LocalToWorldAngles( Angle( 90, 0, 0 ) ) )
				ent:Spawn()
				ent:DrawShadow( false )
				ent:SetModel( "models/tractor_beam_field/tractor_beam_field.mdl" )
				ent.GASLIgnore = true
				
				local physEnt = ent:GetPhysicsObject()
				physEnt:EnableMotion( false )
				physEnt:EnableCollisions( false )
				table.insert( self.GASL_TractorBeamFields, table.Count( self.GASL_TractorBeamFields ) + 1, ent )

				addingDist = addingDist + PlateLength
			end
		end
	end // SERVER

	if CLIENT then

	end // CLIENT

	return true
end

if SERVER then
	-- Deleting field effect 
	function ENT:OnRemove()
		for k, v in pairs(self.GASL_TractorBeamFields) do
			if (v:IsValid()) then v:Remove() end
		end
	end
end // SERVER

