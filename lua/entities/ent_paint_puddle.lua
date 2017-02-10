AddCSLuaFile( )

ENT.Type 			= "anim"
ENT.Base 			= "base_entity"
ENT.RenderGroup 	= RENDERGROUP_BOTH

function ENT:SetupDataTables()

	self:NetworkVar( "Int", 0, "GelRadius" )
	
end

cleanup.Register( "gasl_gel" )

function ENT:Initialize()

	if ( SERVER ) then

		self:SetModel( "models/XQM/Rails/gumball_1.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_OBB )
		self:SetRenderMode( RENDERMODE_TRANSALPHA )
		self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )

		self:SetMaterial( "models/shiny" )
		
		self.GASL_GelType = 0
		self.GASL_GelRandomizeSize = 0
		self.GASL_GelAmount = 0
		
	end

	if ( CLIENT ) then
		
		self.GASL_SizeChanged = false
		
	end
	
end

function ENT:Convert2Grid( pos, angle, rad )

	local WTL = WorldToLocal( pos, Angle( ), Vector( ), angle ) 
	WTL = Vector( math.Round( WTL.x / rad ) * rad, math.Round( WTL.y / rad ) * rad, WTL.z )
	pos = LocalToWorld( WTL, Angle( ), Vector( ), angle )
	
	return pos
	
end

function ENT:PaintGel( pl, pos, normal, rad )

	local maxseg = math.floor( rad / APERTURESCIENCE.GEL_BOX_SIZE )
	
	local effectdata = EffectData()
	effectdata:SetOrigin( pos )
	effectdata:SetNormal( normal )
	effectdata:SetRadius( self:GetGelRadius() )
	effectdata:SetColor( self.GASL_GelType )
	
	self:EmitSound( "GASL.GelSplat" )
	util.Effect( "gel_splat_effect", effectdata )
	
	for x = -maxseg, maxseg do
	for y = -maxseg, maxseg do
	
		local offset = Vector( x * APERTURESCIENCE.GEL_BOX_SIZE, y * APERTURESCIENCE.GEL_BOX_SIZE, 0 )
		offset:Rotate( normal:Angle() + Angle( 90, 0, 0 ) )

		local location = pos + offset
		local gelTrace = APERTURESCIENCE:CheckForGel( location + normal * 5, -normal * 10 ) 
		
		if ( location:Distance( pos ) > rad ) then continue end
		
		if ( !gelTrace.Entity:IsValid() ) then
			
			-- Skip if gel type is water
			if ( self.GASL_GelType == 4 ) then continue end
			
			local trace = util.TraceLine( {
				start = location + normal * 5,
				endpos = location - normal * 10,
				filter = function( ent )
					if ( ent:GetClass() == "ent_gel_paint" || ent:GetClass() == "ent_gel_puddle" || ent:GetClass() == "prop_gel_dropper" ) then return false end
				end
			} )
			
			-- Skip if tracer doesn't hit anything or it in the world
			if ( !trace.Hit || !util.IsInWorld( trace.HitPos ) ) then continue end
			
			local gridPos = self:Convert2Grid( trace.HitPos, trace.HitNormal:Angle() + Angle( 90, 0, 0 ), APERTURESCIENCE.GEL_BOX_SIZE )
			
			-- Skip if grided position is outside of the world
			if ( !util.IsInWorld( gridPos ) ) then continue end
			
			local ent = ents.Create( "ent_gel_paint" )
			ent:SetPos( gridPos )
			ent:SetAngles( trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
			ent:SetMoveType( MOVETYPE_NONE )
			ent:Spawn()
			
			if ( IsValid( pl ) ) then
				pl:AddCount( "gasl_gel", ent )
				pl:AddCleanup( "gasl_gel", ent )
			end
			
			ent:SetGelType( self.GASL_GelType )
			ent:UpdateGel()

		else
			if ( self.GASL_GelType == 4 ) then
				gelTrace.Entity:SetGelType( 0 )
			else
				gelTrace.Entity:SetGelType( self.GASL_GelType )
			end

			gelTrace.Entity:UpdateGel()
			if ( self.GASL_GelType == 4 ) then gelTrace.Entity:Remove() end
		end
		
	end
	end
	
	local findResult = ents.FindInSphere( pos, rad )
	
	for k, v in pairs( findResult ) do
	
		if ( APERTURESCIENCE:IsValidEntity( v ) && !v:IsPlayer() && v:GetPhysicsObject():IsValid()
			&& ( !APERTURESCIENCE.GELLED_ENTITIES[ v ] || v.GASL_GelledType && v.GASL_GelledType != self.GASL_GelType ) ) then
			
			-- Reseting physics material
			if ( v.GASL_PrevPhysMaterial ) then
				v:GetPhysicsObject():SetMaterial( v.GASL_PrevPhysMaterial )
				v.GASL_PrevPhysMaterial = nil
			end
			
			if ( self.GASL_GelType != 4 ) then
				
				v.GASL_GelledType = self.GASL_GelType
				
				local color = APERTURESCIENCE:GetColorByGelType( self.GASL_GelType )
				
				if ( self.GASL_GelType == 1 ) then
					v:SetSubMaterial( 0, "paint/prop_paint_blue" )
				end
				if ( self.GASL_GelType == 2 ) then
					v:SetSubMaterial( 0, "paint/prop_paint_orange" )
				end
				
				if ( !v.GASL_PrevPhysMaterial ) then
				
					if ( self.GASL_GelType == 1 ) then
						v.GASL_PrevPhysMaterial = v:GetPhysicsObject():GetMaterial()
						v:GetPhysicsObject():SetMaterial( "metal_bouncy" )
						APERTURESCIENCE.GELLED_ENTITIES[ v ] = v
					end

					if ( self.GASL_GelType == 2 ) then
						v.GASL_PrevPhysMaterial = v:GetPhysicsObject():GetMaterial()
						v:GetPhysicsObject():SetMaterial( "gmod_ice" )
					end
					
				end
				
			else
				APERTURESCIENCE.GELLED_ENTITIES[ v ] = nil
				v:SetSubMaterial( 0, "" )
				v:GetPhysicsObject():SetMaterial( "none" )
				v.GASL_GelledType = nil
			end
			
		end
		
	end

end

function ENT:DrawTranslucent()
	
	self:DrawModel()
	
end

function ENT:Think()

	self:NextThink( CurTime() + 0.1 )
	
	if ( CLIENT ) then
	
		-- Changing Size
		if ( !self.GASL_SizeChanged ) then
		
			self.GASL_SizeChanged = true
			
			local scale = Vector( 1, 1, 1 ) * ( self:GetGelRadius() / 100 )
			local mat = Matrix()
			mat:Scale( scale )
			self:EnableMatrix( "RenderMultiply", mat )
			
		end
		
	end
	
	if ( SERVER ) then

		local trace = util.TraceLine( {
			start = self:GetPos(),
			endpos = self:GetPos() + self:GetVelocity() / 5,
			ignoreworld = true,
			filter = function( ent )
				if ( ent:GetClass() == "prop_portal" ) then return true end
				if ( ent:GetClass() == "ent_gel_paint" || ent:GetClass() == "ent_gel_puddle" ) then return false end
			end
		} )
		
		local traceEnt = trace.Entity
		
		if ( !traceEnt:IsValid() || traceEnt:IsValid() 
			&& ( traceEnt:GetClass() != "prop_portal" || traceEnt:GetClass() == "prop_portal" && !traceEnt:GetNWBool( "Potal:Other" ) ) ) then
			trace = util.TraceLine( {
				start = self:GetPos(),
				endpos = self:GetPos() + self:GetVelocity() / 5,
				filter = function( ent )
					if ( ent:GetClass() == "ent_gel_paint" || ent:GetClass() == "ent_gel_puddle" || ent:GetClass() == "prop_gel_dropper" ) then return false end
				end
			} )
		end
		
		traceEnt = trace.Entity
		
		if ( trace.Hit && ( !traceEnt:IsValid() || traceEnt:IsValid() && traceEnt:GetClass() != "prop_portal" ) ) then
		
			self:PaintGel( NULL, trace.HitPos, trace.HitNormal, self:GetGelRadius() )
			self:SetColor( Color( 0, 0, 0, 0 ) )
			self:GetPhysicsObject():EnableMotion( false )

			timer.Simple( 1, function() if ( self:IsValid() ) then self:Remove() end end )
			self:NextThink( CurTime() + 2 )
			
		end
		
	end
	
	return true

end
