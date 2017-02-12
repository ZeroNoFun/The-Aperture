AddCSLuaFile( )

ENT.Base 			= "gasl_base_ent"

ENT.Editable		= true
ENT.PrintName		= "Aerial Faith Plate"
ENT.Category		= "Aperture Science"
ENT.Spawnable		= true
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !trace.Hit ) then return end
	
	local ent = ents.Create( ClassName )
	ent:SetPos( trace.HitPos + trace.HitNormal * 10 )
	ent:SetModel( "models/props/faith_plate.mdl" )
	ent:SetAngles( trace.HitNormal:Angle() + Angle( 90, 0, 0 ) )
	ent:Spawn()
	ent:SetSkin( 1 )
	ent:Activate()

	return ent

end

function ENT:SetupDataTables()

	self:NetworkVar( "Vector", 0, "LandPoint" )
	self:NetworkVar( "Float", 1, "LaunchHeight" )
	self:NetworkVar( "Bool", 2, "Enable" )
	self:NetworkVar( "Bool", 3, "StartEnabled" )
	self:NetworkVar( "Float", 4, "TimeOfFlight" )
	self:NetworkVar( "Vector", 5, "LaunchVector" )

end

function ENT:Draw()

	self:DrawModel()
	
end

function ENT:Initialize()

	self.BaseClass.Initialize( self )

	-- no more client side
	if ( CLIENT ) then return end

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )

	self:AddInput( "Enable", function( value ) self:ToggleEnable( value ) end )
	
	self.GASL_Cooldown = 0
	self.GASL_LaunchedEntities = { }
	self.GASL_TrajectoryCurve = { }
	self.GASL_CatapultUpdate = Vector( )
	self.GASL_LaunchAngle = 0
	self.GASL_LaunchForce = 0
	self.GASL_FlyTime = 0
	
end

function ENT:Think()

	self:NextThink( CurTime() + 0.1 )
	
	if ( CLIENT ) then return end

	if ( self:GetLandPoint() == Vector() ) then return end
	
	local FlyingSpeedMult = 4
	local BoxSize = 50

	local trace = util.TraceHull( {
		start = self:GetPos(),
		endpos = self:GetPos() + self:GetUp() * BoxSize,
		filter = self,
		ignoreworld = true,
		mins = Vector( -BoxSize, -BoxSize, -BoxSize ),
		maxs = Vector( BoxSize, BoxSize, BoxSize ),
		mask = MASK_SHOT_HULL
	} )
	
	-- launch init
	if ( trace.Entity:IsValid() && self.GASL_Cooldown == 0 && self:GetEnable()
		&& ( trace.Entity:IsNPC() 
		|| trace.Entity:IsPlayer() 
		|| trace.Entity:GetPhysicsObject():IsValid() ) ) then

		local ent = trace.Entity
		
		APERTURESCIENCE:PlaySequence( self, "straightup", 1.0 )
		self:EmitSound( "door/heavy_metal_stop1.wav" )
		EmitSound( "door/heavy_metal_stop1.wav", self:LocalToWorld( Vector( 0, 0, 100 ) ), self:EntIndex(), CHAN_AUTO, 1, 75, 0, 100 )
		
		self:LaunchEntity( ent )
		self.GASL_Cooldown = 10

	end
	
	-- Reseting cooldown
	if ( self.GASL_Cooldown > 0 ) then self.GASL_Cooldown = self.GASL_Cooldown - 1
	elseif ( self.GASL_Cooldown < 0 ) then  self.GASL_Cooldown = 0 end		

	return true
	
end

-- no more client side
if ( CLIENT ) then return end

function ENT:CalculateTrajectoryForceAng( )

	local pos = self:GetPos()
	local destination = self:GetLandPoint()
	local locXY = Vector( destination.x, destination.y, 0 ):Distance( Vector( pos.x, pos.y, 0 ) )
    local locZ = destination.z - pos.z
	local Gravity = -physenv.GetGravity().z
	
	local force = math.pow( self:GetLaunchHeight() * 100 + 55000, 1 / 1.7 ) --start force
	local dist = 0
	local angle = 0
	local time = 0
	local velX = 0
	local velY = 0
	local maxY = 0
	local brk = 0
	
	local isReversed = false
	
	while math.abs( dist - locXY ) > 1 do
		brk = brk + 1
		if ( brk > 1000000 ) then MsgC( Color( 255, 0, 0 ), "Can't calculate trajectory" ) break end
		angle = angle + ( locXY - dist ) / 5000
		
		velX = math.cos( ( 90 - angle ) * math.pi / 180 ) * force
		velY = math.sin( ( 90 - angle ) * math.pi / 180 ) * force
		time = velY / Gravity -- time to lift up
		maxY = ( velY * velY ) / ( 2 * Gravity )
		
		time = time + math.sqrt( ( ( maxY - locZ ) * 2 ) / Gravity )
		dist = velX * time
		
		-- if doesn't found add force
		if ( angle > 360 || dist ~= dist ) then
			angle = angle - 360
			if ( dist ~= dist ) then force = force + 1 else force = force + 10 end
			
			dist = 0
		end		
		
	end
	
	if ( time == nil ) then
		isReversed = true
		
		while math.abs( dist - locXY ) > 1 do
			brk = brk + 1
			if ( brk > 1000000 ) then MsgC( Color( 255, 0, 0 ), "Can't calculate trajectory" ) break end
		
			angle = angle + ( locXY - dist ) / 5000
			
			velX = math.cos( angle * math.pi / 180 ) * force
			velY = math.sin( angle * math.pi / 180 ) * force
			time = velY / Gravity -- time to lift up
			maxY = ( velY * velY ) / ( 2 * Gravity )
			
			time = time + math.sqrt( ( ( maxY - locZ ) * 2 ) / Gravity )
			dist = velX * time
			
			-- if doesn't found add force
			if ( angle > 360 || dist ~= dist ) then
				angle = angle - 360
				force = force + 100
				dist = 0
			end		
			
		end
		
	end
	
	print( "VelX: ", math.Round( velX ),"  VelY: ", math.Round( velY ), "  MaxY: ", math.Round( maxY ), "  Time: ", math.Round( time * 100 ) / 100, " Force: ", force )
	
	self.GASL_LaunchAngle = angle
	self.GASL_LaunchForce = force
	self.GASL_FlyTime = time

	local destination = self:GetLandPoint()
	local direction = Angle()
	
	if ( isReversed ) then
		direction = Angle( -angle, ( destination - self:GetPos() ):Angle().y, 0 )
	else
		direction = Angle( -90 + angle, ( destination - self:GetPos() ):Angle().y, 0 )
	end
	
	local velocity = direction:Forward() * force
		
	self:SetTimeOfFlight( time )
	self:SetLaunchVector( velocity )

	return angle, force, time
	
end

function ENT:SetLandingPoint( point )

	self:SetLandPoint( point )
	self:CalculateTrajectoryForceAng()
	
end

function ENT:LaunchEntity( entity )

	local angle = self.GASL_LaunchAngle
	local force = self.GASL_LaunchForce
	local time = self.GASL_FlyTime
	
	local velocity = self:GetLaunchVector()
	
	velocity = velocity + ( self:GetPos() - entity:GetPos() ) / time
	
	if ( entity:IsPlayer() ) then entity:SetVelocity( velocity - entity:GetVelocity() )
	elseif ( IsValid( entity:GetPhysicsObject() ) ) then entity:GetPhysicsObject():SetVelocity( velocity )
		
		if ( !timer.Exists( "GASL_Catapult_Fall"..entity:EntIndex() ) ) then
			local entityPhys = entity:GetPhysicsObject()
			entity.GASL_ENT_LastMass = entityPhys:GetMass()
			entityPhys:SetMass( 5000 )
			
			timer.Create( "GASL_Catapult_Fall"..entity:EntIndex(), self:GetTimeOfFlight() - 0.5, 1, function()
				if ( IsValid( entity ) && entity.GASL_ENT_LastMass ) then entityPhys:SetMass( entity.GASL_ENT_LastMass ) end
			end )
		end
		
	end
end

function ENT:TriggerInput( iname, value )
	if ( !WireAddon ) then return end

	if ( iname == "Enable" ) then self:ToggleEnable( tobool( value ) ) end
	
end

function ENT:ToggleEnable( bDown )

	if ( self:GetStartEnabled() ) then bDown = !bDown end
	self:SetEnable( bDown )
	
	if ( self:GetEnable() ) then self:SetSkin( 0 ) else self:SetSkin( 1 ) end
	
end