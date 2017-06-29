AddCSLuaFile()

LIB_LINK_TA = {}
LIB_LINK_TA.FREE_INX = 1

function LIB_LINK_TA:AddInput(name, func)
	if !self.TA_LinkInputs then self.TA_LinkInputs = {} end
	self.TA_LinkInputs[ name ] = func
end

function LIB_LINK_TA:AddOutput( name, value )
	if !self.TA_LinkOutputs then self.TA_LinkOutputs = {} end
	
	self.TA_LinkOutputs[ name ] = value
end

function LIB_LINK_TA:InitIO()

	local tempInps = { }
	
	if ( !self.TA_LinkInputs ) then return end
	
	for k, v in pairs( self.TA_LinkInputs ) do
		tempInps[ k ] = true
	end
		
	net.Start( "TA_LinkConnection" )
		net.WriteString( "initIO" )
		net.WriteEntity( self )
		net.WriteTable( tempInps )
		net.WriteTable( self.TA_LinkOutputs )
	net.Broadcast()

end

function LIB_LINK_TA:ActiveInput( name, value )

	self.TA_LinkInputs[ name ]( value )

end

function LIB_LINK_TA:AddConnection( connectToEnt, inputname, outputname )

	if ( !self.TA_LinkConnections ) then return end
	if ( !connectToEnt.TA_LinkConnectionsFrom ) then return end
	self.TA_LinkConnections[ inputname ] = { ent = connectToEnt, outputname = outputname }
	connectToEnt.TA_LinkConnectionsFrom[ self:EntIndex().."|"..connectToEnt:EntIndex().."|"..inputname.."|"..outputname ] = { ent = self, inputname = inputname, outputname = outputname }
		
	net.Start( "TA_LinkConnection" )
		net.WriteString( "addConnection" )
		net.WriteEntity( self )
		net.WriteEntity( connectToEnt )
		net.WriteString( inputname )
	net.Broadcast()

end

function LIB_LINK_TA:RemoveConnection( inputname )

	if ( !self.TA_LinkConnections ) then return end
	local connection = self.TA_LinkConnections[ inputname ]
	local ent = connection.ent
	local outputname = connection.outputname
	self.TA_LinkConnections[ inputname ] = nil

	if ( IsValid( ent ) && ent.TA_LinkConnectionsFrom ) then
		ent.TA_LinkConnectionsFrom[ self:EntIndex().."|"..ent:EntIndex().."|"..inputname.."|"..outputname ] = nil
	end
		
	net.Start( "TA_LinkConnection" )
		net.WriteString( "removeConnection" )
		net.WriteEntity( self )
		net.WriteString( inputname )
	net.Broadcast()

end

function LIB_LINK_TA:UpdateOutput( name, value )

	if ( !self.TA_LinkOutputs || self.TA_LinkOutputs[ name ] == nil ) then return end
	
	self.TA_LinkOutputs[ name ] = value
	
	for k, v in pairs( self.TA_LinkConnectionsFrom ) do
		
		local ent = v.ent
		local inputname = v.inputname
		local outputname = v.outputname
		
		if ( !IsValid( ent ) ) then
			self.TA_LinkConnectionsFrom[ k ] = nil
			break
		end
		
		if ( name == outputname ) then
			ent:ActiveInput( inputname, value )
		end
	
	end

end

net.Receive( "TA_LinkConnection", function( len, pl )

	local mType = net.ReadString()
	local mEnt = net.ReadEntity()

	if ( !mType || !IsValid( mEnt ) ) then return end

	if ( mType == "init" ) then
		mEnt:InitIO()
		
	elseif ( mType == "initIO" ) then
		local mInputs = net.ReadTable()
		local mOutputs = net.ReadTable()
		mEnt.TA_LinkInputs = mInputs
		mEnt.TA_LinkOutputs = mOutputs
		
	elseif ( mType == "addConnection" ) then
		local mConnectTo = net.ReadEntity()
		local mName = net.ReadString()
		mEnt.TA_LinkConnections[ mName ] = mConnectTo
		
	elseif ( mType == "removeConnection" ) then
		local mName = net.ReadString()
		mEnt.TA_LinkConnections[ mName ] = nil
		
	end
	
end )