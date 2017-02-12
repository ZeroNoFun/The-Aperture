AddCSLuaFile( )

ENT.Base 			= "gasl_base_ent"

ENT.PrintName 		= "Laser Beam"
ENT.Category 		= "Aperture Science"
ENT.Spawnable 		= true
ENT.Editable		= true
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SpawnFunction( ply, trace, ClassName )

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
	
		//if ( self.GASL_UpdateRenderBounds.mins != self.GASL_RenderBounds.mins || self.GASL_UpdateRenderBounds.maxs != self.GASL_RenderBounds.maxs ) then
			//self.GASL_UpdateRenderBounds = { mins = self.GASL_RenderBounds.mins, maxs = self.GASL_RenderBounds.maxs }
			self:SetRenderBounds( self.GASL_RenderBounds.mins, self.GASL_RenderBounds.maxs )
		//end
		
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

function ENT:DoLaser( startpos, ang, ignore )
	
	local points = self:GetAllPortalPassages( startpos, ang )
	local trace = { }
	local itter = 0
	
	for k, v in pairs( points ) do
	
		itter = itter + 1
		
		local offset = ( v.endpos - v.startpos ):GetNormalized()

		trace = util.TraceLine( {
			start = v.startpos,
			endpos = v.endpos + offset,
			filter = function( ent )
				if ( ent:GetClass() == "prop_portal" || ( ent:IsPlayer() || ent:IsNPC() ) && CLIENT || ent == ignore ) then return false end
				if ( ent:GetClass() == "ent_laser_relay" ) then ent.GASL_LastHittedByLaser = CurTime() end
				if ( APERTURESCIENCE:IsValidEntity( ent ) || ent:GetClass() == "ent_laser_catcher" ) then return true end
			end
		} )
		
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
			render.DrawBeam( startpos, endpos, 80, distance / 100, 1, Color( 255, 255, 255 ) )
			
		else
		
			local trEnt = trace.Entity

			if ( IsValid( trEnt ) && ( !trEnt:IsPlayer() && trEnt:Health() > 0 
				|| trEnt:GetClass() == "ent_portal_floor_turret"
				|| trEnt:GetClass() == "ent_portal_turret_different"
				|| trEnt:GetClass() == "ent_portal_defective_turret" ) ) then trEnt:Ignite( 1 ) end
			
			if ( trEnt && trEnt:IsValid() 
				&& ( trEnt:IsPlayer()
				|| trEnt:IsNPC() ) ) then
				trEnt:TakeDamage( 10, self, self ) 
				trEnt:EmitSound( "GASL.LaserBodyBurn" )
				
				-- Forces Player away from the laser
				-- local angles = ( v.endpos - v.startpos ):Angle()
				-- local forceDirLocal = WorldToLocal( trEnt:LocalToWorld( trEnt:GetPhysicsObject():GetMassCenter() ), Angle(), v.startpos, angles )
				-- forceDirLocal.x = 0
				
				-- local forceDir = WorldToLocal( forceDirLocal, Angle(), Vector(), angles )
				-- forceDir.z = 0
				-- forceDir = -forceDir:GetNormalized() * ( 40 - forceDir:Length() )
				-- trEnt:SetVelocity( forceDir * 20 )
				
			end
		
		end
		
		-- skip if 
		if ( self.GASL_AllreadyHandled[ traceEnt:EntIndex() ] ) then break end
		-- reflects when hit reflection cube
		if ( traceEnt && traceEnt:IsValid() && ( traceEnt:GetModel() == "models/props/reflection_cube.mdl" ) ) then
			
			if ( CLIENT ) then
				self:DrawMuzzleEffect( traceEnt:GetPos(), traceEnt:GetForward() )
			end

			self.GASL_AllreadyHandled[ traceEnt:EntIndex() ] = true
			return self:DoLaser( traceEnt:GetPos(), traceEnt:GetAngles(), traceEnt )
		end
		
	end
		
	-- returning last tracer hit position
	return trace
	
end


function ENT:Draw()

	self:DrawModel()
	
	-- skip if disabled
	if ( !self:GetEnable() ) then return end

	self.GASL_AllreadyHandled = { }
	local startPos = self:LocalToWorld( self:ModelToStartCoord() )
	
	self:DrawMuzzleEffect( startPos, self:GetForward() )
	
	local endtrace = self:DoLaser( self:LocalToWorld( self:ModelToStartCoord() ), self:GetAngles(), self )
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

numpad.Register( "aperture_science_laser_emitter_enable", function( pl, ent, keydown, idx )

	if ( !IsValid( ent ) ) then return false end

	if ( keydown ) then ent:ToggleEnable( true ) end
	return true

end )

numpad.Register( "aperture_science_laser_emitter_disable", function( pl, ent, keydown )

	if ( !IsValid( ent ) ) then return false end

	if ( keydown ) then ent:ToggleEnable( false ) end
	return true

end )

function ENT:OnRemove()

	self:StopSound( "GASL.LaserStart" )
	
end
