AddCSLuaFile( )

local WireAddon = WireAddon or WIRE_CLIENT_INSTALLED

ENT.Editable		= true
ENT.PrintName		= "GASL base class"
ENT.AutomaticFrameAdvance = true

if ( WireAddon ) then

	DEFINE_BASECLASS( "base_wire_entity" )
	ENT.WireDebugName = "GASL"
	
else

	DEFINE_BASECLASS( "base_gmodentity" )

end

function ENT:Initialize()

	if ( SERVER ) then

		// Portal Gun integration: activation ignore for portals
		self.isClone = true
		self.GASL_Portals = { }
		self.GASL_PassagesPrev = 0
		self.GASL_EntInfo = { }
		self.GASL_EntitiesEffects = { }
		
	end

	if ( CLIENT ) then
	
	end
	
	self.GASL_BridgeUpdate = { }
	
end

function ENT:Draw()

	self:DrawModel()
	
end

function ENT:GetAllPortalPassages( pos, angle )

	-- If wall projector detect portal update bridge
	local bridgeBuildPos = pos
	local bridgeBuildAng = angle
	local portalLoop = true
	local hitPortal = nil
	local hitPortalExit = nil
	local tracePrevHitPos = Vector( )
	local passages = 1

	local points = { }
	local a = 0
	while ( portalLoop ) do
		a = a + 1
		portalLoop = false
		
		-- Prev Hendling
		if ( hitPortal && hitPortal:IsValid() ) then
			
			-- Getting new position info of next trace test
			local bridgeOffsetPos = hitPortal:WorldToLocal( tracePrevHitPos )
			local bridgeOffsetAngle = hitPortal:WorldToLocalAngles( bridgeBuildAng )
			bridgeOffsetPos.y = -bridgeOffsetPos.y
			
			bridgeOffsetPos.x = 0
			bridgeBuildPos = hitPortal:GetNWBool( "Potal:Other" ):LocalToWorld( bridgeOffsetPos )
			bridgeBuildAng = hitPortal:GetNWBool( "Potal:Other" ):LocalToWorldAngles( bridgeOffsetAngle + Angle( 0, 180, 0 ) )

			hitPortalExit = hitPortal:GetNWBool( "Potal:Other" )
			hitPortal = nil
			
		end
		
		local trace = util.TraceLine( {
			start = bridgeBuildPos,
			endpos = bridgeBuildPos + bridgeBuildAng:Forward() * 100000,
			filter = function( ent )
				if ( ent == self || ent:GetClass() == "prop_portal" || ent:IsPlayer() || ent:IsNPC() || ent:GetPhysicsObject() && ent:GetPhysicsObject():IsValid() ) then return false end
			end
		} )
		
		table.insert( points, table.Count( points ) + 1, { startpos = bridgeBuildPos, endpos = trace.HitPos } )
		
		-- Portal loop if trace hit portal
		for k, v in pairs( ents.FindByClass( "prop_portal" ) ) do
			
			local pos = v:WorldToLocal( trace.HitPos )
			if ( pos.x > -1 && pos.x < 10 
				&& pos.y > -30 && pos.y < 30
				&& pos.z > -45 && pos.z < 45 ) then

				if ( v:GetNWBool( "Potal:Other" ) && v:GetNWBool( "Potal:Other" ):IsValid() ) then
					tracePrevHitPos = trace.HitPos
					passages = passages + 1
					portalLoop = true

					hitPortal = v
					
					break
				end
				
			end
			
		end
		
	end
	
	return points;

end

function ENT:MakeBridges( )

	-- If wall projector detect portal update bridge
	local bridgeBuildPos = self:LocalToWorld( Vector( 0, 0, -1 ) )
	local bridgeBuildAng = self:LocalToWorldAngles( Angle( 0, 0, 0 ) )
	local portalLoop = true
	local hitPortal = nil
	local hitPortalExit = nil
	local tracePrevHitPos = Vector( )
	local passages = 1
	local passagesPrev = self.GASL_PassagesPrev
	
	self:BridgeCheckUpdate( )
	
	while ( portalLoop ) do
	
		portalLoop = false
		
		-- Prev Hendling
		if ( hitPortal && hitPortal:IsValid() ) then
			
			-- Getting new position info of next trace test
			local bridgeOffsetPos = hitPortal:WorldToLocal( tracePrevHitPos )
			local bridgeOffsetAngle = hitPortal:WorldToLocalAngles( bridgeBuildAng )
			bridgeOffsetPos.y = -bridgeOffsetPos.y
			bridgeOffsetPos.x = 0
			bridgeBuildPos = hitPortal:GetNWBool( "Potal:Other" ):LocalToWorld( bridgeOffsetPos )
			bridgeBuildAng = hitPortal:GetNWBool( "Potal:Other" ):LocalToWorldAngles( bridgeOffsetAngle + Angle( 0, 180, 0 ) )

			hitPortalExit = hitPortal:GetNWBool( "Potal:Other" )
			hitPortal = nil
			
		end
		
		local trace = util.TraceLine( {
			start = bridgeBuildPos,
			endpos = bridgeBuildPos + bridgeBuildAng:Forward() * 100000,
			filter = function( ent )
				if ( ent == self || ent:GetClass() == "prop_portal" || ent:IsPlayer() || ent:IsNPC() || ent:GetPhysicsObject() && ent:GetPhysicsObject():IsValid() ) then return false end
			end
		} )
		
		-- Searth for: is tracer hit portal
		for k, v in pairs( ents.FindByClass( "prop_portal" ) ) do
			
			local pos = v:WorldToLocal( trace.HitPos )
			if ( pos.x > -1 && pos.x < 10 
				&& pos.y > -30 && pos.y < 30
				&& pos.z > -45 && pos.z < 45 ) then

				if ( v:GetNWBool( "Potal:Other" ) && v:GetNWBool( "Potal:Other" ):IsValid() ) then

					if ( !self.GASL_Portals[ v:EntIndex().."_"..( passages + 1 ) ] ) then
					
						-- Saving info about portals, each portal contain their passages and location info
						local portalExit = v:GetNWBool( "Potal:Other" )
						self.GASL_Portals[ v:EntIndex().."_"..( passages + 1 ) ] = { ent = v, pos = v:GetPos(), ang = v:GetAngles(), thrC = passages }
						self.GASL_Portals[ portalExit:EntIndex().."_"..passages ] = { ent = portalExit, pos = portalExit:GetPos(), ang = portalExit:GetAngles(), thrC = passages + 1 }

						self.GASL_BridgeUpdate.lastPos = Vector( )
						self.GASL_BridgeUpdate.lastAngle = Angle( )
					end
					
					hitPortal = v
					break
					
				end
			end
			
		end
		
		-- Handling changes position or angles
		if ( self.GASL_BridgeUpdate.lastPos != self:GetPos() or self.GASL_BridgeUpdate.lastAngle != self:GetAngles() ) then
		
			-- Rebuilding bridge specific to this portal
			local bridge = self:BridgeBuild( trace, bridgeBuildPos, bridgeBuildAng, passages )
			self.GASL_EntitiesEffects[ passages ] = bridge
			
		end

		-- Post Hendling
		if ( hitPortal && hitPortal:IsValid() ) then
			
			-- checking for another passing
			if ( hitPortal:GetNWBool( "Potal:Other" ) && hitPortal:GetNWBool( "Potal:Other" ):IsValid() ) then
				tracePrevHitPos = trace.HitPos
				passages = passages + 1
				portalLoop = true
			end
			
		end
		
		if ( passagesPrev > passages ) then
			self:BridgeRemoveBridgesFromPortal2End( passages )
		end
		
		self.GASL_PassagesPrev = passages
	end

end

function ENT:ClearAllData()

	self:RemoveBridges()
	self.GASL_BridgeUpdate = { }
	self.GASL_EntitiesEffects = { }
	self.GASL_Portals = { }
	self.GASL_PassagesPrev = 0

end

function ENT:RemoveBridge( index )

	for k, v in pairs( self.GASL_EntitiesEffects[ index ] ) do
	
		if ( v && v:IsValid() ) then v:Remove() end
	
	end

end

function ENT:RemoveBridges()
	
	for k, v in pairs( self.GASL_EntitiesEffects ) do
	
		if ( v ) then self:RemoveBridge( k ) end
		
	end	

end

function ENT:BridgeRemoveBridgesFromPortal2End( index )

	for k, portal in pairs( self.GASL_Portals ) do
		
		if ( portal.thrC > index ) then
			if ( portal.ent && portal.ent:IsValid() && portal.ent:GetNWBool( "Potal:Other" ) && portal.ent:GetNWBool( "Potal:Other" ):IsValid() ) then
				
				local index = self.GASL_Portals[ portal.ent:GetNWBool( "Potal:Other" ):EntIndex().."_"..portal.thrC ]
				self:RemoveBridge( index.thrC )
				self.GASL_Portals[ portal.ent:GetNWBool( "Potal:Other" ):EntIndex().."_"..portal.thrC ] = nil
			end

			self:RemoveBridge( portal.thrC )
			self.GASL_Portals[ k ] = nil
		end
		
	end
	
end

function ENT:BridgeCheckUpdate()

	---------------------------------
	--------- BRIDGE UPDATE ---------
	---------------------------------

	local removeAllNext = false
	
	-- If portal changed update projector
	for k, portal in pairs( self.GASL_Portals ) do
	
		if ( !removeAllNext && !portal.ent:IsValid() 
			|| portal.ent:IsValid() && portal.pos != portal.ent:GetPos() 
			|| portal.ent:IsValid() && portal.ang != portal.ent:GetAngles() ) then
			
			removeAllNext = true
			self.GASL_BridgeUpdate.lastPos = Vector( )
			self.GASL_BridgeUpdate.lastAngle = Angle( )
			
		end
		
		-- Removing all bridges from that brigde whick was removed to end 
		if ( removeAllNext ) then
		
			if ( portal.ent && portal.ent:IsValid() && portal.ent:GetNWBool( "Potal:Other" ) && portal.ent:GetNWBool( "Potal:Other" ):IsValid() ) then
				
				local index = self.GASL_Portals[ portal.ent:GetNWBool( "Potal:Other" ):EntIndex().."_"..portal.thrC ]
				if ( index ) then
					self:RemoveBridge( index.thrC )
					self.GASL_Portals[ portal.ent:GetNWBool( "Potal:Other" ):EntIndex().."_"..portal.thrC ] = nil
				end
				
			end

			self:RemoveBridge( portal.thrC )
			self.GASL_Portals[ k ] = nil
		end
	
	end
end

function ENT:BridgeBuild( trace, bridgeBuildPos, bridgeBuildAng, passages )

	local disatance = 0
	local hitPortal = nil
	local hitPortalExit = nil
	local tracePrevHitPos = Vector()
	
	-- Removing all prev walls
	if ( self.GASL_EntitiesEffects[ passages ] ) then
	for k, v in pairs( self.GASL_EntitiesEffects[ passages ] ) do
		if ( v:IsValid() ) then v:Remove() end
	end
	end
	
	disatance = bridgeBuildPos:Distance( trace.HitPos )
	
	local addingDist = 0
	local bridge = { }
	while ( disatance > addingDist ) do

		local ent = ents.Create( "prop_physics" )
		ent:SetModel( self.GASL_EntInfo.model )
		ent:SetPos( bridgeBuildPos + bridgeBuildAng:Forward() * addingDist )
		ent:SetAngles( bridgeBuildAng )
		ent:Spawn()
		ent:SetColor( self.GASL_EntInfo.color )
		ent:SetPersistent( true )
		ent.GASL_Ignore = true
		ent.GASL_Untouchable = true
		
		if ( self.GASL_EntInfo.posoffset ) then
			ent:SetPos( ent:LocalToWorld( self.GASL_EntInfo.posoffset ) )
		end
		
		if ( self.GASL_EntInfo.angleoffset ) then
			ent:SetAngles( ent:LocalToWorldAngles( self.GASL_EntInfo.angleoffset ) )
		end

		ent:DrawShadow( false )
		if ( self.GASL_EntInfo.parent ) then ent:SetParent( self ) end
		// Portal Gun integration: activation ignore for portals
		ent.isClone = true
		
		if ( ent:GetPhysicsObject():IsValid() ) then
		
			local physEnt = ent:GetPhysicsObject( )
			physEnt:SetMaterial( "item" )
			physEnt:EnableMotion( false )
			
		end
		
		table.insert( bridge, table.Count( bridge ) + 1, ent )
		addingDist = addingDist + self.GASL_EntInfo.length
	end
	
	return bridge
	
end