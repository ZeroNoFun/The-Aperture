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

	self.GASL_LinkInputs = { }
	self.GASL_LinkOutputs = { }
	self.GASL_LinkConnections = { }
	
	if ( SERVER ) then

		self.GASL_LinkConnectionsFrom = { }

	end

	if ( CLIENT ) then
	
		net.Start( "GASL_LinkConnection" )
		net.WriteString( "init" )
		net.WriteEntity( self )
		net.SendToServer()
		
	end
	
end

function ENT:Draw()

	self:DrawModel()
	
end

----------------------------------------
------------- IO System ----------------
----------------------------------------

function ENT:AddInput( name, func )

	if ( !self.GASL_LinkInputs ) then return end
	
	self.GASL_LinkInputs[ name ] = func
	
end

function ENT:AddOutput( name, value )

	if ( !self.GASL_LinkOutputs ) then return end
	
	self.GASL_LinkOutputs[ name ] = value
	print( name, value , "ADD" )
	
end

function ENT:InitIO()

	local tempInps = { }
	
	if ( !self.GASL_LinkInputs ) then return end
	
	for k, v in pairs( self.GASL_LinkInputs ) do
		tempInps[ k ] = true
	end
	
	print( self, self.GASL_LinkOutputs, table.Count( self.GASL_LinkOutputs ) )
	PrintTable( self.GASL_LinkOutputs )
	
	net.Start( "GASL_LinkConnection" )
		net.WriteString( "initIO" )
		net.WriteEntity( self )
		net.WriteTable( tempInps )
		net.WriteTable( self.GASL_LinkOutputs )
	net.Broadcast()

end

function ENT:ActiveInput( name, value )

	self.GASL_LinkInputs[ name ]( value )

end

function ENT:AddConnection( connectToEnt, inputname, outputname )

	if ( !self.GASL_LinkConnections ) then return end
	if ( !connectToEnt.GASL_LinkConnectionsFrom ) then return end
	self.GASL_LinkConnections[ inputname ] = { ent = connectToEnt, outputname = outputname }
	connectToEnt.GASL_LinkConnectionsFrom[ self:EntIndex().."|"..connectToEnt:EntIndex().."|"..inputname.."|"..outputname ] = { ent = self, inputname = inputname, outputname = outputname }
		
	net.Start( "GASL_LinkConnection" )
		net.WriteString( "addConnection" )
		net.WriteEntity( self )
		net.WriteEntity( connectToEnt )
		net.WriteString( inputname )
	net.Broadcast()

end

function ENT:RemoveConnection( inputname )

	if ( !self.GASL_LinkConnections ) then return end
	local connection = self.GASL_LinkConnections[ inputname ]
	local ent = connection.ent
	local outputname = connection.outputname
	self.GASL_LinkConnections[ inputname ] = nil

	if ( IsValid( ent ) && ent.GASL_LinkConnectionsFrom ) then
		ent.GASL_LinkConnectionsFrom[ self:EntIndex().."|"..ent:EntIndex().."|"..inputname.."|"..outputname ] = nil
	end
		
	net.Start( "GASL_LinkConnection" )
		net.WriteString( "removeConnection" )
		net.WriteEntity( self )
		net.WriteString( inputname )
	net.Broadcast()

end

function ENT:UpdateOutput( name, value )

	if ( !self.GASL_LinkOutputs || self.GASL_LinkOutputs[ name ] == nil ) then return end
	
	self.GASL_LinkOutputs[ name ] = value
	
	for k, v in pairs( self.GASL_LinkConnectionsFrom ) do
		
		local ent = v.ent
		local inputname = v.inputname
		local outputname = v.outputname
		
		if ( !IsValid( ent ) ) then
			self.GASL_LinkConnectionsFrom[ k ] = nil
			break
		end
		
		if ( name == outputname ) then
			ent:ActiveInput( inputname, value )
		end
	
	end

end

net.Receive( "GASL_LinkConnection", function( len, pl )

	local mType = net.ReadString()
	local mEnt = net.ReadEntity()

	print( mEnt, mType )
	if ( !mType || !IsValid( mEnt ) ) then return end

	if ( mType == "init" ) then
		mEnt:InitIO()
		
	elseif ( mType == "initIO" ) then
		local mInputs = net.ReadTable()
		local mOutputs = net.ReadTable()
		mEnt.GASL_LinkInputs = mInputs
		mEnt.GASL_LinkOutputs = mOutputs
		
	elseif ( mType == "addConnection" ) then
		local mConnectTo = net.ReadEntity()
		local mName = net.ReadString()
		mEnt.GASL_LinkConnections[ mName ] = mConnectTo
		
	elseif ( mType == "removeConnection" ) then
		local mName = net.ReadString()
		mEnt.GASL_LinkConnections[ mName ] = nil
		
	end
	
end )

----------------------------------------
------------- PEFFECT ------------------
----------------------------------------

function ENT:PEffectSpawnInit()

	if ( SERVER ) then

		// Portal Gun integration: activation ignore for portals
		self.isClone = true
		self.GASL_PortalsInfo = { }
		self.GASL_PassagesPrev = 0
		self.GASL_EntInfo = { }
		self.GASL_EntitiesEffects = { }
		
	end

	if ( CLIENT ) then
	
	end
	
	self.GASL_PortalEffectUpdate = { }
	
end

function ENT:GetAllPortalPassages( pos, angle )

	-- If pEffect projector detect portal update pEffect
	local pEffectBuildPos = pos
	local pEffectBuildAng = angle
	local portalLoop = true
	local hitPortal = nil
	local hitPortalExit = nil
	local tracePrevHitPos = Vector( )
	local passages = 1

	local points = { }
	
	while ( portalLoop ) do
	
		portalLoop = false
		
		-- Prev Hendling
		if ( hitPortal && hitPortal:IsValid() ) then
			
			-- Getting new position info of next trace test
			local pEffectOffsetPos = hitPortal:WorldToLocal( tracePrevHitPos )
			local pEffectOffsetAngle = hitPortal:WorldToLocalAngles( pEffectBuildAng )
			pEffectOffsetPos.y = -pEffectOffsetPos.y
			pEffectOffsetPos.x = 0

			pEffectBuildPos = hitPortal:GetNWBool( "Potal:Other" ):LocalToWorld( pEffectOffsetPos )
			pEffectBuildAng = hitPortal:GetNWBool( "Potal:Other" ):LocalToWorldAngles( pEffectOffsetAngle + Angle( 0, 180, 0 ) )

			hitPortalExit = hitPortal:GetNWBool( "Potal:Other" )
			hitPortal = nil
			
		end
		
		local trace = util.TraceLine( {
			start = pEffectBuildPos,
			endpos = pEffectBuildPos + pEffectBuildAng:Forward() * 100000,
			filter = function( ent )
				if ( ent == self || ent:GetClass() == "prop_portal" || ent:IsPlayer() || ent:IsNPC() || ent:GetPhysicsObject() && ent:GetPhysicsObject():IsValid() ) then return false end
			end
		} )
		
		table.insert( points, table.Count( points ) + 1, { startpos = pEffectBuildPos, endpos = trace.HitPos } )
		
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

function ENT:MakePEffect( )

	-- If pEffect projector detect portal update pEffect
	local pEffectBuildPos = self:LocalToWorld( Vector( 0, 0, -1 ) )
	local pEffectBuildAng = self:LocalToWorldAngles( Angle( 0, 0, 0 ) )
	local portalLoop = true
	local hitPortal = nil
	local hitPortalExit = nil
	local tracePrevHitPos = Vector( )
	local passages = 1
	local passagesPrev = self.GASL_PassagesPrev
	
	self:PEffectCheckUpdate( )
	
	while ( portalLoop ) do
	
		portalLoop = false
		
		-- Prev Hendling
		if ( hitPortal && hitPortal:IsValid() ) then
			
			-- Getting new position info of next trace test
			local pEffectOffsetPos = hitPortal:WorldToLocal( tracePrevHitPos )
			local pEffectOffsetAngle = hitPortal:WorldToLocalAngles( pEffectBuildAng )
			pEffectOffsetPos.y = -pEffectOffsetPos.y
			pEffectOffsetPos.x = 0
			pEffectBuildPos = hitPortal:GetNWBool( "Potal:Other" ):LocalToWorld( pEffectOffsetPos )
			pEffectBuildAng = hitPortal:GetNWBool( "Potal:Other" ):LocalToWorldAngles( pEffectOffsetAngle + Angle( 0, 180, 0 ) )

			hitPortalExit = hitPortal:GetNWBool( "Potal:Other" )
			hitPortal = nil
			
		end
		
		local trace = util.TraceLine( {
			start = pEffectBuildPos,
			endpos = pEffectBuildPos + pEffectBuildAng:Forward() * 100000,
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

					if ( !self.GASL_PortalsInfo[ v:EntIndex().."_"..( passages + 1 ) ] ) then
					
						-- Saving info about portals, each portal contain their passages and location info
						local portalExit = v:GetNWBool( "Potal:Other" )
						self.GASL_PortalsInfo[ v:EntIndex().."_"..( passages + 1 ) ] = { ent = v, pos = v:GetPos(), ang = v:GetAngles(), thrC = passages }
						self.GASL_PortalsInfo[ portalExit:EntIndex().."_"..passages ] = { ent = portalExit, pos = portalExit:GetPos(), ang = portalExit:GetAngles(), thrC = passages + 1 }

						self.GASL_PortalEffectUpdate.lastPos = Vector( )
						self.GASL_PortalEffectUpdate.lastAngle = Angle( )

					end
					
					hitPortal = v
					break
					
				end
			end
			
		end
		
		-- Handling changes position or angles
		if ( self.GASL_PortalEffectUpdate.lastPos != self:GetPos() or self.GASL_PortalEffectUpdate.lastAngle != self:GetAngles() ) then
		
			-- Rebuilding pEffect specific to this portal
			local pEffect = self:PEffectBuild( trace, pEffectBuildPos, pEffectBuildAng, passages )
			self.GASL_EntitiesEffects[ passages ] = pEffect
			
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
			self:PEffectRemovePEffectFromPortal2End( passages )
		end
		
		self.GASL_PassagesPrev = passages
	end
	
	self.GASL_PortalEffectUpdate.lastPos = self:GetPos()
	self.GASL_PortalEffectUpdate.lastAngle = self:GetAngles()

end

function ENT:ClearAllData()

	self:RemovePEffects()
	self.GASL_PortalEffectUpdate = { }
	self.GASL_EntitiesEffects = { }
	self.GASL_PortalsInfo = { }
	self.GASL_PassagesPrev = 0

end

function ENT:RemovePEffect( index )

	for k, v in pairs( self.GASL_EntitiesEffects[ index ] ) do
	
		if ( v && v:IsValid() ) then v:Remove() end
	
	end

end

function ENT:RemovePEffects()
	for k, v in pairs( self.GASL_EntitiesEffects ) do
	
		if ( v ) then self:RemovePEffect( k ) end
		
	end	

end

function ENT:PEffectRemovePEffectFromPortal2End( index )

	for k, portal in pairs( self.GASL_PortalsInfo ) do
		
		if ( portal.thrC > index ) then
			if ( portal.ent && portal.ent:IsValid() && portal.ent:GetNWBool( "Potal:Other" ) && portal.ent:GetNWBool( "Potal:Other" ):IsValid() ) then
				
				local index = self.GASL_PortalsInfo[ portal.ent:GetNWBool( "Potal:Other" ):EntIndex().."_"..portal.thrC ]
				self:RemovePEffect( index.thrC )
				self.GASL_PortalsInfo[ portal.ent:GetNWBool( "Potal:Other" ):EntIndex().."_"..portal.thrC ] = nil
			end

			self:RemovePEffect( portal.thrC )
			self.GASL_PortalsInfo[ k ] = nil
		end
		
	end
	
end

function ENT:PEffectCheckUpdate()

	---------------------------------
	--------- PEFFECT UPDATE ---------
	---------------------------------

	local removeAllNext = false
	
	-- If portal changed update projector
	for k, portal in pairs( self.GASL_PortalsInfo ) do
	
		if ( !removeAllNext && !portal.ent:IsValid() 
			|| portal.ent:IsValid() && portal.pos != portal.ent:GetPos() 
			|| portal.ent:IsValid() && portal.ang != portal.ent:GetAngles() ) then
			
			removeAllNext = true
			self.GASL_PortalEffectUpdate.lastPos = Vector( )
			self.GASL_PortalEffectUpdate.lastAngle = Angle( )
			
		end
		
		-- Removing all PEffect from that brigde whick was removed to end 
		if ( removeAllNext ) then
		
			if ( portal.ent && portal.ent:IsValid() && portal.ent:GetNWBool( "Potal:Other" ) && portal.ent:GetNWBool( "Potal:Other" ):IsValid() ) then
				
				local index = self.GASL_PortalsInfo[ portal.ent:GetNWBool( "Potal:Other" ):EntIndex().."_"..portal.thrC ]
				if ( index ) then
					self:RemovePEffect( index.thrC )
					self.GASL_PortalsInfo[ portal.ent:GetNWBool( "Potal:Other" ):EntIndex().."_"..portal.thrC ] = nil
				end
				
			end

			self:RemovePEffect( portal.thrC )
			self.GASL_PortalsInfo[ k ] = nil
		end
	
	end
end

function ENT:PEffectBuild( trace, pEffectBuildPos, pEffectBuildAng, passages )

	local disatance = 0
	local hitPortal = nil
	local hitPortalExit = nil
	local tracePrevHitPos = Vector()
	
	-- Removing all prev pEffects
	if ( self.GASL_EntitiesEffects[ passages ] ) then
	for k, v in pairs( self.GASL_EntitiesEffects[ passages ] ) do
		if ( v:IsValid() ) then v:Remove() end
	end
	end
	
	disatance = pEffectBuildPos:Distance( trace.HitPos )
	
	local addingDist = 0
	local pEffect = { }
	while ( disatance > addingDist ) do

		local ent = ents.Create( "prop_physics" )
		ent:SetModel( self.GASL_EntInfo.model )
		ent:SetPos( pEffectBuildPos + pEffectBuildAng:Forward() * addingDist )
		ent:SetAngles( pEffectBuildAng )
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
		
		table.insert( pEffect, table.Count( pEffect ) + 1, ent )
		addingDist = addingDist + self.GASL_EntInfo.length
	end
	
	return pEffect
	
end