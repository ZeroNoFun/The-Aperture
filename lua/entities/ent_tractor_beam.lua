AddCSLuaFile( )

ENT.Base = "gasl_base_ent"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !APERTURESCIENCE.ALLOWING.tractor_beam && !ply:IsSuperAdmin() ) then ply:PrintMessage( HUD_PRINTTALK, "This entity is blocked" ) return end

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
	self:NetworkVar( "Bool", 2, "StartEnabled" )
	self:NetworkVar( "Bool", 3, "StartReversed" )

end

function ENT:Initialize()

	self.BaseClass.Initialize( self )

	//self:PEffectSpawnInit()
	
	self.GASL_FunnelUpdate = { lastPos = Vector(), lastAngle = Angle() }

	if ( SERVER ) then

		self:SetModel( "models/gasl/tractor_beam_128.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:GetPhysicsObject():EnableMotion( false )
		
		self.GASL_TractorBeamLeavedEntities = { }
		//self.GASL_EntInfo = { model = "models/gasl/tractor_beam_field_effect.mdl", length = 320, color = Color( 255, 255, 255 ), angle = Angle( -90, 0, 0 ), parent = true }
		
		self:AddInput( "Enable", function( value ) self:ToggleEnable( value ) end )
		self:AddInput( "Reverse", function( value ) self:ToggleReverse( value ) end )

		if ( !WireAddon ) then return end
		self.Inputs = Wire_CreateInputs( self, { "Enable", "Reverse" } )
		
	end

	if ( CLIENT ) then
	
		self.GASL_ParticleEffect = ParticleEmitter( self:GetPos() )
		self.GASL_ParticleEffectTime = 0
		self.GASL_RotationStep = 0
		self.FieldEffects = { }
		self.BaseRotation = 0

		local min, max = self:GetRenderBounds()
		self.RenderBounds = { mins = min, maxs = max }
		
		if ( !self:GetStartEnabled() ) then
			//APERTURESCIENCE:PlaySequence( self, "tractor_beam_idle", 1.0 )
		end
		
	end
	
end

function ENT:Draw()

	self:DrawModel()
	
end

function ENT:Drawing()

	-- Skipping tick if it disabled
	if ( !self:GetEnable() ) then return end

	local Reverse = self:GetReverse()
	local color = Reverse and APERTURESCIENCE.FUNNEL_REVERSE_COLOR or APERTURESCIENCE.FUNNEL_COLOR
	local dir = Reverse and -1 or 1
	local material = Reverse and Material( "effects/particle_ring_pulled_add_oriented_reverse" ) or Material( "effects/particle_ring_pulled_add_oriented" )

	//render.SetLightingMode( 1 )
	render.SuppressEngineLighting( true ) 
	render.SetColorModulation( color.r / 255, color.g / 255, color.b / 255 )
	//render.SetBlend( 0.5 )
	//render.SetShadowColor( 0, 0, 0 ) 
	//render.ResetModelLighting( 0, 0, 0 )
	if ( self.FieldEffects ) then
		for k, v in pairs( self.FieldEffects ) do
			v:DrawModel()
		end
	end
	//render.SetLightingMode( 0 )
	render.SuppressEngineLighting( false ) 
	render.SetColorModulation( 1, 1, 1 )
	//render.SetBlend( 1 )

	local GASL_FunnelWidth = 60
	
	-- Tractor beam particle effect 
	local ParticleEffectWidth = 40
	local RotationMultiplier = 2.5
	local QuadRadius = 140

	local tractorBeamTrace = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:LocalToWorld( Vector( 0, 0, 1000000 ) ),
		filter = function( ent )
			if ( ent == self || ent:GetClass() == "prop_portal" || ent:IsPlayer() || ent:IsNPC() ) then
				return false end
		end
	} )
	local totalDistance = self:GetPos():Distance( tractorBeamTrace.HitPos )

	if ( CurTime() > self.GASL_ParticleEffectTime ) then
		self.GASL_ParticleEffectTime = CurTime() + 0.1
		
		for i = 0, 1, 0.1 do 
			for k = 1, 3 do 
				local cossinValues = CurTime() * RotationMultiplier * dir + ( ( math.pi * 2 ) / 3 ) * k
				local multWidth = i * ParticleEffectWidth
				local localVec = Vector( math.cos( cossinValues ) * multWidth, math.sin( cossinValues ) * multWidth, 30 )
				local particlePos = self:LocalToWorld( localVec ) + VectorRand() * 5
				
				local p = self.GASL_ParticleEffect:Add( "sprites/light_glow02_add", particlePos )
				p:SetDieTime( math.random( 1, 2 ) * ( ( 0 - i ) / 2 + 1 ) )
				p:SetStartAlpha( math.random( 0, 50 ) ) 
				p:SetEndAlpha( 255 )
				p:SetStartSize( math.random( 10, 20 ) )
				p:SetEndSize( 0 )
				p:SetVelocity( self:GetUp() * APERTURESCIENCE.FUNNEL_MOVE_SPEED * dir + VectorRand() * 5 )
				p:SetGravity( VectorRand() * 5 )
				p:SetColor( color.r, color.g, color.b )
				p:SetCollide( true )
			end
		end

		for repeats = 1, 2 do
			
			local randDist = math.min( totalDistance - GASL_FunnelWidth, math.max( GASL_FunnelWidth, math.random( 0, totalDistance ) ) )
			local randVecNormalized = VectorRand()
			randVecNormalized:Normalize()
			
			local particlePos = self:LocalToWorld( Vector( 0, 0, randDist ) + randVecNormalized * GASL_FunnelWidth )
			
			local p = self.GASL_ParticleEffect:Add( "sprites/light_glow02_add", particlePos )
			p:SetDieTime( math.random( 3, 5 ) )
			p:SetStartAlpha( math.random( 200, 255 ) )
			p:SetEndAlpha( 0 )
			p:SetStartSize( math.random( 5, 10 ) )
			p:SetEndSize( 0 )
			p:SetVelocity( self:GetUp() * APERTURESCIENCE.FUNNEL_MOVE_SPEED * 4 * dir )
			
			p:SetColor( color.r, color.g, color.b )
			p:SetCollide( true )
			
		end
	end

	render.SetMaterial( material )
	render.DrawQuadEasy( tractorBeamTrace.HitPos + tractorBeamTrace.HitNormal, tractorBeamTrace.HitNormal, QuadRadius, QuadRadius, color, ( CurTime() * 10 ) * -dir )
	render.DrawQuadEasy( tractorBeamTrace.HitPos + tractorBeamTrace.HitNormal, tractorBeamTrace.HitNormal, QuadRadius, QuadRadius, color, ( CurTime() * 10 ) * -dir + 120 )
	render.DrawQuadEasy( tractorBeamTrace.HitPos + tractorBeamTrace.HitNormal, tractorBeamTrace.HitNormal, QuadRadius, QuadRadius, color, ( CurTime() * 10 ) * -dir * 2 )

end

if ( CLIENT ) then

	function ENT:OnRemove()
	
		for k, v in pairs( self.FieldEffects ) do
			v:Remove()
		end

	end

	function ENT:Think()			

		//self.BaseClass.Think( self )
		local Reverse = self:GetReverse()
		local color = Reverse and APERTURESCIENCE.FUNNEL_REVERSE_COLOR or APERTURESCIENCE.FUNNEL_COLOR
		local dir = Reverse and -1 or 1
		local angle = Reverse and -90 or 90
		local offset = Reverse and 320 or 0

		-- local tractorBeamTrace = util.TraceLine( {
			-- start = self:GetPos(),
			-- endpos = self:LocalToWorld( Vector( 0, 0, 1000000 ) ),
			-- filter = function( ent )
				-- if ( ent == self || ent:GetClass() == "prop_portal" || ent:IsPlayer() || ent:IsNPC() ) then
					-- return false end
			-- end
		-- } )
		-- local totalDistance = self:GetPos():Distance( tractorBeamTrace.HitPos )

		-- Handling changes in distance to funnel end
		self:SetRenderBounds( self.RenderBounds.mins, self.RenderBounds.maxs + Vector( 0, 0, 1000 ), 0 )
		
		local PassagesPoints = self:GetAllPortalPassages( self:GetPos(), self:LocalToWorldAngles( Angle( -90, 0, 0 ) ) )
		local RequireToSpawn = table.Count( PassagesPoints )
		for k, v in pairs( PassagesPoints ) do
			RequireToSpawn = RequireToSpawn + math.floor( v.startpos:Distance( v.endpos ) / 320 )
		end

		if ( table.Count( self.FieldEffects ) != RequireToSpawn || !self:GetEnable() ) then
			for k, v in pairs( self.FieldEffects ) do
				v:Remove()
			end
			self.FieldEffects = { }
		end
		
		if ( self:GetEnable() ) then
		
			local itterator = 0
			for k, v in pairs( PassagesPoints ) do
				local Direction = ( v.endpos - v.startpos ):GetNormalized()
				local _, angles = LocalToWorld( Vector(), Angle( angle, 0, 0 ), Vector(), v.angles )
				
				for i = 0, v.startpos:Distance( v.endpos ), 320 do
					itterator = itterator + 1
					
					if ( table.Count( self.FieldEffects ) != RequireToSpawn ) then
						c_Model = ents.CreateClientProp()
						c_Model:SetPos( v.startpos + ( i + offset ) * Direction )
						c_Model:SetAngles( angles )
						c_Model:SetModel( "models/gasl/tractor_beam_field_effect.mdl" )
						c_Model:SetNoDraw( true )
						c_Model:Spawn()
						table.insert( self.FieldEffects, table.Count( self.FieldEffects ) + 1, c_Model )
					else
						local c_Model = self.FieldEffects[ itterator ]
						c_Model:SetPos( v.startpos + ( i + offset ) * Direction )
						c_Model:SetAngles( angles )
					end
				end
			end
			
			self.BaseRotation = self.BaseRotation + FrameTime() * dir * 150
			if ( self.BaseRotation > 360 ) then self.BaseRotation = self.BaseRotation - 360  end
			if ( self.BaseRotation < -360 ) then self.BaseRotation = self.BaseRotation + 360 end
			self:ManipulateBoneAngles( 1, Angle( self.BaseRotation, 0, 0 ) ) //
			self:ManipulateBoneAngles( 10, Angle( self.BaseRotation, 0, 0 ) )
			self:ManipulateBoneAngles( 17, Angle( self.BaseRotation, 0, 0 ) )
			self:ManipulateBoneAngles( 9, Angle( self.BaseRotation, 0, 0 ) ) 
			self:ManipulateBoneAngles( 8, Angle( self.BaseRotation * 2, 0, 0 ) ) // center
		end
	end
end
// No more client side
if ( CLIENT ) then return true end

function ENT:Think()

	self:NextThink( CurTime() )
	local Reverse = self:GetReverse()
	local color = Reverse and APERTURESCIENCE.FUNNEL_REVERSE_COLOR or APERTURESCIENCE.FUNNEL_COLOR
	local dir = Reverse and -1 or 1
	local angle = Reverse and -90 or 90
	
	self.BaseClass.Think( self )
	
	-- Skip this tick if exursion funnel is disabled and removing effect if possible
	if ( !self:GetEnable() ) then
		if ( self.GASL_FunnelUpdate.lastPos != Vector() || self.GASL_FunnelUpdate.lastAngle != Angle() ) then
			self.GASL_FunnelUpdate.lastPos = Vector()
			self.GASL_FunnelUpdate.lastAngle = Angle()
				
			-- Removing effects
			self:SetupTrails( )
		end

		return
	end
	
	local PassagesPoints = self:GetAllPortalPassages( self:GetPos(), self:LocalToWorldAngles( Angle( -90, 0, 0 ) ) )
	local TractorBeamEntities = { }
	local FunnelWidth = 60
	
	for k, v in pairs( PassagesPoints ) do
		
		local tractorBeamHullFinder = util.TraceHull( {
			start = v.startpos,
			endpos = v.endpos,
			ignoreworld = true,
			filter = function( ent ) 
			
				if ( ent == self ) then return false end
				if ( !ent.GASL_Ignore && ( ent:GetClass() == "prop_portal" || ent:IsPlayer() || ent:IsNPC() 
						|| IsValid( ent:GetPhysicsObject() ) && ent:GetPhysicsObject():IsValid() && ent:GetPhysicsObject():IsMotionEnabled() ) ) then 
					
					table.insert( TractorBeamEntities, ent:EntIndex(), ent )
					ent.GASL_TravelingInBeamDir = ( v.endpos - v.startpos ):GetNormalized()
					ent.GASL_TravelingInBeamPos = v.startpos
					
					return false
				end
				
				return true
			end,
			mins = -Vector( FunnelWidth, FunnelWidth, FunnelWidth ),
			maxs = Vector( FunnelWidth, FunnelWidth, FunnelWidth ),
			mask = MASK_SHOT_HULL
		} )
		
	end
	
	-- Handling entities in field 
	for k, v in pairs( TractorBeamEntities ) do
	
		if ( !IsValid( v ) ) then continue end
		
		-- Removing entity from table if it still in funnel
		self.GASL_TractorBeamLeavedEntities[ k ] = nil
		
		local centerPos = IsValid( v:GetPhysicsObject() ) and v:LocalToWorld( v:GetPhysicsObject():GetMassCenter() ) or v:GetPos()
		local index = CurTime() * 4 + v:EntIndex() * 10
		local Offset = v:GetClass() == "ent_paint_puddle" and Vector( 0, math.cos( index ), math.sin( index ) ) * 50 or Vector()
		-- Getting 2d dir to closest point to tractor beam
		local WTL = WorldToLocal( centerPos, Angle(), v.GASL_TravelingInBeamPos, v.GASL_TravelingInBeamDir:Angle() )
		
		local min, max = v:WorldSpaceAABB()
		local entRadius = min:Distance( max ) / 3
		
		WTL = Vector( WTL.x, 0, 0 )
		
		local LTW = LocalToWorld( WTL, Angle(), v.GASL_TravelingInBeamPos, v.GASL_TravelingInBeamDir:Angle() )
		local tractorBeamMovingSpeed = APERTURESCIENCE.FUNNEL_MOVE_SPEED * dir

		-- Handling entering into Funnel
		if ( !v.GASL_TractorBeamEnter ) then
			v.GASL_TractorBeamEnter = true
			
			if ( v:IsPlayer() or v:IsNPC() ) then
				if ( v:IsPlayer() ) then v:EmitSound( "GASL.TractorBeamEnter" ) end
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
			Offset:Rotate( v.GASL_TravelingInBeamDir:Angle() )
			vPhysObject:SetVelocity( v.GASL_TravelingInBeamDir * tractorBeamMovingSpeed + Offset + ( LTW - ( centerPos + vPhysObject:GetMassCenter() ) ) - v:GetVelocity() / 10 )
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
		adding = 320
	else
		color = APERTURESCIENCE.FUNNEL_COLOR
		angle = 1
		adding = 0
	end
	
	-- self.GASL_EntInfo.angleoffset = Angle( angle * 90, 0, 0 )
	-- self.GASL_EntInfo.posoffset = Vector( adding, 0, 0 )
	-- self.GASL_EntInfo.color = color
	
	//self:MakePEffect()
	
	-- Handling changes position or angles
	if ( self.GASL_FunnelUpdate.lastPos != self:GetPos() || self.GASL_FunnelUpdate.lastAngle != self:GetAngles() ) then
		self.GASL_FunnelUpdate.lastPos = self:GetPos()
		self.GASL_FunnelUpdate.lastAngle = self:GetAngles()
		self:SetupTrails()
	end

	return true
	
end

function ENT:CheckForLeave( )

	if ( !self.GASL_TractorBeamLeavedEntities ) then return end
	
	for k, v in pairs( self.GASL_TractorBeamLeavedEntities ) do
		if ( !IsValid( v ) ) then break end
		
		if ( v:IsPlayer() || v:IsNPC() ) then
			if( v:IsPlayer() ) then
				v:StopSound( "GASL.TractorBeamEnter" )
			end
		else v:GetPhysicsObject():EnableGravity( true ) end
		
		v.GASL_TractorBeamEnter = false
	end
	
end

function ENT:SetupTrails( )
	
	local TrailWidth = 150
	local TrailWidthEnd = 0
	
	if ( IsValid( self.GASL_Trail1 ) ) then self.GASL_Trail1:Remove() end
	if ( IsValid( self.GASL_Trail2 ) ) then self.GASL_Trail2:Remove() end
	if ( IsValid( self.GASL_Trail3 ) ) then self.GASL_Trail3:Remove() end
	
	if ( self:GetEnable() ) then
	
		local Reverse = self:GetReverse()
		local color = Reverse and APERTURESCIENCE.FUNNEL_REVERSE_COLOR or APERTURESCIENCE.FUNNEL_COLOR
		local material = Reverse and "trails/beam_hotred_add_oriented.vmt" or "trails/beam_hotblue_add_oriented.vmt"
		
		self.GASL_Trail1 = util.SpriteTrail( self, 1, color, false, TrailWidth, TrailWidthEnd, 1, 1 / ( TrailWidth + TrailWidthEnd ) * 0.5, material ) 
		self.GASL_Trail2 = util.SpriteTrail( self, 3, color, false, TrailWidth, TrailWidthEnd, 1, 1 / ( TrailWidth + TrailWidthEnd ) * 0.5, material ) 
		self.GASL_Trail3 = util.SpriteTrail( self, 4, color, false, TrailWidth, TrailWidthEnd, 1, 1 / ( TrailWidth + TrailWidthEnd ) * 0.5, material ) 
		
	end

end

function ENT:TriggerInput( iname, value )
	if ( !WireAddon ) then return end
	
	if ( iname == "Enable" ) then self:ToggleEnable( tobool( value ) ) end
	if ( iname == "Reverse" ) then self:ToggleReverse( tobool( value ) ) end
	
end

function ENT:ToggleEnable( bDown )

	if ( self:GetStartEnabled() ) then bDown = !bDown end

	self:SetEnable( bDown )
	
	if ( self:GetEnable( ) ) then
	
		self:EmitSound( "GASL.TractorBeamStart" )
		self:EmitSound( "GASL.TractorBeamLoop" )

		if ( self:GetReverse() ) then
			APERTURESCIENCE:PlaySequence( self, "back", 1.5 )
		else
			APERTURESCIENCE:PlaySequence( self, "forward", 1.5 )
		end
		
	else
		self:StopSound( "GASL.TractorBeamLoop" )
		self:EmitSound( "GASL.TractorBeamEnd" )

		APERTURESCIENCE:PlaySequence( self, "idle", 1.0 )
	
		self:CheckForLeave()
	end
	
end

function ENT:ToggleReverse( bDown )

	if ( self:GetStartReversed() ) then bDown = !bDown end
	self:SetReverse( bDown )
	self:SetupTrails( )
	
	if ( self:GetEnable() ) then
		if ( self:GetReverse() ) then
			APERTURESCIENCE:PlaySequence( self, "back", 2.0 )
		else
			self.GASL_FunnelUpdate = { }
			APERTURESCIENCE:PlaySequence( self, "forward", 2.0 )
		end		
	end
	
end

function ENT:OnRemove()

	self:CheckForLeave()
	self:StopSound( "GASL.TractorBeamLoop" )
	
end
