AddCSLuaFile( )

ENT.Base 			= "base_entity"

ENT.Editable		= true
ENT.PrintName		= "Excursion Funnel"
ENT.RenderGroup 	= RENDERGROUP_BOTH

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Reverse" )
	self:NetworkVar( "Bool", 1, "Enable" )
	self:NetworkVar( "Bool", 2, "Toggle" )
	
end

function ENT:Initialize()

	self.GASL_tractor_beam_objects_move_speed = 173
	self.GASL_tractor_beam_color1 = Color( 0, 150, 255 )
	self.GASL_tractor_beam_color2 = Color( 255, 150, 0 )

	if ( SERVER ) then

		self:SetModel( "models/props/tractor_beam_emitter.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		
		self.GASL_TractorBeamLeavedEntities = { }
		self.GASL_TractorBeamFields = { }
		
	end

	if ( CLIENT ) then
	
		self.GASL_ParticleEffect = ParticleEmitter( self:GetPos() )
		self.GASL_ParticleEffectTime = 0
		self.GASL_RotationStep = 0
		
	end
	
	self.GASL_TractorBeamUpdate = 0
end

function ENT:Draw()

	self:DrawModel()
	
	local GASL_FunnelWidth = 60

	local tractorBeamTrace = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:LocalToWorld( Vector( 10000, 0, 0 ) ),
		filter = function( ent ) if ( ent == self or ent:GetClass() == "player" or ent:GetClass() == "prop_physics" ) then return false end end
	} )
	
	local totalDistance = self:GetPos():Distance( tractorBeamTrace.HitPos )

	-- Handling changes position or angles 
	if ( self.GASL_TractorBeamUpdate != totalDistance ) then
		self.GASL_TractorBeamUpdate = totalDistance
		
		local min, max = self:GetRenderBounds() 
		min = Vector()
		max = Vector()
		
		self:SetRenderBounds( min, max, Vector( totalDistance, 0, 0 ) )
	end
	
	-- Skipping tick if it disabled
	if ( !self:GetEnable() ) then return end

	-- Rotation
	local color
	local dir
	local material
	if( self:GetReverse() ) then
		material = Material( "effects/particle_ring_pulled_add_oriented_reverse" )
		color = self.GASL_tractor_beam_color2
		dir = -1
	else
		material = Material( "effects/particle_ring_pulled_add_oriented" )
		color = self.GASL_tractor_beam_color1
		dir = 1
	end
	
	local RotationMult = 0.75
	local Rotation = self.GASL_RotationStep * RotationMult
	self.GASL_RotationStep = self.GASL_RotationStep + dir

	if ( Rotation < -360 ) then self.GASL_RotationStep = 0 end
	if ( Rotation > 360 ) then self.GASL_RotationStep = 0 end
	
	self:ManipulateBoneAngles( 1, Angle( Rotation, 0, 0 ) )
	self:ManipulateBoneAngles( 2, Angle( Rotation, 0, 0 ) )
	self:ManipulateBoneAngles( 3, Angle( Rotation, 0, 0 ) )
	self:ManipulateBoneAngles( 4, Angle( Rotation, 0, 0 ) )
	self:ManipulateBoneAngles( 5, Angle( Rotation * 2, 0, 0 ) )

	-- Tractor beam particle effect 
	local ParticleEffectWidth = 40
	local RotationMultiplier = 2.5
	local QuadRadius = 170

	if ( CurTime() > self.GASL_ParticleEffectTime ) then
		self.GASL_ParticleEffectTime = CurTime() + 0.1
		
		for i = 0, 1, 0.1 do 
			for k = 1, 3 do 
				local cossinValues = CurTime() * RotationMultiplier * dir + ( ( math.pi * 2 ) / 3 ) * k
				local multWidth = i * ParticleEffectWidth
				local localVec = Vector( 30, math.cos( cossinValues ) * multWidth, math.sin( cossinValues ) * multWidth)
				local particlePos = self:LocalToWorld( localVec ) + VectorRand() * 5
				
				local p = self.GASL_ParticleEffect:Add( "sprites/light_glow02_add", particlePos )
				p:SetDieTime( math.random( 1, 2 ) * ( ( 0 - i ) / 2 + 1 ) )
				p:SetStartAlpha( math.random( 0, 50 ) ) 
				p:SetEndAlpha( 255 )
				p:SetStartSize( math.random( 10, 20 ) )
				p:SetEndSize( 0 )
				p:SetVelocity( self:GetForward() * 100 * dir + VectorRand() * 5 )
				p:SetGravity( VectorRand() * 5 )
				p:SetColor( color.r, color.g, color.b )
				p:SetCollide( true )
			end
		end
		
		for repeats = 1, 2 do
			
			local randDist = math.min( totalDistance - GASL_FunnelWidth, math.max( GASL_FunnelWidth, math.random( 0, totalDistance ) ) )
			local randVecNormalized = VectorRand()
			randVecNormalized:Normalize()
			
			local particlePos = self:LocalToWorld( Vector( randDist, 0, 0 ) + randVecNormalized * GASL_FunnelWidth )
			
			local p = self.GASL_ParticleEffect:Add( "sprites/light_glow02_add", particlePos )
			p:SetDieTime( math.random( 3, 5 ) )
			p:SetStartAlpha( math.random( 200, 255 ) )
			p:SetEndAlpha( 0 )
			p:SetStartSize( math.random( 5, 10 ) )
			p:SetEndSize( 0 )
			p:SetVelocity( self:GetForward() * self.GASL_tractor_beam_objects_move_speed * 4 * dir )
			
			p:SetColor( color.r, color.g, color.b )
			p:SetCollide( true )
			
		end
	end
	
	render.SetMaterial( material )
	render.DrawQuadEasy( tractorBeamTrace.HitPos, tractorBeamTrace.HitNormal, QuadRadius, QuadRadius, color, ( CurTime() * 10 ) * -dir )
	render.DrawQuadEasy( tractorBeamTrace.HitPos, tractorBeamTrace.HitNormal, QuadRadius, QuadRadius, color, ( CurTime() * 10 ) * -dir + 120 )
	render.DrawQuadEasy( tractorBeamTrace.HitPos, tractorBeamTrace.HitNormal, QuadRadius, QuadRadius, color, ( CurTime() * 10 ) * -dir * 2 )
end

function ENT:Think()

	self:NextThink( CurTime() )

	if ( SERVER ) then
		
		-- Skip this tick if exursion funnel is disabled and removing effect if possible
		if ( !self:GetEnable() ) then
			
			if ( self.GASL_TractorBeamUpdate != 0 ) then
			
				self.GASL_TractorBeamUpdate = 0
				
				-- Removing preview field effect
				self:TractorBeamEffectRemove( )
				
			end

			return
		end
		
		local TractorBeamEntities = { }
		local FunnelWidth = 60
		
		local tractorBeamTrace = util.TraceLine( {
			start = self:GetPos(),
			endpos = self:LocalToWorld( Vector( 10000, 0, 0) ),
			filter = function( ent ) if ( ent == self or ent:GetClass() == "player" or ent:GetClass() == "prop_physics" ) then return false end end
		} )
		
		local totalDistance = self:GetPos():Distance( tractorBeamTrace.HitPos )
		
		local tractorBeamHullFinder = util.TraceHull( {
			start = self:GetPos(),
			endpos = self:LocalToWorld( Vector( totalDistance, 0, 0 ) ),
			ignoreworld = true,
			filter = function( ent ) 
			
				if ( ent == self ) then return false end
				
				if ( not ent.GASL_Ignore and ( ent:IsPlayer() or ent:IsNPC() or ent:GetPhysicsObject() ) ) then 
					
					table.insert( TractorBeamEntities, ent:EntIndex(), ent )
					
					return false
					
				end
			end,
			mins = -Vector( FunnelWidth, FunnelWidth, FunnelWidth ),
			maxs = Vector( FunnelWidth, FunnelWidth, FunnelWidth ),
			mask = MASK_SHOT_HULL
		} )
		
		local dir
		if( self:GetReverse() ) then
			dir = -1
		else
			dir = 1
		end
		
		-- Handling entities in field 
		for k, v in pairs( TractorBeamEntities ) do
		
			if ( not v:IsValid() ) then break end
			
			-- Removing entity from table if it still in funnel
			self.GASL_TractorBeamLeavedEntities[ k ] = nil
			
			local centerPos = Vector()
			
			if ( v:GetPhysicsObject() ) then
			
				local vPhysObject = v:GetPhysicsObject()
				centerPos = v:LocalToWorld( vPhysObject:GetMassCenter() )
				
			else
				centerPos = v:GetPos()
			end
			
			local WTL = self:WorldToLocal( centerPos )
			local min, max = v:WorldSpaceAABB()
			local entRadius = min:Distance( max ) / 3
			
			WTL = Vector( WTL.x, 0, 0 )
			
			local LTW = self:LocalToWorld( WTL )
			local tractorBeamMovingSpeed = self.GASL_tractor_beam_objects_move_speed * math.min( 1, ( totalDistance - ( WTL.x + entRadius ) ) / entRadius ) * dir

			if( self:GetReverse() ) then
				tractorBeamMovingSpeed = self.GASL_tractor_beam_objects_move_speed * math.min( 1, ( WTL.x - entRadius ) / entRadius ) * dir
			else
				tractorBeamMovingSpeed = self.GASL_tractor_beam_objects_move_speed * math.min( 1, ( totalDistance - ( WTL.x + entRadius ) ) / entRadius ) * dir
			end
			
			if ( !v.GASL_TractorBeamEnter ) then
				
				v.GASL_TractorBeamEnter = true
				
				if ( v:IsPlayer() or v:IsNPC() ) then
				
					if ( v:IsPlayer() ) then

						v:EmitSound( "GASL.TractorBeamEnter" )
						
					end
					
				elseif ( v:GetPhysicsObject() ) then
				
					local vPhysObject = v:GetPhysicsObject()
					vPhysObject:EnableGravity( false )
					
				end
				
			end
			
			if ( v:IsPlayer() or v:IsNPC() ) then
			
				if ( v:IsPlayer() ) then

					-- Player moving while in the funnel
					local forward, back, right, left, up, down
					
					if ( v:KeyDown( IN_FORWARD ) ) then forward = 1 else forward = 0 end
					if ( v:KeyDown( IN_BACK ) ) then back = 1 else back = 0 end
					if ( v:KeyDown( IN_MOVERIGHT ) ) then right = 1 else right = 0 end
					if ( v:KeyDown( IN_MOVELEFT ) ) then left = 1 else left = 0 end
					if ( v:KeyDown( IN_JUMP ) ) then up = 1 else up = 0 end
					if ( v:KeyDown( IN_DUCK ) ) then down = 1 else down = 0 end
					
					-- Slowdown player in the funnel when they moving
					if ( v:KeyDown( IN_FORWARD ) 
						|| v:KeyDown( IN_BACK ) 
						|| v:KeyDown( IN_MOVERIGHT ) 
						|| v:KeyDown( IN_MOVELEFT ) 
						|| v:KeyDown( IN_JUMP ) 
						|| v:KeyDown( IN_DUCK ) ) then
						tractorBeamMovingSpeed = 0
					end

					local ply_moving = Vector( forward - back, left - right, up - down ) * 100
					ply_moving:Rotate( v:EyeAngles() )
					
					local ply_moving_cutted_local = self:WorldToLocal( self:GetPos() + ply_moving )
					ply_moving_cutted_local = Vector( 0, ply_moving_cutted_local.y, ply_moving_cutted_local.z )
					local ply_moving = self:LocalToWorld( ply_moving_cutted_local ) - self:GetPos()
					
					local vPhysObject = v:GetPhysicsObject()
					
					v:SetVelocity( self:GetForward() * tractorBeamMovingSpeed + ( LTW - centerPos + ply_moving ) * 2 - v:GetVelocity() )
				else
					v:SetVelocity( self:GetForward() * tractorBeamMovingSpeed + ( LTW - centerPos ) * 2 - v:GetVelocity() )
				end
				
			elseif ( v:GetPhysicsObject() ) then
				local vPhysObject = v:GetPhysicsObject()
				vPhysObject:SetVelocity( self:GetForward() * tractorBeamMovingSpeed + ( LTW - ( centerPos + vPhysObject:GetMassCenter() ) ) - v:GetVelocity() / 10 )
			end
			
		end
		
		self:CheckForLeave()
		
		self.GASL_TractorBeamLeavedEntities = TractorBeamEntities
				
		-- Handling if effect need change
		if ( self.GASL_TractorBeamUpdate != totalDistance ) then
		
			self.GASL_TractorBeamUpdate = totalDistance
			
			self:TractorBeamEffect( totalDistance )
		
		end
	end


	if ( CLIENT ) then

	end

	return true
	
end

function ENT:CheckForLeave( )

	for k, v in pairs( self.GASL_TractorBeamLeavedEntities ) do
		
		if ( not v:IsValid( ) ) then break end
		
		if ( v:IsPlayer( ) or v:IsNPC( ) ) then
		
			if( v:IsPlayer( ) ) then
				v:StopSound( "GASL.TractorBeamEnter" )
			end
		
		else
			v:GetPhysicsObject():EnableGravity( true )
		end
		
		v.GASL_TractorBeamEnter = false
		
	end
	
end

function ENT:SetupTrails( )
	
	local TrailWidth = 120
	local TrailWidthEnd = 30
	
	if ( self.GASL_Trail1 && self.GASL_Trail1:IsValid() ) then self.GASL_Trail1:Remove() end
	if ( self.GASL_Trail2 && self.GASL_Trail2:IsValid() ) then self.GASL_Trail2:Remove() end
	if ( self.GASL_Trail3 && self.GASL_Trail3:IsValid() ) then self.GASL_Trail3:Remove() end
	
	local color
	if( self:GetReverse() ) then
		color = self.GASL_tractor_beam_color2
	else
		color = self.GASL_tractor_beam_color1
	end
	
	self.GASL_Trail1 = util.SpriteTrail( self, 1, color, false, TrailWidth, TrailWidthEnd, 1, 1 / ( TrailWidth + TrailWidthEnd ) * 0.5, "trails/laser.vmt" ) 
	self.GASL_Trail2 = util.SpriteTrail( self, 3, color, false, TrailWidth, TrailWidthEnd, 1, 1 / ( TrailWidth + TrailWidthEnd ) * 0.5, "trails/laser.vmt" ) 
	self.GASL_Trail3 = util.SpriteTrail( self, 4, color, false, TrailWidth, TrailWidthEnd, 1, 1 / ( TrailWidth + TrailWidthEnd ) * 0.5, "trails/laser.vmt" ) 

end

function ENT:TractorBeamEffectRemove( )

	for k, v in pairs( self.GASL_TractorBeamFields ) do
		if ( v:IsValid() ) then
			v:Remove()
		end
	end
	
end

function ENT:TractorBeamEffect( distance )

	if ( CLIENT ) then return end
	
	self:SetupTrails()
	
	local PlateLength = 428.5
	
	-- Removing preview field effect
	self:TractorBeamEffectRemove( )
	
	-- Spawning field effect 
	local addingDist = 0
	
	local color
	local angle
	local adding
	
	if( self:GetReverse() ) then
		color = self.GASL_tractor_beam_color2
		angle = -1
		adding = PlateLength
	else
		color = self.GASL_tractor_beam_color1
		angle = 1
		adding = 0
	end
		
	while ( distance > addingDist ) do
		
		local ent = ents.Create( "prop_physics" )
		ent:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )
		ent:SetPos( self:LocalToWorld( Vector( addingDist + adding, 0, -1 ) ) )
		ent:SetAngles( self:LocalToWorldAngles( Angle( 90 * angle, 0, 0 ) ) )
		ent:SetParent( self )
		ent:Spawn()
		
		ent:DrawShadow( false )
		ent:SetModel( "models/tractor_beam_field/tractor_beam_field.mdl" )
		ent.GASLIgnore = true
		ent:SetColor( color )
		
		local physEnt = ent:GetPhysicsObject()
		physEnt:EnableMotion( false )
		physEnt:EnableCollisions( false )
		table.insert( self.GASL_TractorBeamFields, table.Count( self.GASL_TractorBeamFields ) + 1, ent )

		addingDist = addingDist + PlateLength
	end
	
end

function ENT:ToggleEnable( bDown )

	if ( self:GetToggle( ) ) then
	
		if ( !bDown ) then return end
		
		self:SetEnable( !self:GetEnable( ) )
	else
		self:SetEnable( bDown )
	end
	
	if ( self:GetEnable( ) ) then
		self:EmitSound( "GASL.TractorBeamStart" )
		self:EmitSound( "GASL.TractorBeamLoop" )
	else
	
		self:CheckForLeave()
		
		self:StopSound( "GASL.TractorBeamLoop" )
		self:EmitSound( "GASL.TractorBeamEnd" )
		
	end
	
end

function ENT:ToggleReverse( bDown )

	if ( self:GetToggle() ) then
	
		if ( !bDown ) then return end
		
		self:SetReverse( !self:GetReverse() )
		
	else
		self:SetReverse( bDown )
	end
	
	if ( self:GetEnable() ) then self.GASL_TractorBeamUpdate = 0 end
	
end

if ( SERVER ) then

	numpad.Register( "aperture_science_tractor_beam_enable", function( pl, ent, keydown, idx )

		if ( !IsValid( ent ) ) then return false end

		if ( keydown ) then ent:ToggleEnable( true ) end
		return true

	end )

	numpad.Register( "aperture_science_tractor_beam_disable", function( pl, ent, keydown )

		if ( !IsValid( ent ) ) then return false end

		if ( keydown ) then ent:ToggleEnable( false ) end
		return true

	end )
	
	numpad.Register( "aperture_science_tractor_beam_reverse_back", function( pl, ent, keydown )

		if ( !IsValid( ent ) ) then return false end

		if ( keydown ) then ent:ToggleReverse( true ) end
		return true

	end )

	numpad.Register( "aperture_science_tractor_beam_reverse_forward", function( pl, ent, keydown )

		if ( !IsValid( ent ) ) then return false end

		if ( keydown ) then ent:ToggleReverse( false ) ent.GASL_TractorBeamUpdate = 0 end
		return true

	end )

	-- Removing field effect 
	function ENT:OnRemove()
	
		self:CheckForLeave()
		
		self:StopSound( "GASL.TractorBeamLoop" )
		self:TractorBeamEffectRemove( )
		
	end
	
end

