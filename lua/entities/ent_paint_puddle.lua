AddCSLuaFile( )

ENT.Type 			= "anim"
ENT.Base 			= "base_entity"
ENT.RenderGroup 	= RENDERGROUP_BOTH

function ENT:SetupDataTables()

	self:NetworkVar( "Int", 0, "GelRadius" )

end

cleanup.Register( "aperture_paint" )

function ENT:Initialize()

	if ( SERVER ) then
		self:SetModel( "models/gasl/portal_gel_bubble.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_OBB )
		self:SetRenderMode( RENDERMODE_TRANSALPHA )
		self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
		
		self.GASL_GelType = 0
		self.GASL_PAINTPUDDLE_PrevPos = self:GetPos()
	end
	
end

function ENT:PaintGel( pl, pos, normal, rad )

	local effectdata = EffectData()
	effectdata:SetOrigin( pos )
	effectdata:SetNormal( normal )
	effectdata:SetRadius( self:GetGelRadius() )
	effectdata:SetColor( self.GASL_GelType )
	
	if ( rad >= 150 ) then
		self:EmitSound( "GASL.GelSplatBig" )
		util.Effect( "paint_bomb_effect", effectdata )
	else
		self:EmitSound( "GASL.GelSplat" )
		util.Effect( "paint_splat_effect", effectdata )
	end
	
	local maxseg = math.floor( rad / APERTURESCIENCE.GEL_BOX_SIZE )
	
	for x = -maxseg, maxseg do
	for y = -maxseg, maxseg do
	
		local offset = Vector( x * APERTURESCIENCE.GEL_BOX_SIZE, y * APERTURESCIENCE.GEL_BOX_SIZE, 0 )
		offset:Rotate( normal:Angle() + Angle( 90, 0, 0 ) )
		
		local location = pos + offset
		local GridLocation = APERTURESCIENCE:ConvertToGridWithoutZ( location, normal:Angle() + Angle( 90, 0, 0 ), APERTURESCIENCE.GEL_BOX_SIZE )
		local paint = APERTURESCIENCE:CheckForGel( GridLocation + normal * 10, -normal * 20, true, true, normal ) 
		
		if ( GridLocation:Distance( pos ) > rad ) then continue end
		
		if ( !IsValid( paint ) ) then
			
			-- Skip if paint type is water
			if ( self.GASL_GelType == PORTAL_GEL_WATER ) then continue end
			
			-- Skip if grided position is outside of the world
			if ( !util.IsInWorld( GridLocation ) ) then continue end

			local trace = util.TraceLine( {
				start = GridLocation + normal * 10,
				endpos = GridLocation - normal * 10,
				filter = function( ent )
					if ( ent:GetClass() == "env_portal_paint" ) then return false end
					if ( !APERTURESCIENCE:IsValidEntity( ent ) ) then return true end
				end
			} )
			
			-- Skip if tracer doesn't hit anything or it in the world
			if ( !trace.Hit || trace.Fraction == 0 || !util.IsInWorld( trace.HitPos ) ) then continue end
			
			local ent = ents.Create( "env_portal_paint" )
			if( !IsValid( ent ) ) then return end
			if ( IsValid( trace.Entity ) ) then ent:SetParent( trace.Entity ) end
			ent:SetPos( trace.HitPos + normal )
			ent:SetAngles( trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
			ent:SetMoveType( MOVETYPE_NONE )
			ent:SetMatType( trace.MatType )
			ent:Spawn()
			
			if ( IsValid( pl ) ) then pl:AddCleanup( "aperture_paint", ent ) end
			ent:SetGelType( self.GASL_GelType )
			ent:UpdateGel()

		else
		
			if ( IsValid( paint ) && paint:GetClass() == "env_portal_paint" ) then 
				if ( self.GASL_GelType == PORTAL_GEL_WATER ) then
					paint:SetGelType( PORTAL_GEL_NONE )
					paint:UpdateGel()
					paint:Remove()
				else
					paint:SetGelType( self.GASL_GelType )
					paint:UpdateGel()
				end
			end
		end
		
	end
	end
	
	// handling props around splat
	local findResult = ents.FindInSphere( pos, rad )
	
	for k, v in pairs( findResult ) do
	
		if ( APERTURESCIENCE:IsValidEntity( v ) && !v:IsPlayer() ) then
		
			if ( !APERTURESCIENCE.GELLED_ENTITIES[ v ] || v.GASL_GelledType && v.GASL_GelledType != self.GASL_GelType ) then
				
				local Center = v:GetPhysicsObject() and v:LocalToWorld( v:GetPhysicsObject():GetMassCenter() ) or v:GetPos()
				
				local trace = util.TraceLine( {
					start = self:GetPos(),
					endpos = Center,
					filter = function( ent ) if ( ent:GetClass() != "ent_paint_puddle" && ent != v ) then return true end end
				} )
				if ( trace.Hit ) then continue end

				-- Reseting physics material
				if ( v.GASL_PrevPhysMaterial ) then
					v:GetPhysicsObject():SetMaterial( v.GASL_PrevPhysMaterial )
					v.GASL_PrevPhysMaterial = nil
				end
				
				if ( self.GASL_GelType != 4 ) then
					
					local color = APERTURESCIENCE:GetColorByGelType( self.GASL_GelType )
					v.GASL_GelledType = self.GASL_GelType
					
					if ( self.GASL_GelType != PORTAL_GEL_BOUNCE && APERTURESCIENCE.GELLED_ENTITIES[ v ] ) then APERTURESCIENCE.GELLED_ENTITIES[ v ] = nil end
					
					// adding properties to the entities
					if ( !v.GASL_PrevPhysMaterial ) then
					
						// painting entity
						if ( self.GASL_GelType != PORTAL_GEL_WATER ) then APERTURESCIENCE:PaintProp( v, self.GASL_GelType ) end
						
						if ( self.GASL_GelType == PORTAL_GEL_BOUNCE ) then
							v.GASL_PrevPhysMaterial = v:GetPhysicsObject():GetMaterial()
							v:GetPhysicsObject():SetMaterial( "metal_bouncy" )
							APERTURESCIENCE.GELLED_ENTITIES[ v ] = v
							
						elseif ( self.GASL_GelType == PORTAL_GEL_SPEED ) then
							v.GASL_PrevPhysMaterial = v:GetPhysicsObject():GetMaterial()
							v:GetPhysicsObject():SetMaterial( "gmod_ice" )
							
						elseif ( self.GASL_GelType == PORTAL_GEL_STICKY ) then
							v.GASL_PrevPhysMaterial = v:GetPhysicsObject():GetMaterial()
							APERTURESCIENCE.GELLED_ENTITIES[ v ] = v
						end
					end
					
				else
					// clearing properties from the entities
					APERTURESCIENCE.GELLED_ENTITIES[ v ] = nil
					APERTURESCIENCE:ClearPaintProp( v )
					
					v.GASL_GelledType = nil
				end
			
			end
			
			// extinguish if gel is water
			if( self.GASL_GelType == PORTAL_GEL_WATER && v:IsOnFire() ) then
				v:Extinguish()
			end
		end
	end

end

function ENT:DrawTranslucent()
	
	self:DrawModel()
	
	-- local entities = ents.FindInSphere( self:GetPos(), self:GetGelRadius() * 2 ) 
	
	-- for k, v in pairs( entities ) do
	
		-- if ( v:GetClass() == "ent_paint_puddle" ) then
			
			-- table.insert( APERTURESCIENCE.CONNECTED_PAINTS, 0, self )
			-- break
			
		-- end
		
	-- end
	
end

function ENT:Think()

	self:NextThink( CurTime() + 0.1 )
	
	// puddle animation
	if ( CLIENT ) then
		-- Changing Size
		local rotation = ( CurTime() * 1.5 + self:EntIndex() * 10 ) * 4
		local scale = Vector( 1 + math.cos( rotation ) / 4, 1 + math.sin( rotation ) / 4, 1 ) * ( self:GetGelRadius() / 110 )
		local mat = Matrix()
		mat:Scale( scale )
		self:EnableMatrix( "RenderMultiply", mat )

		self:SetAngles( Angle( rotation * 10, rotation * 20, 0 ) )
		
		-- no more client side
		return true
	end
	
	
	local trace = util.TraceLine( {
		start = self.GASL_PAINTPUDDLE_PrevPos,
		endpos = self:GetPos(),
		ignoreworld = true,
		filter = function( ent )
			if ( ent:GetClass() == "prop_portal" ) then return true end
		end
	} )
	local traceEnt = trace.Entity
	
	if ( !IsValid( traceEnt ) || IsValid( traceEnt )
		&& traceEnt:GetClass() != "prop_portal" && !IsValid( traceEnt:GetNWBool( "Potal:Other" ) ) ) then
		trace = util.TraceLine( {
			start = self.GASL_PAINTPUDDLE_PrevPos,
			endpos = self:GetPos(),
			filter = function( ent )
				if ( ( APERTURESCIENCE:IsValidEntity( ent ) || APERTURESCIENCE:IsValidStaticEntity( ent ) ) && ent != self:GetOwner() ) then return true end
			end
		} )
		
		traceEnt = trace.Entity
		if ( trace.HitSky ) then 
			self:Remove()
			return
		end
	end

	if ( trace.Hit ) then
		
		if ( IsValid( traceEnt ) && traceEnt:GetClass() == "prop_portal" ) then self:NextThink( CurTime() + 0.5 ) end
		if ( !IsValid( traceEnt ) || IsValid( traceEnt ) && traceEnt:GetClass() != "prop_portal" ) then
			self:SetPos( trace.HitPos + trace.HitNormal )
			self:SetColor( Color( 0, 0, 0, 0 ) )
			self:GetPhysicsObject():EnableMotion( false )
			self:PaintGel( self:GetOwner(), trace.HitPos, trace.HitNormal, self:GetGelRadius() )

			timer.Simple( 1, function() if ( IsValid( self ) ) then self:Remove() end end )
			self:NextThink( CurTime() + 10 )
		end
		
	elseif ( trace.Fraction == 0 || !util.IsInWorld( self:GetPos() ) ) then self:Remove() return end
	self.GASL_PAINTPUDDLE_PrevPos = self:GetPos()
	
	return true
end
