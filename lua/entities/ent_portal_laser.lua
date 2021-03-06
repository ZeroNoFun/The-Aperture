AddCSLuaFile( )

ENT.Base = "gasl_base_ent"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !APERTURESCIENCE.ALLOWING.laser && !ply:IsSuperAdmin() ) then ply:PrintMessage( HUD_PRINTTALK, "This entity is blocked" ) return end

	if ( !trace.Hit ) then return end
	
	local ent = ents.Create( ClassName )
	ent:SetPos( trace.HitPos )
	ent:SetModel( "models/props/laser_emitter_center.mdl" )
	ent:SetAngles( trace.HitNormal:Angle() )
	ent:Spawn()

	return ent

end

function ENT:SetupDataTables()
	
	self:NetworkVar( "Bool", 0, "Enable" )
	self:NetworkVar( "Bool", 1, "Toggle" )
	self:NetworkVar( "Bool", 2, "StartEnabled" )
	
end

if ( CLIENT ) then

	function ENT:Think()
	
		self:SetRenderBounds( self.GASL_RenderBounds.mins, self.GASL_RenderBounds.maxs )
		
	end

	function ENT:Initialize()
		
		self.BaseClass.Initialize( self )

		local min, max = self:GetRenderBounds() 
		self.GASL_RenderBounds = { mins = min, maxs = max }
		self.GASL_UpdateRenderBounds = { mins = Vector(), maxs = Vector() }
		
	end
	
	function ENT:DrawMuzzleEffect( startpos, dir )

		local LaserSpriteCount = 8
		local LaserSpriteRadius = 70 * math.Rand( 0.9, 1.1 )
		local LaserSpriteDist = 50
		
		for i = 1, ( LaserSpriteCount - 2 ) do
			local radius = LaserSpriteRadius * ( 1 - ( i / LaserSpriteCount ) )
			render.SetMaterial( Material( "particle/laser_beam_glow" ) )
			render.DrawSprite( startpos + dir * i * ( LaserSpriteDist / LaserSpriteCount ), radius, radius, Color( 255, 255, 255 ) )
		end
		
	end

end

function ENT:ModelToStartCoord()

	local modelToStartCoord = {
		["models/props/laser_emitter_center.mdl"] = Vector( 30, 0, 0 ),
		["models/props/laser_emitter.mdl"] = Vector( 30, 0, -14 )
	}
	
	return modelToStartCoord[ self:GetModel() ]
	
end

function ENT:DamageEntity( ent )

	if ( !IsValid( ent ) ) then return end
	
	ent:TakeDamage( 10, self, self ) 
	ent:EmitSound( "GASL.LaserBodyBurn" )
	
	-- Forces Player away from the laser
	-- local angles = ( v.endpos - v.startpos ):Angle()
	-- local forceDirLocal = WorldToLocal( trEnt:LocalToWorld( trEnt:GetPhysicsObject():GetMassCenter() ), Angle(), v.startpos, angles )
	-- forceDirLocal.x = 0
	
	-- local forceDir = WorldToLocal( forceDirLocal, Angle(), Vector(), angles )
	-- forceDir.z = 0
	-- forceDir = -forceDir:GetNormalized() * ( 40 - forceDir:Length() )
	-- trEnt:SetVelocity( forceDir * 20 )
	
end

function ENT:DoLaser( startpos, ang, ignore )
	
	self.GASL_LASER_Reflections = self.GASL_LASER_Reflections + 1
	
	if ( self.GASL_LASER_Reflections > 256 ) then return end
	
	local points = self:GetAllPortalPassages( startpos, ang, ignore )
	local trace = { }
	local itter = 0
		
	for k, v in pairs( points ) do
		
		itter = itter + 1
		
		local offset = ( v.endpos - v.startpos ):GetNormalized()

		trace = util.TraceLine( {
			start = v.startpos,
			endpos = v.endpos + offset,
			filter = function( ent )
				if ( ( ent:IsNPC() || ent:IsPlayer() ) && SERVER ) then return false end
				if ( ent:GetClass() == "env_portal_paint" && ent:GetGelType() == PORTAL_GEL_REFLECTION ) then return true end
				if ( ent:GetClass() == "prop_portal" || ( ent:IsPlayer() || ent:IsNPC() ) && CLIENT || ent == ignore ) then return false end
				if ( ent:GetClass() == "ent_laser_relay" ) then ent.GASL_LastHittedByLaser = CurTime() end
				if ( APERTURESCIENCE:IsValidEntity( ent ) || ent:GetClass() == "ent_laser_catcher" || ent:GetClass() == "prop_physics" ) then return true end
				
				if( IsValid( ent ) ) then return true end

			end
		} )
		
		local traceHitEntity = NULL
		
		if ( SERVER ) then
			traceHitEntity = util.TraceLine( {
				start = v.startpos,
				endpos = v.endpos + offset,
				filter = function( ent )
					if ( ( ent:IsNPC() || ent:IsPlayer() ) ) then return true end
					if ( ent:GetClass() == "prop_portal" || ent == ignore ) then return false end
					if ( ent:GetClass() == "ent_laser_relay" ) then ent.GASL_LastHittedByLaser = CurTime() end
					if ( APERTURESCIENCE:IsValidEntity( ent ) || ent:GetClass() == "ent_laser_catcher" || ent:GetClass() == "prop_physics" ) then return true end
					//if( IsValid( ent ) ) then return true end

				end
			} ).Entity
		end
		
		local addingDist = 20
		local addingDistB = 0
		local traceEnt = trace.Entity
		
		if ( traceEnt && traceEnt:IsValid() ) then addingDist = 0 end		
		if ( itter > 1 ) then addingDistB = 20 end
		if ( itter == table.Count( points ) ) then addingDist = 0 end
		
		local startpos = v.startpos - offset * addingDistB
		local endpos = trace.HitPos + offset * addingDist

		local distance = trace.HitPos:Distance( v.startpos )

		if ( CLIENT ) then
			
			if ( IsValid( traceEnt ) && traceEnt:GetClass() == "ent_laser_catcher" ) then
				endpos = traceEnt:LocalToWorld( traceEnt:ModelToStartCoord() )
			end
			
			local localEndPos = self:WorldToLocal( endpos )
			
			if ( localEndPos.x > self.GASL_RenderBounds.maxs.x ) then self.GASL_RenderBounds.maxs.x = localEndPos.x end
			if ( localEndPos.y > self.GASL_RenderBounds.maxs.y ) then self.GASL_RenderBounds.maxs.y = localEndPos.y end
			if ( localEndPos.z > self.GASL_RenderBounds.maxs.z ) then self.GASL_RenderBounds.maxs.z = localEndPos.z end
			
			if ( localEndPos.x < self.GASL_RenderBounds.mins.x ) then self.GASL_RenderBounds.mins.x = localEndPos.x end
			if ( localEndPos.y < self.GASL_RenderBounds.mins.y ) then self.GASL_RenderBounds.mins.y = localEndPos.y end
			if ( localEndPos.z < self.GASL_RenderBounds.mins.z ) then self.GASL_RenderBounds.mins.z = localEndPos.z end

			render.SetMaterial( Material( "sprites/purplelaser1" ) )
			render.DrawBeam( startpos, endpos, 60, distance / 100, 1, Color( 255, 255, 255 ) )
			
		elseif ( IsValid( traceHitEntity ) ) then
			
			if ( ( !traceHitEntity:IsPlayer() && traceHitEntity:Health() > 0 
				|| traceHitEntity:GetClass() == "ent_portal_floor_turret"
				|| traceHitEntity:GetClass() == "ent_portal_turret_different"
				|| traceHitEntity:GetClass() == "ent_portal_defective_turret" ) ) then traceHitEntity:Ignite( 1 ) end
				
			if ( traceHitEntity:IsNPC() || traceHitEntity:IsPlayer() ) then self:DamageEntity( traceHitEntity ) end
		end
		
		-- skip if 
		if ( self.GASL_AllreadyHandled[ traceEnt:EntIndex() ] ) then break end

		if ( IsValid( traceEnt ) ) then
		
			-- reflect when hit reflection gel
			if ( traceEnt:GetClass() == "env_portal_paint" && traceEnt:GetGelType() == PORTAL_GEL_REFLECTION
				|| traceEnt.GASL_GelledType && traceEnt.GASL_GelledType == PORTAL_GEL_REFLECTION ) then
				
				local normal = trace.HitNormal 
				APERTURESCIENCE:NormalFlipZeros( normal )
				
				local reflectionDir = normal:Dot(-offset) * normal * 2 + offset 
				return self:DoLaser( trace.HitPos + trace.HitNormal / 10, reflectionDir:Angle(), traceEnt )
			
			end

			-- reflects when hit reflection cube
			if ( traceEnt:GetModel() == "models/props/reflection_cube.mdl" ) then
				
				if ( CLIENT ) then
					self:DrawMuzzleEffect( traceEnt:GetPos(), traceEnt:GetForward() )
				end

				self.GASL_AllreadyHandled[ traceEnt:EntIndex() ] = true
				return self:DoLaser( traceEnt:GetPos(), traceEnt:GetAngles(), traceEnt )
			end
			
		end
		
	end
		
	-- returning last tracer hit position
	return trace
	
end


function ENT:Draw()

	self.GASL_LASER_Reflections = 0

	self:DrawModel()
	
	-- skip if disabled
	if ( !self:GetEnable() ) then return end

	self.GASL_AllreadyHandled = { }
	local startPos = self:LocalToWorld( self:ModelToStartCoord() )
	
	self:DrawMuzzleEffect( startPos, self:GetForward() )
	
	local endtrace = self:DoLaser( self:LocalToWorld( self:ModelToStartCoord() ), self:GetAngles(), self )
	
	if ( !endtrace ) then return end
	
	local endpos = endtrace.HitPos
	local endnormal = endtrace.HitNormal
	local endentity = endtrace.Entity
	
	local pos = self:WorldToLocal( endpos )
	
	if ( IsValid( endentity ) && endentity:GetClass() == "ent_laser_catcher" ) then
		return
	end
	
	if ( !timer.Exists( "GASL_LaserSparksEffect"..self:EntIndex() ) ) then 
		timer.Create( "GASL_LaserSparksEffect"..self:EntIndex(), 0.05, 1, function() end )

		local vPoint = Vector( 0, 0, 0 )
		local effectdata = EffectData()
		effectdata:SetOrigin( endpos )
		effectdata:SetNormal( endnormal )
		util.Effect( "StunstickImpact", effectdata )
	
	end
	
end

-- no more client side
if ( CLIENT ) then return end

function ENT:Initialize()

	self.BaseClass.Initialize( self )
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:GetPhysicsObject():EnableMotion( false )

	self:AddInput( "Enable", function( value ) self:ToggleEnable( value ) end )

	--
	if ( !WireAddon ) then return end
	self.Inputs = Wire_CreateInputs( self, { "Enable" } )

end

function ENT:TriggerInput( iname, value )
	if ( !WireAddon ) then return end
	
	if ( iname == "Enable" ) then self:ToggleEnable( tobool( value ) ) end
	
end

function ENT:Think()

	self.GASL_LASER_Reflections = 0
	
	self:NextThink( CurTime() )
	
	-- skip if disabled
	if ( !self:GetEnable() ) then return end
	
	if ( !timer.Exists( "GASL_LaserDamaging"..self:EntIndex() ) ) then 
		timer.Create( "GASL_LaserDamaging"..self:EntIndex(), 0.1, 1, function() end )
			
		self.GASL_AllreadyHandled = { }
		local endtrace = self:DoLaser( self:LocalToWorld( self:ModelToStartCoord() ), self:GetAngles(), self )
		local endentity = endtrace.Entity
		
		if ( IsValid( endentity ) && endentity:GetClass() == "ent_laser_catcher" ) then
			endentity.GASL_LastHittedByLaser = CurTime()
			return
		end
	
	end

	return true
	
end

function ENT:ToggleEnable( bDown )

	if ( self:GetStartEnabled() ) then bDown = !bDown end
	
	if ( self:GetToggle() ) then
	
		if ( !bDown ) then return end
		
		self:SetEnable( !self:GetEnable() )
		
	else
		self:SetEnable( bDown )
	end
	
	if ( self:GetEnable() ) then
		self:EmitSound( "GASL.LaserStart" )
	else
		self:StopSound( "GASL.LaserStart" )
	end
	
end

function ENT:OnRemove()

	self:StopSound( "GASL.LaserStart" )
	
end
