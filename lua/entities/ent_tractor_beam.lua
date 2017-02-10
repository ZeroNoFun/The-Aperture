AddCSLuaFile( )

ENT.Base 			= "gasl_base_ent"

ENT.Editable		= true
ENT.PrintName		= "Excursion Funnel"
ENT.Category		= "Aperture Science"
ENT.Spawnable		= true
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !trace.Hit ) then return end
	
	local ent = ents.Create( ClassName )
	ent:SetPos( trace.HitPos + trace.HitNormal * 31 )
	ent:SetAngles( trace.HitNormal:Angle() )
	ent:Spawn()

	return ent

end

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Reverse" )
	self:NetworkVar( "Bool", 1, "Enable" )
	self:NetworkVar( "Bool", 2, "Toggle" )
	self:NetworkVar( "Bool", 3, "StartEnabled" )
	self:NetworkVar( "Bool", 4, "StartReversed" )

end

function ENT:Initialize()

	self.BaseClass.Initialize( self )

	self:PEffectSpawnInit()
	
	self.GASL_FunnelUpdate = { lastPos = Vector(), lastAngle = Angle() }

	if ( SERVER ) then

		self:SetModel( "models/props/tractor_beam_emitter.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:GetPhysicsObject():EnableMotion( false )
		
		self.GASL_TractorBeamLeavedEntities = { }
		self.GASL_TractorBeamFields = { }
		
		self.GASL_EntInfo = { model = "models/tractor_beam_field/tractor_beam_field.mdl", length = 428.5, color = Color( 255, 255, 255 ), angle = Angle( 90, 0, 0 ), parent = true }
		
		self:AddInput( "Enable", function( value ) self:ToggleEnable( value ) end )
		self:AddInput( "Reverse", function( value ) self:ToggleReverse( value ) end )

		if ( !WireAddon ) then return end
		self.Inputs = Wire_CreateInputs( self, { "Enable", "Reverse" } )
		
	end

	if ( CLIENT ) then
	
		self.GASL_ParticleEffect = ParticleEmitter( self:GetPos() )
		self.GASL_ParticleEffectTime = 0
		self.GASL_RotationStep = 0
		
		if ( !self:GetStartEnabled() ) then
			APERTURESCIENCE:PlaySequence( self, "tractor_beam_idle", 1.0 )
		end
		
	end
	
	self:UpdateLabel()
	
end

function ENT:UpdateLabel()

	local enabled, reverse
	if ( self:GetEnable() ) then enabled = 1 else enabled = 0 end
	if ( self:GetReverse() ) then reverse = 1 else reverse = 0 end
	
	self:SetOverlayText( string.format( "Enabled: %i\nReversed: %i", enabled, reverse ) )
	
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
	if ( self.GASL_FunnelUpdate.lastPos != self:GetPos() or self.GASL_FunnelUpdate.lastAngle != self:GetAngles() ) then
		self.GASL_FunnelUpdate.lastPos = self:GetPos()
		self.GASL_FunnelUpdate.lastAngle = self:GetAngles()
		
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
		color = APERTURESCIENCE.FUNNEL_REVERSE_COLOR
		dir = -1
	else
		material = Material( "effects/particle_ring_pulled_add_oriented" )
		color = APERTURESCIENCE.FUNNEL_COLOR
		dir = 1
	end
	
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
				p:SetVelocity( self:GetForward() * APERTURESCIENCE.FUNNEL_MOVE_SPEED * dir + VectorRand() * 5 )
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
			p:SetVelocity( self:GetForward() * APERTURESCIENCE.FUNNEL_MOVE_SPEED * 4 * dir )
			
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
	
	self.BaseClass.Think( self )
	
	if ( CLIENT ) then return end
	
	-- Skip this tick if exursion funnel is disabled and removing effect if possible
	if ( !self:GetEnable() ) then
		
		if ( self.GASL_FunnelUpdate.lastPos == self:GetPos() or self.GASL_FunnelUpdate.lastAngle == self:GetAngles() ) then
			self.GASL_FunnelUpdate.lastPos = { }
			
			-- Removing effects
			self:ClearAllData( )
			self:SetupTrails( )

		end

		return
	end
	
	local TractorBeamEntities = { }
	local FunnelWidth = 60
	
	local passagesPoints = self:GetAllPortalPassages( self:GetPos(), self:GetAngles() )
	
	for k, v in pairs( passagesPoints ) do
		
		local tractorBeamHullFinder = util.TraceHull( {
			start = v.startpos,
			endpos = v.endpos,
			ignoreworld = true,
			filter = function( ent ) 
			
				if ( ent == self ) then return false end
				
				if ( !ent.GASL_Ignore and ( ent:IsPlayer() or ent:IsNPC() or ent:GetPhysicsObject():IsValid() ) ) then 
					
					table.insert( TractorBeamEntities, ent:EntIndex(), ent )
					ent.GASL_TravelingInBeamDir = ( v.endpos - v.startpos ):GetNormalized()
					ent.GASL_TravelingInBeamPos = v.startpos
					
					return false
					
				end
			end,
			mins = -Vector( FunnelWidth, FunnelWidth, FunnelWidth ),
			maxs = Vector( FunnelWidth, FunnelWidth, FunnelWidth ),
			mask = MASK_SHOT_HULL
		} )
		
	end
	
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
		if ( v:GetPhysicsObject():IsValid() ) then
		
			local vPhysObject = v:GetPhysicsObject()
			centerPos = v:LocalToWorld( vPhysObject:GetMassCenter() )
			
		else
			centerPos = v:GetPos()
		end
		
		-- Getting 2d dir to closest point to tractor beam
		local WTL = WorldToLocal( centerPos, Angle(), v.GASL_TravelingInBeamPos, v.GASL_TravelingInBeamDir:Angle() )
		
		local min, max = v:WorldSpaceAABB()
		local entRadius = min:Distance( max ) / 3
		
		WTL = Vector( WTL.x, 0, 0 )
		
		local LTW = LocalToWorld( WTL, Angle(), v.GASL_TravelingInBeamPos, v.GASL_TravelingInBeamDir:Angle() )
		local tractorBeamMovingSpeed = APERTURESCIENCE.FUNNEL_MOVE_SPEED * dir

		-- if( self:GetReverse() ) then
			-- tractorBeamMovingSpeed = APERTURESCIENCE.FUNNEL_MOVE_SPEED * math.min( 1, ( WTL.x - entRadius ) / entRadius ) * dir
		-- else
			-- tractorBeamMovingSpeed = APERTURESCIENCE.FUNNEL_MOVE_SPEED * math.min( 1, ( totalDistance - ( WTL.x + entRadius ) ) / entRadius ) * dir
		-- end
		
		-- Handling entering into Funnel
		if ( !v.GASL_TractorBeamEnter ) then
			
			v.GASL_TractorBeamEnter = true
			
			if ( v:IsPlayer() or v:IsNPC() ) then
			
				if ( v:IsPlayer() ) then

					v:EmitSound( "GASL.TractorBeamEnter" )
					
				end
				
			elseif ( v:GetPhysicsObject():IsValid() ) then
			
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
				
				-- Slowdown player in the funnel when they moving
				if ( v:KeyDown( IN_FORWARD ) 
					|| v:KeyDown( IN_BACK ) 
					|| v:KeyDown( IN_MOVERIGHT ) 
					|| v:KeyDown( IN_MOVELEFT ) ) then
					tractorBeamMovingSpeed = 0
				end

				-- removing player forward/back funnel moving possibilities
				local ply_moving = Vector( forward - back, left - right, 0 ) * 100
				ply_moving:Rotate( v:EyeAngles() )
				
				local ply_moving_cutted_local = WorldToLocal( v.GASL_TravelingInBeamPos + ply_moving, Angle( ), v.GASL_TravelingInBeamPos, v.GASL_TravelingInBeamDir:Angle() )
				ply_moving_cutted_local = Vector( 0, ply_moving_cutted_local.y, ply_moving_cutted_local.z )
				local ply_moving = LocalToWorld( ply_moving_cutted_local, Angle( ), v.GASL_TravelingInBeamPos, v.GASL_TravelingInBeamDir:Angle() ) - v.GASL_TravelingInBeamPos
				
				local vPhysObject = v:GetPhysicsObject()
				
				v:SetVelocity( v.GASL_TravelingInBeamDir * tractorBeamMovingSpeed + ( LTW - centerPos + ply_moving ) * 2 - v:GetVelocity() )
			else
				v:SetVelocity( v.GASL_TravelingInBeamDir * tractorBeamMovingSpeed + ( LTW - centerPos ) * 2 - v:GetVelocity() )
			end
			
		elseif ( v:GetPhysicsObject():IsValid() ) then
			local vPhysObject = v:GetPhysicsObject()
			vPhysObject:SetVelocity( v.GASL_TravelingInBeamDir * tractorBeamMovingSpeed + ( LTW - ( centerPos + vPhysObject:GetMassCenter() ) ) - v:GetVelocity() / 10 )
		end
		
	end
	
	self:CheckForLeave()
	
	self.GASL_TractorBeamLeavedEntities = TractorBeamEntities		
	
	local color
	local angle = 0
	local adding = 0
	
	if( self:GetReverse() ) then
		color = APERTURESCIENCE.FUNNEL_REVERSE_COLOR
		angle = -1
		adding = self.GASL_EntInfo.length
	else
		color = APERTURESCIENCE.FUNNEL_COLOR
		angle = 1
		adding = 0
	end
	
	self.GASL_EntInfo.angleoffset = Angle( angle * 90, 0, 0 )
	self.GASL_EntInfo.posoffset = Vector( adding, 0, 0 )
	self.GASL_EntInfo.color = color
	
	self:MakePEffect()
	
	-- Handling changes position or angles
	if ( self.GASL_FunnelUpdate.lastPos != self:GetPos() or self.GASL_FunnelUpdate.lastAngle != self:GetAngles() ) then
		self.GASL_FunnelUpdate.lastPos = self:GetPos()
		self.GASL_FunnelUpdate.lastAngle = self:GetAngles()
		
	end

	return true
	
end

function ENT:CheckForLeave( )

	if ( !self.GASL_TractorBeamLeavedEntities ) then return end
	
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

-- no more client size
if ( CLIENT ) then return end

function ENT:SetupTrails( )
	
	local TrailWidth = 120
	local TrailWidthEnd = 30
	
	if ( self.GASL_Trail1 && self.GASL_Trail1:IsValid() ) then self.GASL_Trail1:Remove() end
	if ( self.GASL_Trail2 && self.GASL_Trail2:IsValid() ) then self.GASL_Trail2:Remove() end
	if ( self.GASL_Trail3 && self.GASL_Trail3:IsValid() ) then self.GASL_Trail3:Remove() end
	
	if ( self:GetEnable() ) then
	
		local color
		if ( self:GetReverse( ) ) then
			color = APERTURESCIENCE.FUNNEL_REVERSE_COLOR
		else
			color = APERTURESCIENCE.FUNNEL_COLOR
		end
		
		self.GASL_Trail1 = util.SpriteTrail( self, 1, color, false, TrailWidth, TrailWidthEnd, 1, 1 / ( TrailWidth + TrailWidthEnd ) * 0.5, "trails/laser.vmt" ) 
		self.GASL_Trail2 = util.SpriteTrail( self, 3, color, false, TrailWidth, TrailWidthEnd, 1, 1 / ( TrailWidth + TrailWidthEnd ) * 0.5, "trails/laser.vmt" ) 
		self.GASL_Trail3 = util.SpriteTrail( self, 4, color, false, TrailWidth, TrailWidthEnd, 1, 1 / ( TrailWidth + TrailWidthEnd ) * 0.5, "trails/laser.vmt" ) 
		
	end

end

function ENT:TractorBeamEffectRemove( )

	for k, v in pairs( self.GASL_TractorBeamFields ) do
		if ( v:IsValid() ) then v:Remove() end
	end
	
end

function ENT:TractorBeamEffect( distance )
	
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
		color = APERTURESCIENCE.FUNNEL_REVERSE_COLOR
		angle = -1
		adding = PlateLength
	else
		color = APERTURESCIENCE.FUNNEL_COLOR
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

function ENT:TriggerInput( iname, value )
	if ( !WireAddon ) then return end
	
	if ( iname == "Enable" ) then self:ToggleEnable( tobool( value ) ) end
	if ( iname == "Reverse" ) then self:ToggleReverse( tobool( value ) ) end
	
end

function ENT:ToggleEnable( bDown )

	if ( self:GetStartEnabled() ) then bDown = !bDown end

	if ( self:GetToggle() ) then
	
		if ( !bDown ) then return end
		
		self:SetEnable( !self:GetEnable( ) )
	else
		self:SetEnable( bDown )
	end
	
	if ( self:GetEnable( ) ) then
	
		self:EmitSound( "GASL.TractorBeamStart" )
		self:EmitSound( "GASL.TractorBeamLoop" )

		if ( self:GetReverse() ) then
			APERTURESCIENCE:PlaySequence( self, "tractor_beam_turning_reverse", 1.5 )
		else
			APERTURESCIENCE:PlaySequence( self, "tractor_beam_turning", 1.5 )
		end
		
	else
		
		self:StopSound( "GASL.TractorBeamLoop" )
		self:EmitSound( "GASL.TractorBeamEnd" )

		APERTURESCIENCE:PlaySequence( self, "tractor_beam_idle", 1.0 )
	
		self:CheckForLeave()
		
	end
	
end

function ENT:ToggleReverse( bDown )

	if ( self:GetStartReversed() ) then bDown = !bDown end

	if ( self:GetToggle() ) then
	
		if ( !bDown ) then return end
		
		self:SetReverse( !self:GetReverse() )
		
	else
		self:SetReverse( bDown )
	end
	
	if ( self:GetEnable() ) then
	
		if ( self:GetReverse() ) then
			APERTURESCIENCE:PlaySequence( self, "tractor_beam_turning_reverse", 2.0 )
		else
			self.GASL_FunnelUpdate = { }
			APERTURESCIENCE:PlaySequence( self, "tractor_beam_turning", 2.0 )
		end
		
		self:ClearAllData()
		
	end
	
end

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

	if ( keydown ) then ent:ToggleReverse( false ) end
	return true

end )

-- Removing field effect 
function ENT:OnRemove()

	self:CheckForLeave()
	
	self:StopSound( "GASL.TractorBeamLoop" )
	self:TractorBeamEffectRemove( )
	
end
