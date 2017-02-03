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
	ent:SetAngles( trace.HitNormal:Angle() )
	ent:Spawn()

	return ent

end

function ENT:SetupDataTables()
	
	self:NetworkVar( "Bool", 0, "Enable" )
	self:NetworkVar( "Bool", 1, "Toggle" )
	
end

if ( CLIENT ) then

	function ENT:Initialize()
	
		self.GASL_UpdateRenderBounds = Vector()
	
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
				if ( ( APERTURESCIENCE:IsValidEntity( ent ) ) ) then return true end
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
		
			render.SetMaterial( Material( "effects/redlaser1" ) )
			render.DrawBeam( startpos, endpos, 10, distance / 100, 1, Color( 255, 255, 255 ) )
			render.SetMaterial( Material( "effects/redlaser2" ) )
			render.DrawBeam( startpos, endpos, 3, distance / 100, 1, Color( 255, 255, 255 ) )
			
		else

			local tr = util.TraceHull( {
				start = v.startpos,
				endpos = v.endpos + offset,
				filter = function( ent ) 
					if ( ( APERTURESCIENCE:IsValidEntity( ent ) ) ) then return true end
				end,
				mins = -Vector( 10, 10, 10 ),
				maxs = Vector( 10, 10, 10 )
			} )
		
			local trEnt = tr.Entity
			
			if ( trEnt && trEnt:IsValid() 
				&& ( trEnt:IsPlayer()
				|| trEnt:IsNPC() ) ) then
				trEnt:TakeDamage( 10, self, self ) 
				trEnt:EmitSound( "GASL.LaserBodyBurn" )
				
				local forceDirLocal = WorldToLocal( trEnt:LocalToWorld( trEnt:GetPhysicsObject():GetMassCenter() ), Angle(), self:LocalToWorld( self:ModelToStartCoord() ), self:GetAngles() )
				forceDirLocal.x = 0
				
				local forceDir = WorldToLocal( forceDirLocal, Angle(), Vector(), self:GetAngles() )
				forceDir = forceDir:GetNormalized() * -forceDir:Length()
				trEnt:SetVelocity( forceDir * 20 )
				
			end
		
		end
		
		-- reflects when hit reflection cube
		if ( traceEnt && traceEnt:IsValid() && !self.GASL_AllreadyHandled[ traceEnt:EntIndex() ]
			&& ( traceEnt:GetModel() == "models/props/reflection_cube.mdl" ) ) then
			
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
		
	local endtrace = self:DoLaser( self:LocalToWorld( self:ModelToStartCoord() ), self:GetAngles(), self )
	local endpos = endtrace.HitPos
	local endnormal = endtrace.HitNormal
	
	local pos = self:WorldToLocal( endpos )
	
	if ( pos != self.GASL_UpdateRenderBounds && self:GetVelocity():Length() == 0 ) then
		
		self.GASL_UpdateRenderBounds = pos
		local min, max = self:GetRenderBounds() 
		
		max.x = pos.x
		self:SetRenderBounds( min, max )
		
	end
	
	if ( !timer.Exists( "GASL_LaserSparksEffect"..self:EntIndex() ) ) then 
			timer.Create( "GASL_LaserSparksEffect"..self:EntIndex(), 0.08, 1, function() end )

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

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:GetPhysicsObject():EnableMotion( false )

end


function ENT:Think()

	self:NextThink( CurTime() )
	
	-- skip if disabled
	if ( !self:GetEnable() ) then return end
	
	if ( !timer.Exists( "GASL_LaserDamaging"..self:EntIndex() ) ) then 
			timer.Create( "GASL_LaserDamaging"..self:EntIndex(), 0.1, 1, function() end )
			
		self.GASL_AllreadyHandled = { }
		self:DoLaser( self:LocalToWorld( self:ModelToStartCoord() ), self:GetAngles(), self )
	
	end

	return true
	
end

function ENT:ToggleEnable( bDown )

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
